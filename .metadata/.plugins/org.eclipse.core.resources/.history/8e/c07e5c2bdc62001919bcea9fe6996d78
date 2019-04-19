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

  void testFunction();

  void loadDatabase(/*const vector<vector<string> > &l_dataBase_v*/);
  void loadDatabase(const vector<vector<string>> &l_dataBase_v);

  void showDatabase() const;

  void readSelectRule(/*vector<string> l_selectRule_v*/);
  void readSelectRule(vector<string> l_selectRule_v);

  void run();

private:
  string m_dataBasePath_str;
  string m_delimeter_str;
  vector<vector<string>> m_dataList_v;
  vector<string> m_selectRule_v;

  vector<vector<string>> *collectDataVector_p = NULL;
  vector<vector<string>> m_workDataVector;

  vector<vector<string>> m_AND_collectDataVector;
  vector<vector<string>> m_OR_collectDataVector;

  void or_method(vector<vector<string>> *f_collectDataVector_p,
                 vector<vector<string>> &f_OR_collectDataVector_r);

  void and_method(vector<vector<string>> *f_collectDataVector_p,
                  const vector<vector<string>> &f_OR_collectDataVector_r,
                  vector<vector<string>> &f_AND_collectDataVector_r,
                  vector<vector<string>> &f_workDataVector);

  void or_and_merge(const vector<vector<string>> *f_collectDataVector_p,
                    const vector<vector<string>> &f_OR_collectDataVector_r,
                    vector<vector<string>> &f_AND_collectDataVector_r);

  void equal(int input, string f_SelectRule_str,
             const vector<vector<string>> &dataBase_r,
             vector<vector<string>> *f_collectDataVector_p,
             vector<vector<string>> &f_workDataVector, bool &firstRun);
};

#endif /* SELECT_H_ */
