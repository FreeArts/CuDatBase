#include "cuda_select.cuh"

__global__ void test_kernel(void) {
}

void wrapper(void)
{
		test_kernel <<<1, 1>>> ();
		printf("Hello, world!");
}
