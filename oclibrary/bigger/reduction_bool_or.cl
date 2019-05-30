#define T bool
#define Operation(X, Y) ((X) || (Y))

__kernel void marrow_kernel(__global T *g_idata, __global T *g_odata, const unsigned long n, __local volatile T* sdata) { 
    size_t blockSize = get_local_size(0); 
    size_t tid = get_local_id(0); 
    size_t first = get_group_id(0) * 2 * blockSize + tid; 
    size_t i = first; 
    size_t gridSize = blockSize * 2 * get_num_groups(0); 

    if (i < n) { 
       sdata[tid] = g_idata[i]; 

       if (i + blockSize < n) 
         sdata[tid] = Operation(sdata[tid], g_idata[i + blockSize]); 
       i += gridSize; 

       while (i < n) { 
        sdata[tid] = Operation(sdata[tid], g_idata[i]); 

         if (i + blockSize < n) 
             sdata[tid] = Operation(sdata[tid], g_idata[i + blockSize]); 
         i += gridSize; 
       } 
    } 

    barrier(CLK_LOCAL_MEM_FENCE); 
    
    if (tid < 128 && (first + 128 < n)) { sdata[tid] = Operation(sdata[tid], sdata[tid + 128]); } 
    barrier(CLK_LOCAL_MEM_FENCE); 

    if (tid < 64 && (first + 64 < n)) { sdata[tid] = Operation(sdata[tid], sdata[tid + 64]);} 
    barrier(CLK_LOCAL_MEM_FENCE); 
    
    if (tid < 32) { 
       if (first + 32 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 32]); 
       if (first + 16 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 16]); 
       if (first +  8 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 8]); 
       if (first +  4 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 4]); 
       if (first +  2 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 2]); 
       if (first +  1 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 1]); 
    } 

    if (tid == 0) 
       g_odata[get_group_id(0)] = sdata[0]; 
}