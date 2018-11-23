__kernel void marrow_kernel(global float* out_arrayfloat0, global float* arrayfloat1, global float* arrayfloat2, const int int_3, const unsigned long limit0) {
const size_t index0 = get_global_id(0);
if (index0 >= limit0) return;
float local0 = arrayfloat1[index0] - arrayfloat2[index0];
out_arrayfloat0[index0] = pow(local0, int_3);
}
