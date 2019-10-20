
#include "cuda_select.cuh"
#include <cooperative_groups.h>
#include <vector>

//------Real Functions----

CudaSelect::CudaSelect() {
  // copyDataToDevice();
}

CudaSelect::~CudaSelect() {}

__device__ int stepper = 0;
__global__ void searcData(long int *f_dataBase_p, long int *f_resultLines_p,
                          const unsigned int f_databaseRowSize_ui,
                          const unsigned int f_databaseColumnSize_ui,
                          const unsigned int f_targetWord_ui) {

  int rowThread = blockIdx.x * blockDim.x + threadIdx.x;
  int columnThread = blockIdx.y * blockDim.y + threadIdx.y;

  long int temp =
      f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + columnThread];
  if (temp == f_targetWord_ui) {
    // printf("Founded threadPair: %i %i\n",rowThread,columnThread);
    for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {
      long int l_dataBaseFoundedLineContent_li =
          f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];
      f_resultLines_p[l_it_x + stepper] = l_dataBaseFoundedLineContent_li;
      // printf("Array %d \n",
      // f_resultLines_p[(f_databaseColumnSize_ui)+l_it_x]);
    }
    atomicAdd(&stepper, f_databaseColumnSize_ui);
  }

  auto syncGroup = cooperative_groups::this_thread_block();
  syncGroup.sync();
  //__syncthreads();
}

void CudaSelect::copyDataToDevice(
    const vector<vector<long int>> &f_dataBase_r,
    const unsigned int f_databaseRowSize_ui,
    unsigned int f_databaseColumnSize_ui,
    thrust::device_vector<long int> &f_DeviceDataBase_r) {
  int l_tmpDatabaseContainer_i[f_databaseRowSize_ui][f_databaseColumnSize_ui];

  unsigned int l_it_x = 0;
  unsigned int l_it_y = 0;

  for (vector<long int> vec : f_dataBase_r) {
    for (long int vector_member : vec) {
      l_tmpDatabaseContainer_i[l_it_x][l_it_y] = vector_member;
      l_it_y++;
    }
    l_it_y = 0;
    l_it_x++;
  }

  printf("\n");

  // What??
  thrust::copy(&(l_tmpDatabaseContainer_i[0][0]),
               &(l_tmpDatabaseContainer_i[f_databaseRowSize_ui]
                                         [f_databaseColumnSize_ui]),
               f_DeviceDataBase_r.begin());
}

void CudaSelect::CudaRun(const vector<string> &f_selectRule,
                         const vector<vector<long int>> &f_dataBase_r,
                         const vector<string> &f_dataBaseHeader_v) {

  unsigned int l_databaseRowSize_ui = f_dataBase_r.size();
  unsigned int l_databaseColumnSize_ui = f_dataBaseHeader_v.size();

  // thrust::device_vector<long int> *l_collectDataVector_p(NULL);
  // thrust::device_vector<long int>
  // l_workDataVector(l_databaseRowSize_ui*l_databaseColumnSize_ui);

  // thrust::device_vector<long int>
  // l_AND_collectDataVector(l_databaseRowSize_ui*l_databaseColumnSize_ui);
  // thrust::device_vector<long int>
  // l_OR_collectDataVector(l_databaseRowSize_ui*l_databaseColumnSize_ui);

  thrust::device_vector<long int> l_DeviceDatabase(l_databaseRowSize_ui *
                                                   l_databaseColumnSize_ui);
  thrust::device_vector<long int> l_DeviceResult(l_databaseRowSize_ui *
                                                 l_databaseColumnSize_ui);
  thrust::host_vector<long int> l_foundedResult(l_databaseRowSize_ui *
                                                l_databaseColumnSize_ui);

  copyDataToDevice(f_dataBase_r, l_databaseRowSize_ui, l_databaseColumnSize_ui,
                   l_DeviceDatabase);

  dim3 grid(l_databaseRowSize_ui, l_databaseColumnSize_ui);
  searcData<<<grid, 1>>>(thrust::raw_pointer_cast(l_DeviceDatabase.data()),
                         thrust::raw_pointer_cast(l_DeviceResult.data()),
                         l_databaseRowSize_ui, l_databaseColumnSize_ui, 2010);
  cudaDeviceSynchronize();

  l_foundedResult = l_DeviceResult;

  for (int x = 0; x < l_databaseRowSize_ui; x++) {
    for (int y = 0; y < l_databaseColumnSize_ui; y++) {
      printf("Result %lu ", l_foundedResult[(x * l_databaseColumnSize_ui) + y]);
    }
    printf("\n");
  }
}

void CudaSelect::or_method(
    thrust::device_vector<long int> *f_collectDataVector_p,
    thrust::device_vector<long int> &f_OR_collectDataVector_r) {}

void CudaSelect::and_method(
    thrust::device_vector<long int> *f_collectDataVector_p,
    const thrust::device_vector<long int> &f_OR_collectDataVector_r,
    thrust::device_vector<long int> &f_AND_collectDataVector_r,
    thrust::device_vector<long int> &f_workDataVector) {}

void CudaSelect::or_and_merge(
    const thrust::device_vector<long int> *f_collectDataVector_p,
    const thrust::device_vector<long int> &f_OR_collectDataVector_r,
    thrust::device_vector<long int> &f_AND_collectDataVector_r) {}

void CudaSelect::equal(int input, string f_SelectRule_str,
                       const thrust::device_vector<long int> &dataBase_r,
                       thrust::device_vector<long int> *f_collectDataVector_p,
                       thrust::device_vector<long int> &f_workDataVector,
                       bool &firstRun, unsigned int f_columnNumber_ui) {}
//-----------------------------------------------------

void testVector() {

  // https://www.geeksforgeeks.org/convert-string-char-array-cpp/
  printf("TestFunction");
  thrust::host_vector<char *> host_vector;
  vector<string> simple_vector;
  vector<char *> simple_result_vector;
  thrust::device_vector<char *> device_vector;

  simple_vector.push_back("Hello");
  simple_vector.push_back("vilag");
  simple_vector.push_back("Szia");

  for (int i = 0; i < simple_vector.size(); i++) {
    // char* s = (char*)"Hello";
    // device_vector.push_back(s);

    std::string str = simple_vector.at(i);
    char *s = const_cast<char *>(str.c_str());
    // strcpy
    host_vector.push_back(s);

    // simple_result_vector.at(i) = device_vector[i];
    // host_vector = device_vector;
  }

  device_vector = host_vector;

  cout << "host_v " << (simple_vector[0]) << endl;
  cout << "host_v " << (host_vector[0]) << endl;
  cout << "host_v " << (device_vector[0]) << endl;

  cout << "host_v " << &(simple_vector[0]) << endl;
  cout << "host_v " << &(host_vector[0]) << endl;
  cout << "host_v " << &(device_vector[0]) << endl;
}

// example so test--------------------
__global__ void addKernel(int *c, const int *a, const int *b, int size) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < size) {
    c[i] = a[i] + b[i];
  }
}

void addWithCuda(int *c, const int *a, const int *b, int size) {
  int *dev_a = nullptr;
  int *dev_b = nullptr;
  int *dev_c = nullptr;

  // Allocate GPU buffers for three vectors (two input, one output)
  cudaMalloc((void **)&dev_c, size * sizeof(int));
  cudaMalloc((void **)&dev_a, size * sizeof(int));
  cudaMalloc((void **)&dev_b, size * sizeof(int));

  // Copy input vectors from host memory to GPU buffers.
  cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);

  // Launch a kernel on the GPU with one thread for each element.
  // 2 is number of computational blocks and (size + 1) / 2 is a number of
  // threads in a block
  addKernel<<<2, (size + 1) / 2>>>(dev_c, dev_a, dev_b, size);

  // cudaDeviceSynchronize waits for the kernel to finish, and returns
  // any errors encountered during the launch.
  cudaDeviceSynchronize();

  // Copy output vector from GPU buffer to host memory.
  cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);

  cudaFree(dev_c);
  cudaFree(dev_a);
  cudaFree(dev_b);
}

void callExample(int a[5], int b[5], int c[5]) {
  // const int a[5] = {  1,  2,  3,  4,  5 };
  // const int b[5] = { 10, 20, 30, 40, 50 };
  // int c[5] = { 0 };

  addWithCuda(c, a, b, 5);

  cudaDeviceReset();
}
//------------------------------------------
void testCuda(void) {
  // test_kernel <<<1, 1>>> ();
  printf("Hello, world!");
  work();
}
//-----------------
/*
/**
 * CUDA kernel that computes reciprocal values for a given vector
 */
__global__ void reciprocalKernel(float *data, unsigned vectorSize) {
  unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < vectorSize)
    data[idx] = 1.0 / data[idx];
}

/**
 * Host function that copies the data and launches the work on GPU
 */
float *gpuReciprocal(float *data, unsigned size) {
  float *rc = new float[size];
  float *gpuData;

  CUDA_CHECK_RETURN(cudaMalloc((void **)&gpuData, sizeof(float) * size));
  CUDA_CHECK_RETURN(
      cudaMemcpy(gpuData, data, sizeof(float) * size, cudaMemcpyHostToDevice));

  static const int BLOCK_SIZE = 256;
  const int blockCount = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
  reciprocalKernel<<<blockCount, BLOCK_SIZE>>>(gpuData, size);

  CUDA_CHECK_RETURN(
      cudaMemcpy(rc, gpuData, sizeof(float) * size, cudaMemcpyDeviceToHost));
  CUDA_CHECK_RETURN(cudaFree(gpuData));
  return rc;
}

float *cpuReciprocal(float *data, unsigned size) {
  float *rc = new float[size];
  for (unsigned cnt = 0; cnt < size; ++cnt)
    rc[cnt] = 1.0 / data[cnt];
  return rc;
}

void initialize(float *data, unsigned size) {
  for (unsigned i = 0; i < size; ++i)
    data[i] = .5 * (i + 1);
}

int work(void) {
  static const int WORK_SIZE = 65530;
  float *data = new float[WORK_SIZE];

  initialize(data, WORK_SIZE);

  float *recCpu = cpuReciprocal(data, WORK_SIZE);
  float *recGpu = gpuReciprocal(data, WORK_SIZE);
  float cpuSum = std::accumulate(recCpu, recCpu + WORK_SIZE, 0.0);
  float gpuSum = std::accumulate(recGpu, recGpu + WORK_SIZE, 0.0);

  /* Verify the results */
  std::cout << "gpuSum = " << gpuSum << " cpuSum = " << cpuSum << std::endl;

  /* Free memory */
  delete[] data;
  delete[] recCpu;
  delete[] recGpu;

  return 0;
}

/**
 * Check the return value of the CUDA runtime API call and exit
 * the application if the call has failed.
 */

static void CheckCudaErrorAux(const char *file, unsigned line,
                              const char *statement, cudaError_t err) {
  if (err == cudaSuccess)
    return;
  std::cerr << statement << " returned " << cudaGetErrorString(err) << "("
            << err << ") at " << file << ":" << line << std::endl;
  exit(1);
}
