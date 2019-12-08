#include "cuda_select.cuh"
#include <cooperative_groups.h>
#include <vector>

CudaSelect::CudaSelect() {

  m_firstMethodWasOr_b = true;
  m_firstRun_b = true;
  m_RunTimeMilliseconds_f = 0.0;
  m_searchRunTime_f = 0.0;

  m_necessaryBlockNumber_ui = 0;
  m_necessaryThreadNumber_ui = 0;

  m_resultDatabase_v.clear();
}

CudaSelect::~CudaSelect() {}

__global__ void searcData(long int *f_dataBase_p, long int *f_resultLines_p,
                          const unsigned long int f_databaseRowSize_ui,
                          const unsigned long int f_databaseColumnSize_ui,
                          const unsigned long int f_targetWord_ui) {

  unsigned long int rowThread = blockIdx.x * blockDim.x + threadIdx.x;
  unsigned long int columnThread = blockIdx.y * blockDim.y + threadIdx.y;

  if ((rowThread <= f_databaseRowSize_ui) &&
      (columnThread <= f_databaseColumnSize_ui)) {

    long int l_tmpWordContainer_li =
        f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + columnThread];

    if (l_tmpWordContainer_li == f_targetWord_ui) {

      for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {

        long int l_dataBaseFoundedLineContent_li =
            f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];

        f_resultLines_p[l_it_x + (rowThread * f_databaseColumnSize_ui)] =
            l_dataBaseFoundedLineContent_li;
      }
    }
  }
  // auto syncOnlyThreads= cooperative_groups::this_thread();
  // auto syncGroup = cooperative_groups::this_thread_block();
  // syncGroup.sync();
  // syncOnlyThreads.sync();
  __syncthreads();
}

__global__ void searcDataInColumn(long int *f_dataBase_p,
                                  long int *f_resultLines_p,
                                  const unsigned int f_databaseRowSize_ui,
                                  const unsigned int f_databaseColumnSize_ui,
                                  const long int f_targetWord_ui,
                                  const unsigned long int f_targetColumn) {

  int rowThread = blockIdx.x * blockDim.x + threadIdx.x;

  if (rowThread <= f_databaseRowSize_ui) {
    long int l_tmpWordContainer_li =
        f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + f_targetColumn];

    if (l_tmpWordContainer_li == f_targetWord_ui) {

      for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {

        long int l_dataBaseFoundedLineContent_li =
            f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];
        f_resultLines_p[l_it_x + (rowThread * f_databaseColumnSize_ui)] =
            l_dataBaseFoundedLineContent_li;
      }
    }
  }
  // auto syncOnlyThreads= cooperative_groups::this_thread();
  // auto syncGroup = cooperative_groups::this_thread_block();
  // syncGroup.sync();
  // syncOnlyThreads.sync();
  __syncthreads();
}

__global__ void
searcDataLessInColumn(long int *f_dataBase_p, long int *f_resultLines_p,
                      const unsigned int f_databaseRowSize_ui,
                      const unsigned int f_databaseColumnSize_ui,
                      const long int f_targetWord_ui,
                      const unsigned long int f_targetColumn) {

  int rowThread = blockIdx.x * blockDim.x + threadIdx.x;

  if (rowThread <= f_databaseRowSize_ui) {
    long int l_tmpWordContainer_li =
        f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + f_targetColumn];

    if (l_tmpWordContainer_li < f_targetWord_ui) {

      for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {

        long int l_dataBaseFoundedLineContent_li =
            f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];
        f_resultLines_p[l_it_x + (rowThread * f_databaseColumnSize_ui)] =
            l_dataBaseFoundedLineContent_li;
      }
    }
  }
  // auto syncOnlyThreads= cooperative_groups::this_thread();
  // auto syncGroup = cooperative_groups::this_thread_block();
  // syncGroup.sync();
  // syncOnlyThreads.sync();
  __syncthreads();
}

__global__ void
searcDataGreaterInColumn(long int *f_dataBase_p, long int *f_resultLines_p,
                         const unsigned int f_databaseRowSize_ui,
                         const unsigned int f_databaseColumnSize_ui,
                         const long int f_targetWord_ui,
                         const unsigned long int f_targetColumn) {

  int rowThread = blockIdx.x * blockDim.x + threadIdx.x;

  if (rowThread <= f_databaseRowSize_ui) {
    long int l_tmpWordContainer_li =
        f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + f_targetColumn];

    if (l_tmpWordContainer_li > f_targetWord_ui) {

      for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {

        long int l_dataBaseFoundedLineContent_li =
            f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];
        f_resultLines_p[l_it_x + (rowThread * f_databaseColumnSize_ui)] =
            l_dataBaseFoundedLineContent_li;
      }
    }
  }
  // auto syncOnlyThreads= cooperative_groups::this_thread();
  // auto syncGroup = cooperative_groups::this_thread_block();
  // syncGroup.sync();
  // syncOnlyThreads.sync();
  __syncthreads();
}

void CudaSelect::copyDataToDevice(
    const vector<vector<long int>> &f_dataBase_r,
    const unsigned long int f_databaseRowSize_ui,
    unsigned long int f_databaseColumnSize_ui,
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

  // ToDo! What??
  thrust::copy(&(l_tmpDatabaseContainer_i[0][0]),
               &(l_tmpDatabaseContainer_i[f_databaseRowSize_ui]
                                         [f_databaseColumnSize_ui]),
               f_DeviceDataBase_r.begin());
}

void CudaSelect::copyDataFromDevice(
    const unsigned long int f_databaseRowSize_ui,
    const unsigned long int f_databaseColumnSize_ui,
    const thrust::host_vector<long int> &f_resultVector) {

  vector<long int> l_tmpDatabaseContainer_v;
  for (int x = 0; x < f_databaseRowSize_ui; x++) {

    l_tmpDatabaseContainer_v.clear();
    for (int y = 0; y < f_databaseColumnSize_ui; y++) {
      long int l_tmpVectorValue =
          f_resultVector[(x * f_databaseColumnSize_ui) + y];

      l_tmpDatabaseContainer_v.push_back(l_tmpVectorValue);
    }
    m_resultDatabase_v.push_back(l_tmpDatabaseContainer_v);
  }
}

void CudaSelect::CudaRun(const vector<string> &f_selectRule,
                         const vector<vector<long int>> &f_dataBase_r,
                         const vector<string> &f_dataBaseHeader_v) {

  unsigned long int l_databaseRowSize_ui = f_dataBase_r.size();
  unsigned long int l_databaseColumnSize_ui = f_dataBaseHeader_v.size();

  calculateGridBalanceMethod(m_necessaryBlockNumber_ui,
                             m_necessaryThreadNumber_ui, l_databaseRowSize_ui);

  thrust::device_vector<long int> l_workDataVector(l_databaseRowSize_ui *
                                                   l_databaseColumnSize_ui);

  thrust::device_vector<long int> l_collectDataVector_v(
      l_databaseRowSize_ui * l_databaseColumnSize_ui);

  thrust::device_vector<long int> l_DeviceDatabase(l_databaseRowSize_ui *
                                                   l_databaseColumnSize_ui);

  // ToDo: Rename it for host_Copy.......
  thrust::host_vector<long int> l_foundedResult(l_databaseRowSize_ui *
                                                l_databaseColumnSize_ui);

  copyDataToDevice(f_dataBase_r, l_databaseRowSize_ui, l_databaseColumnSize_ui,
                   l_DeviceDatabase);

  //---------------------R-U-N----------------------
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaEventRecord(start);

  m_firstRun_b = true;
  m_firstMethodWasOr_b = true;

  int whereIsTheTargetCharacter;

  for (string l_rule_str : f_selectRule) {
    whereIsTheTargetCharacter = l_rule_str.find("&");
    if (whereIsTheTargetCharacter != (-1)) {

      and_method(l_collectDataVector_v, l_workDataVector, l_databaseRowSize_ui,
                 l_databaseColumnSize_ui);

      if (m_firstMethodWasOr_b)
        m_firstMethodWasOr_b = false;

      continue;
    }

    whereIsTheTargetCharacter = l_rule_str.find("|");
    if (whereIsTheTargetCharacter != (-1)) {

      continue;
    }

    /// first will be find date="2010"
    whereIsTheTargetCharacter = l_rule_str.find("=");
    if (whereIsTheTargetCharacter != (-1)) {
      find(whereIsTheTargetCharacter, l_rule_str, l_DeviceDatabase,
           f_dataBaseHeader_v, l_collectDataVector_v, l_workDataVector,
           l_databaseRowSize_ui, l_databaseColumnSize_ui, "=");

      continue;
    }

    whereIsTheTargetCharacter = l_rule_str.find("<");
    if (whereIsTheTargetCharacter != (-1)) {
      find(whereIsTheTargetCharacter, l_rule_str, l_DeviceDatabase,
           f_dataBaseHeader_v, l_collectDataVector_v, l_workDataVector,
           l_databaseRowSize_ui, l_databaseColumnSize_ui, "<");

      continue;
    }

    whereIsTheTargetCharacter = l_rule_str.find(">");
    if (whereIsTheTargetCharacter != (-1)) {
      find(whereIsTheTargetCharacter, l_rule_str, l_DeviceDatabase,
           f_dataBaseHeader_v, l_collectDataVector_v, l_workDataVector,
           l_databaseRowSize_ui, l_databaseColumnSize_ui, ">");

      continue;
    }
  }

  l_foundedResult = l_collectDataVector_v;

  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&m_RunTimeMilliseconds_f, start, stop);

  /*//Only l_foundedResult value Debug:
   for (int x = 0; x < l_databaseRowSize_ui; x++) {
     for (int y = 0; y < l_databaseColumnSize_ui; y++) {
       printf("cuda %lu ", l_foundedResult[(x * l_databaseColumnSize_ui) + y]);
     }
     printf("\n");
   }*/

  copyDataFromDevice(l_databaseRowSize_ui, l_databaseColumnSize_ui,
                     l_foundedResult);
}

void CudaSelect::and_method(
    thrust::device_vector<long int> &f_collectDataVector_r,
    thrust::device_vector<long int> &f_workDataVector,
    unsigned long int f_rowNumber_ui, unsigned long int f_columnNumber_ui) {

  thrust::host_vector<long int> nullInitVector(
      f_rowNumber_ui * f_columnNumber_ui); // by default Null vector
  f_workDataVector = nullInitVector;

  /// f_collectDataVector_p point to f_collectDataVector_r !!!!!!!!!!!
  /// put the AND_collectDataVector_r contains to l_workDataVector by directly
  f_workDataVector = f_collectDataVector_r;

  // similar to f_collectDataVector_p->clear();
  f_collectDataVector_r = nullInitVector;
}

void CudaSelect::find(int whereIsTheTargetCharacter, string f_SelectRule_str,
                      thrust::device_vector<long int> &dataBase_r,
                      const vector<string> &f_dataBaseHeader_v,
                      thrust::device_vector<long int> &f_collectDataVector_r,
                      thrust::device_vector<long int> &f_workDataVector,
                      unsigned long int f_rowNumber_ui,
                      unsigned long int f_columnNumber_ui,
                      string f_mathRule_str) {

  /// date="2010"
  unsigned int l_targetColumnNumber_ui = 0;
  /// cut "=2010" part
  string column = f_SelectRule_str.substr(0, whereIsTheTargetCharacter);
  /// cut "date=" part
  string tmp_row = f_SelectRule_str.substr(whereIsTheTargetCharacter + 1,
                                           f_SelectRule_str.size());
  long int row = std::stol(tmp_row);

  /// find "date" number of column //PC side
  for (unsigned int l_it_y = 0; l_it_y < f_dataBaseHeader_v.size();
       l_it_y++) // Todo optimalize to parallel search!!
  {
    string l_column = f_dataBaseHeader_v.at(l_it_y);
    if (l_column == column) {
      l_targetColumnNumber_ui = l_it_y;
    }
  }

  if ((m_firstRun_b == true) || (m_firstMethodWasOr_b == true)) {
    /// if first time run the query, search the lines from original database
    /// else we search from workDataVector

    dim3 necessaryBlockSize(m_necessaryBlockNumber_ui);
    dim3 necessaryThreadSize(m_necessaryThreadNumber_ui);

    if (f_mathRule_str == "=") {

      cudaEvent_t start, stop;
      cudaEventCreate(&start);
      cudaEventCreate(&stop);

      cudaEventRecord(start);

      searcDataInColumn<<<necessaryBlockSize, necessaryThreadSize>>>(
          thrust::raw_pointer_cast(dataBase_r.data()),
          thrust::raw_pointer_cast(f_collectDataVector_r.data()),
          f_rowNumber_ui, f_columnNumber_ui, row, l_targetColumnNumber_ui);

      cudaEventRecord(stop);
      cudaEventSynchronize(stop);
      float l_searchTime;
      cudaEventElapsedTime(&l_searchTime, start, stop);

      m_searchRunTime_f += l_searchTime;

    }

    else if (f_mathRule_str == "<") {
      searcDataLessInColumn<<<necessaryBlockSize, necessaryThreadSize>>>(
          thrust::raw_pointer_cast(dataBase_r.data()),
          thrust::raw_pointer_cast(f_collectDataVector_r.data()),
          f_rowNumber_ui, f_columnNumber_ui, row, l_targetColumnNumber_ui);
    }

    else if (f_mathRule_str == ">") {
      searcDataGreaterInColumn<<<necessaryBlockSize, necessaryThreadSize>>>(
          thrust::raw_pointer_cast(dataBase_r.data()),
          thrust::raw_pointer_cast(f_collectDataVector_r.data()),
          f_rowNumber_ui, f_columnNumber_ui, row, l_targetColumnNumber_ui);
    }

    // Debug point
    /*thrust::host_vector<long int> l_foundedResult(3 * 4);
    l_foundedResult= *f_collectDataVector_p;

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 4; y++) {
        printf("result %lu ", l_foundedResult[(x * 4) + y]);
      }
      printf("\n");
    }*/

    cudaDeviceSynchronize();
    m_firstRun_b = false;

  }

  else {

    dim3 necessaryBlockSize(m_necessaryBlockNumber_ui);
    dim3 necessaryThreadSize(m_necessaryThreadNumber_ui);

    if (f_mathRule_str == "=") {

      cudaEvent_t start, stop;
      cudaEventCreate(&start);
      cudaEventCreate(&stop);

      cudaEventRecord(start);

      searcDataInColumn<<<necessaryBlockSize, necessaryThreadSize>>>(
          thrust::raw_pointer_cast(f_workDataVector.data()),
          thrust::raw_pointer_cast(f_collectDataVector_r.data()),
          f_rowNumber_ui, f_columnNumber_ui, row, l_targetColumnNumber_ui);

      cudaEventRecord(stop);
      cudaEventSynchronize(stop);
      float l_searchTime;
      cudaEventElapsedTime(&l_searchTime, start, stop);

      m_searchRunTime_f += l_searchTime;

    }

    else if (f_mathRule_str == "<") {
      searcDataLessInColumn<<<necessaryBlockSize, necessaryThreadSize>>>(
          thrust::raw_pointer_cast(f_workDataVector.data()),
          thrust::raw_pointer_cast(f_collectDataVector_r.data()),
          f_rowNumber_ui, f_columnNumber_ui, row, l_targetColumnNumber_ui);
    }

    else if (f_mathRule_str == ">") {
      searcDataGreaterInColumn<<<necessaryBlockSize, necessaryThreadSize>>>(
          thrust::raw_pointer_cast(f_workDataVector.data()),
          thrust::raw_pointer_cast(f_collectDataVector_r.data()),
          f_rowNumber_ui, f_columnNumber_ui, row, l_targetColumnNumber_ui);
    }

    cudaDeviceSynchronize();
  }
}

void CudaSelect::calculateGridFillMethod(
    unsigned long int &f_necessaryBlockNumber_r,
    unsigned long int &f_necessaryThreadNumber_r,
    const unsigned long int f_rowNumber_ui) {

  f_necessaryBlockNumber_r = f_rowNumber_ui / 500;

  if (f_necessaryBlockNumber_r <= 0) {
    f_necessaryBlockNumber_r = 1;
    f_necessaryThreadNumber_r = f_rowNumber_ui;
  }

  else {
    // maximum Thread/block
    f_necessaryThreadNumber_r = 500;
  }
}

void CudaSelect::calculateGridBalanceMethod(
    unsigned long int &f_necessaryBlockNumber_r,
    unsigned long int &f_necessaryThreadNumber_r,
    const unsigned long int f_rowNumber_ui) {

  // maximum 500 thread/block
  f_necessaryBlockNumber_r = f_rowNumber_ui / 500;

  if (f_necessaryBlockNumber_r <= 0) {
    f_necessaryBlockNumber_r = 1;
    f_necessaryThreadNumber_r = f_rowNumber_ui;
  }

  else {
    unsigned long int l_remainder_ui =
        f_rowNumber_ui % f_necessaryBlockNumber_r;
    if (l_remainder_ui == 0) {
      f_necessaryThreadNumber_r = f_rowNumber_ui / f_necessaryBlockNumber_r;
    } else {
      f_necessaryThreadNumber_r =
          (f_rowNumber_ui / f_necessaryBlockNumber_r) + 1;
    }
  }
}

vector<vector<long int>> CudaSelect::getQueryResult() const {

  return m_resultDatabase_v;
}

float CudaSelect::getRuntimeValue() const { return m_RunTimeMilliseconds_f; }

float CudaSelect::getSearchtimeValue() const { return m_searchRunTime_f; }
