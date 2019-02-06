__kernel void marrow_kernel(global float* out_tensor3float3, global float* tensor3float4, const unsigned long size0, const unsigned long size1, const unsigned long size2) {
// currentDim:  2
// currentDim:  1
const size_t index0 = get_global_id(0);
if (index0 >= size0) return;
const size_t index1 = get_global_id(1);
if (index1 >= size1) return;
const size_t index01 = index1 * size0 + index0;
const size_t size01 = size1 * size0;
const size_t index2 = get_global_id(2);
if (index2 >= size2) return;
const size_t index012 = index2 * size01 + index01;
out_tensor3float3[index012] = tensor3float4[index012] * tensor3float4[index012];
}
