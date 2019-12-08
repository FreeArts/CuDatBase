/*
 * select.h
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

#ifndef SELECT_H_
#define SELECT_H_

#include "cuda_select.cuh"

#include <algorithm>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace std;

class SELECT {
public:
  SELECT();
  virtual ~SELECT();

  void loadDatabase(const vector<vector<long int>> &f_dataBase_v,
                    const vector<string> f_headerOfDataBase);

  void showDatabase() const;

  void readSelectRule(vector<string> f_selectRule_v);

  void run();
  vector<vector<long int>> parallelRun();

  vector<vector<long int>> getQueryResult() const;

  string getSWversion();
  float getParallelRuntimeValue() const;
  float getParallelSearchtimeValue() const;

private:
  string m_dataBasePath_str;
  string m_delimeter_str;
  vector<vector<long int>> m_dataList_v;
  vector<string> m_databaseHeader;
  vector<string> m_selectRule_v;

  vector<vector<long int>> m_workDataVector;

  vector<vector<long int>> m_AND_collectDataVector;

  bool m_firstRun_b;
  bool m_firstMethodWasOr_b;

  void and_method(vector<vector<long int>> &f_AND_collectDataVector_r,
                  vector<vector<long int>> &f_workDataVector);

  void equal(int whereIsTheTargetCharacter, string f_SelectRule_str,
             const vector<vector<long int>> &dataBase_r,
             vector<vector<long int>> &f_AND_collectDataVector_r,
             vector<vector<long int>> &f_workDataVector);

  void less(int whereIsTheTargetCharacter, string f_SelectRule_str,
            const vector<vector<long int>> &dataBase_r,
            vector<vector<long int>> &f_AND_collectDataVector_r,
            vector<vector<long int>> &f_workDataVector);

  void greater(int whereIsTheTargetCharacter, string f_SelectRule_str,
               const vector<vector<long int>> &dataBase_r,
               vector<vector<long int>> &f_AND_collectDataVector_r,
               vector<vector<long int>> &f_workDataVector);

  string m_versionNumber_str;
  float m_parallelRuntimeResult_f;
  float m_parallelSearchtimeResult_f;

  //-------------------------------------O-N-L-Y-F-O-R-D-E-B-U-G-!!!!--------------
  // void loadCSV();
  // void testRun();
};

#endif /* SELECT_H_ */
