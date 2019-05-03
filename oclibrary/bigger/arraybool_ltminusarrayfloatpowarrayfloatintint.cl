__kernel void marrow_kernel(global bool* out_arraybool0, global float* arrayfloat1, global float* arrayfloat2, const int int_3, const int int_4, const unsigned long size0) {
const size_t index0 = get_global_id(0);
if (index0 >= size0) return;
float local0 = pow(arrayfloat2[index0], int_3);
float local1 = arrayfloat1[index0] - local0;
out_arraybool0[index0] = local1 < int_4;
}
