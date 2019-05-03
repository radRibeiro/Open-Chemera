#define T float
#define Operation(X, Y) ((X) + (Y))

__kernel void marrow_kernel(__global T *g_idata, __global T *g_odata, unsigned long nrows, unsigned long ncols, __local volatile T* sdata) {

    size_t blockSize = get_local_size(0);
    size_t tid = get_local_id(0);
    size_t gid = get_global_id(0);
    size_t gridSize = blockSize * 2 * get_num_groups(0);
    size_t group = get_group_id(0);
    size_t nthreads = get_global_size(0);

    unsigned rows_per_thread = (nrows*ncols+nthreads-1)/nthreads + 1;
    unsigned adjustment = blockSize % ncols;

    size_t row =  (gid - adjustment*group) / ncols ;

   for (size_t k = 0; k < rows_per_thread; k++, row+=nrows/rows_per_thread) {

    if ((tid +  adjustment) >= blockSize)
      break;

    size_t first =  tid%ncols + row * ncols;    size_t i = first;
    size_t n = (first + ncols  ) / ncols * ncols;

    if ((i < n) && (row < nrows)) {

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

    size_t pos = first % ncols;
    if ((pos < 128) && (first + 128 < n)) { sdata[tid] = Operation(sdata[tid], sdata[tid + 128]); }
    barrier(CLK_LOCAL_MEM_FENCE);

    if ((pos < 64) && (first + 64 < n)) { sdata[tid] = Operation(sdata[tid], sdata[tid + 64]);}
    barrier(CLK_LOCAL_MEM_FENCE);

    if (pos < 32) {
        if (first + 32 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 32]);
        if (first + 16 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 16]);
        if (first +  8 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 8]);
        if (first +  4 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 4]);
        if (first +  2 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 2]);
        if (first +  1 < n) sdata[tid] = Operation(sdata[tid], sdata[tid + 1]);
    }

    if ((pos == 0) && (row < nrows)) {
           g_odata[row] = sdata[tid];
    }
   }
}
