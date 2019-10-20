
#include "cuda_select.cuh"
#include <vector>
//https://devblogs.nvidia.com/cooperative-groups/
#include <cooperative_groups.h>

//------Real Functions----
namespace CudaVariables{

	thrust::device_vector<long int> *collectDataVector_p(NULL);
	thrust::device_vector<long int> m_workDataVector(4*CudaSelect::m_columnNumber_ui);

	thrust::device_vector<long int> m_AND_collectDataVector(4*CudaSelect::m_columnNumber_ui);
	thrust::device_vector<long int> m_OR_collectDataVector(4*CudaSelect::m_columnNumber_ui);

	thrust::device_vector<long int> foundedResults(4*CudaSelect::m_columnNumber_ui);
}

using namespace CudaVariables;

CudaSelect::CudaSelect(){
	//copyDataToDevice();
}

CudaSelect::~CudaSelect(){

}
//Only for beta
__global__ void searchDataFromDatabase(long int *data, int row, int col) {

	  printf("Element (%d, %d) = %d\n", row, col, data[(row*CudaSelect::m_columnNumber_ui)+col]);

}

/*__global__ void searcData(long int *data,long int *result, const unsigned int f_databaseRowSize_ui,const unsigned int f_databaseColumnSize_ui,const unsigned int f_targetWord_ui) {

	int rowThread = blockIdx.y * blockDim.y + threadIdx.y;
	int columnThread = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int l_tmpStepper_ui = 0;

	for(;rowThread<f_databaseRowSize_ui;rowThread++){
		printf("Element (%d, %d) = %d\n", rowThread, columnThread, data[(rowThread*CudaSelect::m_columnNumber_ui)+columnThread]);
		long int temp = data[(rowThread*f_databaseColumnSize_ui)+columnThread];
		if(temp == f_targetWord_ui)
		{
			printf("found\n");
			for(int l_it_x=0;l_it_x<=3;l_it_x++)
			{
				long int asd = data[(rowThread*f_databaseColumnSize_ui)+l_it_x];
				result[(l_tmpStepper_ui*CudaSelect::m_columnNumber_ui)+l_it_x] = asd;
				//tmp[tmp_stepper][i]= asd;
				//printf("Array %d ", tmp[tmp_stepper][i]);
				printf("Array %d \n", result[(l_tmpStepper_ui*CudaSelect::m_columnNumber_ui)+l_it_x]);
			}
			l_tmpStepper_ui = atomicAdd(&l_tmpStepper_ui,1);
		}
	}
}*/

//Only for beta
void CudaSelect::copyDataToDevice()
{
	int H = 2;
	int W = CudaSelect::m_columnNumber_ui;
    int h[H][W];

    h[0][0] = 111;
    h[0][1] = 112;
    h[0][2] = 113;

    h[1][0] = 222;
    h[1][1] = 223;
    h[1][2] = 224;

    thrust::device_vector<long int> d(H*W);

    thrust::copy(&(h[0][0]), &(h[H-1][W-1]), d.begin());
    //thrust::sequence(d.begin(), d.end());
    searchDataFromDatabase<<<3,1>>>(thrust::raw_pointer_cast(d.data()), 1, 0);
    cudaDeviceSynchronize();
}
/*
void CudaSelect::copyDataToDevice(const vector<vector<long int>> &f_dataBase_r,unsigned int f_databaseHeaderColumnSize_ui)
{
	unsigned int targetInfo = 2009;
	unsigned int l_databaseRowSize_ui = f_dataBase_r.size();
	unsigned int l_databaseColumnSize_ui = f_databaseHeaderColumnSize_ui;
    int l_tmpDatabaseContainer_i[l_databaseRowSize_ui][l_databaseColumnSize_ui];

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

    thrust::device_vector<long int> databaseOnCuda(l_databaseRowSize_ui*l_databaseColumnSize_ui);
    thrust::copy(&(l_tmpDatabaseContainer_i[0][0]), &(l_tmpDatabaseContainer_i[l_databaseRowSize_ui-1][l_databaseColumnSize_ui-1]), databaseOnCuda.begin());

    thrust::device_vector<long int> resultDatabaseOnCuda(l_databaseRowSize_ui*l_databaseColumnSize_ui);
    searcData<<<4,1>>>(thrust::raw_pointer_cast(databaseOnCuda.data()),thrust::raw_pointer_cast(resultDatabaseOnCuda.data()),l_databaseRowSize_ui,l_databaseColumnSize_ui,targetInfo);
    cudaDeviceSynchronize();

    thrust::host_vector<long int> l_foundedResult(l_databaseRowSize_ui*l_databaseColumnSize_ui);
    l_foundedResult = resultDatabaseOnCuda;

    for(int x =0; x< l_databaseRowSize_ui;x++)
    {
    	for(int y = 0; y<l_databaseColumnSize_ui;y++)
    	{
    		printf("Array %lu ", l_foundedResult[(x*CudaSelect::m_columnNumber_ui)+y]);
    	}
    }

}*/

/*void CudaSelect::copyDataToDevice(const vector<vector<long int>> &f_dataBase_r,unsigned int f_databaseHeaderColumnSize_ui)
{
	unsigned int targetInfo = 2009;
	unsigned int l_databaseRowSize_ui = f_dataBase_r.size();
	unsigned int l_databaseColumnSize_ui = f_databaseHeaderColumnSize_ui;
    int l_tmpDatabaseContainer_i[l_databaseRowSize_ui][l_databaseColumnSize_ui];

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

    thrust::device_vector<long int> databaseOnCuda(l_databaseRowSize_ui*l_databaseColumnSize_ui);
    thrust::copy(&(l_tmpDatabaseContainer_i[0][0]), &(l_tmpDatabaseContainer_i[l_databaseRowSize_ui-1][l_databaseColumnSize_ui-1]), databaseOnCuda.begin());

    thrust::device_vector<long int> resultDatabaseOnCuda(l_databaseRowSize_ui*l_databaseColumnSize_ui);
    searcData<<<4,1>>>(thrust::raw_pointer_cast(databaseOnCuda.data()),thrust::raw_pointer_cast(resultDatabaseOnCuda.data()),l_databaseRowSize_ui,l_databaseColumnSize_ui,targetInfo);
    cudaDeviceSynchronize();

    thrust::host_vector<long int> l_foundedResult(l_databaseRowSize_ui*l_databaseColumnSize_ui);
    l_foundedResult = resultDatabaseOnCuda;

    for(int x =0; x< l_databaseRowSize_ui;x++)
    {
    	for(int y = 0; y<l_databaseColumnSize_ui;y++)
    	{
    		printf("Array %lu ", l_foundedResult[(x*CudaSelect::m_columnNumber_ui)+y]);
    	}
    }

}*/
//http://selkie.macalester.edu/csinparallel/modules/ConceptDataDecomposition/build/html/Decomposition/CUDA_VecAdd.html
/*__global__ void searcData(long int *f_dataBase_p,long int *f_resultLines_p, const unsigned int f_databaseRowSize_ui,const unsigned int f_databaseColumnSize_ui,const unsigned int f_targetWord_ui) {

	int rowThread = blockIdx.y * blockDim.y + threadIdx.y;
	int columnThread = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int l_tmpStepper_ui = 0;

	printf("I am the %i %i threadPair\n",rowThread,columnThread);

	for(;rowThread<f_databaseRowSize_ui;rowThread++){
	//if(rowThread<f_databaseRowSize_ui){
		//printf("Element (%d, %d) = %d\n", rowThread, columnThread, f_dataBase_p[(rowThread*f_databaseColumnSize_ui)+columnThread]);
		long int temp = f_dataBase_p[(rowThread*f_databaseColumnSize_ui)+columnThread];
		if(temp == f_targetWord_ui)
		{
			printf("Founded threadPair: %i %i\n",rowThread,columnThread);
			for(int l_it_x=0;l_it_x<f_databaseColumnSize_ui;l_it_x++)
			{
				long int l_dataBaseFoundedLineContent_li = f_dataBase_p[(rowThread*f_databaseColumnSize_ui)+l_it_x];
				f_resultLines_p[(l_tmpStepper_ui*f_databaseColumnSize_ui)+l_it_x] = l_dataBaseFoundedLineContent_li;
				printf("Array %d \n", f_resultLines_p[(l_tmpStepper_ui*f_databaseColumnSize_ui)+l_it_x]);
			}
			//l_tmpStepper_ui = atomicAdd(&l_tmpStepper_ui,1);
		}
	}
}*/
__device__  int stepper = 0;
__global__ void searcData(long int *f_dataBase_p,long int *f_resultLines_p, const unsigned int f_databaseRowSize_ui,const unsigned int f_databaseColumnSize_ui,const unsigned int f_targetWord_ui) {


	int rowThread = blockIdx.x * blockDim.x + threadIdx.x;
	int columnThread = blockIdx.y * blockDim.y + threadIdx.y;

	long int temp = f_dataBase_p[(rowThread*f_databaseColumnSize_ui)+columnThread];
	if(temp == f_targetWord_ui)
	{
		//printf("Founded threadPair: %i %i\n",rowThread,columnThread);
		for(int l_it_x=0;l_it_x<f_databaseColumnSize_ui;l_it_x++)
		{
			long int l_dataBaseFoundedLineContent_li = f_dataBase_p[(rowThread*f_databaseColumnSize_ui)+l_it_x];
			f_resultLines_p[l_it_x+stepper] = l_dataBaseFoundedLineContent_li;
			//printf("Array %d \n", f_resultLines_p[(f_databaseColumnSize_ui)+l_it_x]);
		}
		atomicAdd(&stepper,f_databaseColumnSize_ui);

	}

	auto syncGroup = cooperative_groups::this_thread_block();
	syncGroup.sync();
	//__syncthreads();
}

void CudaSelect::copyDataToDevice(const vector<vector<long int>> &f_dataBase_r,const unsigned int f_databaseRowSize_ui,unsigned int f_databaseColumnSize_ui,thrust::device_vector<long int> &f_DeviceDataBase_r)
{
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

	//What??
    thrust::copy(&(l_tmpDatabaseContainer_i[0][0]), &(l_tmpDatabaseContainer_i[f_databaseRowSize_ui][f_databaseColumnSize_ui]), f_DeviceDataBase_r.begin());

}

void CudaSelect::CudaRun(const vector<string> &f_selectRule,const vector<vector<long int>> &f_dataBase_r,const vector<string> &f_dataBaseHeader_v){

	unsigned int l_databaseRowSize_ui = f_dataBase_r.size();
	//printf("%i\n",l_databaseRowSize_ui);
	unsigned int l_databaseColumnSize_ui = f_dataBaseHeader_v.size();
	//printf("%i\n",l_databaseColumnSize_ui);


	//thrust::device_vector<long int> *l_collectDataVector_p(NULL);
	//thrust::device_vector<long int> l_workDataVector(l_databaseRowSize_ui*l_databaseColumnSize_ui);

	//thrust::device_vector<long int> l_AND_collectDataVector(l_databaseRowSize_ui*l_databaseColumnSize_ui);
	//thrust::device_vector<long int> l_OR_collectDataVector(l_databaseRowSize_ui*l_databaseColumnSize_ui);

	thrust::device_vector<long int> l_DeviceDatabase(l_databaseRowSize_ui*l_databaseColumnSize_ui);
	thrust::device_vector<long int> l_DeviceResult(l_databaseRowSize_ui*l_databaseColumnSize_ui);
	thrust::host_vector<long int> l_foundedResult(l_databaseRowSize_ui*l_databaseColumnSize_ui);

	copyDataToDevice(f_dataBase_r,l_databaseRowSize_ui,l_databaseColumnSize_ui,l_DeviceDatabase);

	dim3 grid(l_databaseRowSize_ui,l_databaseColumnSize_ui);
	searcData<<<grid,1>>>(thrust::raw_pointer_cast(l_DeviceDatabase.data()),thrust::raw_pointer_cast(l_DeviceResult.data()),l_databaseRowSize_ui,l_databaseColumnSize_ui,2010);
    cudaDeviceSynchronize();

    l_foundedResult = l_DeviceResult;

    for(int x =0;x<l_databaseRowSize_ui;x++)
    {
    	for(int y = 0;y< l_databaseColumnSize_ui;y++)
    	{
    		printf("Result %lu ", l_foundedResult[(x*l_databaseColumnSize_ui)+y]);
    	}
    	printf("\n");
    }
	 /*int input; // Todo destroy it...

	  for (string l_rule_str : f_selectRule) {
	    input = l_rule_str.find("&");
	    if (input != (-1)) {

	      //and_method(collectDataVector_p, m_OR_collectDataVector,
	                 //m_AND_collectDataVector, m_workDataVector);
	      continue;
	    }

	    input = l_rule_str.find("|");
	    if (input != (-1)) {
	      //or_method(collectDataVector_p, m_OR_collectDataVector);
	      continue;
	    }

	    /// first will be find date="2010"
	    input = l_rule_str.find("=");
	    if (input != (-1)) {
	      //equal(input, l_rule_str, l_dataBase_r, collectDataVector_p,
	            //m_workDataVector, firstRun);

	      continue;
	    }

	    //or_and_merge(collectDataVector_p, m_OR_collectDataVector,
	                 //m_AND_collectDataVector);
	  }*/
}

void CudaSelect::or_method(thrust::device_vector<long int> *f_collectDataVector_p, thrust::device_vector<long int> &f_OR_collectDataVector_r) {
  /// put collectDataVector_p contain to l_OR_collectDataVector_r by indirect
  f_collectDataVector_p = &f_OR_collectDataVector_r;
  f_collectDataVector_p->clear();
}

void CudaSelect::and_method(thrust::device_vector<long int> *f_collectDataVector_p,const thrust::device_vector<long int> &f_OR_collectDataVector_r,thrust::device_vector<long int> &f_AND_collectDataVector_r,thrust::device_vector<long int> &f_workDataVector) {

  or_and_merge(f_collectDataVector_p, f_OR_collectDataVector_r,
               f_AND_collectDataVector_r);

  /// put collectDataVector_p contain to AND_collectDataVector_r by indirect
  f_collectDataVector_p = &f_AND_collectDataVector_r;

  f_workDataVector.clear();
  /// put the AND_collectDataVector_r contains to l_workDataVector by directly
  f_workDataVector = f_AND_collectDataVector_r;
  f_collectDataVector_p->clear();
}

void CudaSelect::or_and_merge(
    const thrust::device_vector<long int> *f_collectDataVector_p,
    const thrust::device_vector<long int> &f_OR_collectDataVector_r,
    thrust::device_vector<long int> &f_AND_collectDataVector_r) {
  /// if the collectDataVector_p point to the OR_collectDataVector_r copy the
  /// OR_collectDataVector_r contain to AND_collectDataVector_r
  if ((void *)f_collectDataVector_p == &f_OR_collectDataVector_r) {
    f_AND_collectDataVector_r.insert(f_AND_collectDataVector_r.end(),
                                     f_OR_collectDataVector_r.begin(),
                                     f_OR_collectDataVector_r.end());
  }
}

void CudaSelect::equal(int input, string f_SelectRule_str,
                   const thrust::device_vector<long int> &dataBase_r,
                   thrust::device_vector<long int> *f_collectDataVector_p,
                   thrust::device_vector<long int> &f_workDataVector, bool &firstRun, unsigned int f_columnNumber_ui) {
/*
	/// date="2010"
  unsigned int l_columnNumber_ui = f_columnNumber_ui;
  /// cut "=2010" part
  string column = f_SelectRule_str.substr(0, input);
  /// cut "date=" part
  string tmp_row = f_SelectRule_str.substr(input + 1, f_SelectRule_str.size());
  long int row = std::stol(tmp_row);


  if (firstRun == true) {
    /// if first time run the query, search the lines from original database
    /// else we search from workDataVector
    for (unsigned int l_it_x = 0; l_it_x < dataBase_r.size(); l_it_x++) {
      long int word = dataBase_r.at(l_it_x).at(l_columnNumber_ui);
      if (word == row) {
        // if find the line which include "2010" value put to
        // collectDataVector_p
        f_collectDataVector_p->push_back(dataBase_r.at(l_it_x));
      }
    }
    firstRun = false;
  }

  else {
    for (unsigned int l_it_x = 0; l_it_x < f_workDataVector.size(); l_it_x++) {
      long int word = f_workDataVector.at(l_it_x).at(l_columnNumber_ui);
      if (word == row) {
        f_collectDataVector_p->push_back(f_workDataVector.at(l_it_x));
      }
    }
  }*/
}
//------------------------

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

void parallelANDmethod(vector<vector<long int>> *f_collectDataVector_p,
                       const vector<vector<long int>> &f_OR_collectDataVector_r,
                       vector<vector<long int>> &f_AND_collectDataVector_r,
                       vector<vector<long int>> &f_workDataVector) {

  /*// thrust::device_vector<thrust::device_vector<string>> a;

  thrust::host_vector<char *> host_vector;
  std::vector<char *> data;
  vector<string> simple_vector;
  vector<char *> simple_result_vector;
  thrust::device_vector<char *> device_vector;

  thrust::device_vector<string> asd;
  thrust::host_vector<string> bsd;

  for (int i = 0; i <= simple_vector.size(); i++) {
    // char* s = (char*)"Hello";
    // device_vector.push_back(s);

    std::string str = simple_vector.at(i);
    char *s = const_cast<char *>(str.c_str());
    device_vector.push_back(s);

    simple_result_vector.at(i) = device_vector[i];
    host_vector = device_vector;
  }*/
}

void parallelORandMerge(const vector<vector<string>> *f_collectDataVector_p,
                        const vector<vector<string>> &f_OR_collectDataVector_r,
                        vector<vector<string>> &f_AND_collectDataVector_r) {}

void CopySelectRuleToDevice(vector<string> f_selectRule_v) {

  std::vector<const char *> l_selectRule_cv(f_selectRule_v.size(), nullptr);
  for (int i = 0; i < f_selectRule_v.size(); i++) {
    l_selectRule_cv[i] = f_selectRule_v[i].c_str();
  }

  thrust::host_vector<const char *> h_selectRule_cv = l_selectRule_cv;
  thrust::device_vector<const char *> d_selectRule_cv = h_selectRule_cv;
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
