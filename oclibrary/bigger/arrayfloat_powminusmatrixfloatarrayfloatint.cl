__kernel void marrow_kernel(global float* out_arrayfloat0, global float* matrixfloat1, global float* arrayfloat2, const int int_3, const unsigned long size0, const unsigned long size1) {
// currentDim:  1
const size_t index0 = get_global_id(0);
if (index0 >= size0) return;
const size_t index1 = get_global_id(1);
if (index1 >= size1) return;
const size_t index01 = index1 * size0 + index0;
float local0 = matrixfloat1[index01] - arrayfloat2[index0];
out_arrayfloat0[index01] = pow(local0, int_3);
}
