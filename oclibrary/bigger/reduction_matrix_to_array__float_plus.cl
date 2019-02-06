#define T float
#define Operation(X, Y) ((X) + (Y))

__kernel void marrow_kernel( __global T *g_odata,__global T *g_idata, 
                const unsigned long column_count, const unsigned long row_count, __local volatile T* sdata) {

    size_t tid = get_local_id(0);
    size_t gid = get_global_id(0);

    size_t row = gid / column_count;
    size_t column = gid % column_count;


    if(row < row_count && column < column_count)
    {
        sdata[tid] = g_idata[gid];
    }
    barrier(CLK_LOCAL_MEM_FENCE);

    if(row < row_count && column < column_count)
    {
       size_t step = column_count / 2;
       size_t limit = column_count;

       while(step > 0)
       {
            if(column + step < limit) {
                if(tid + step < get_local_size(0))
                {
                    sdata[tid] = Operation(sdata[tid], sdata[tid + step]);
                }
                else if (gid + step < column_count * row_count)
                {
                    sdata[tid] = Operation(sdata[tid], g_idata[gid + step]);
                }
            }

            barrier(CLK_LOCAL_MEM_FENCE);

            step /= 2;
            limit /= 2;
       }
    }


    barrier(CLK_LOCAL_MEM_FENCE);

    if(row < row_count && column == 0)
    {
        g_odata[row] = sdata[tid];
    }

}