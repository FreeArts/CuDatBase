/*
 * select.cpp
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

#include "select.h"

SELECT::SELECT() {
  // TODO Auto-generated constructor stub
  // setDatabaseName("/home/freeart/MscThesis/CuDatBase/cudatbase/src/example.txt");
  testFunction();
  m_dataList_v.empty();

  // For test without Qt
  m_dataBasePath_str = "";
  m_delimeter_str = ";";
}

SELECT::~SELECT() {
  // TODO Auto-generated destructor stub
}

void SELECT::testFunction() { testCuda(); }

void SELECT::loadDatabase(const vector<vector<string>> &l_dataBase_v) {
  m_dataList_v = l_dataBase_v;
}

void SELECT::showDatabase() const {

  for (vector<string> vec : m_AND_collectDataVector) {
    for (string vector_member : vec) {
      cout << vector_member << ";";
    }
    cout << std::endl;
  }
}

void SELECT::readSelectRule(vector<string> l_selectRule_v) {
  m_selectRule_v = l_selectRule_v;
}

void SELECT::run() {

  // date="2010" & sex="men" | brand="ktm"
  bool firstRun = true;
  int input; // Todo destroy it...
  collectDataVector_p = &m_AND_collectDataVector;
  const vector<vector<string>> &l_dataBase_r = m_dataList_v;

  for (string l_rule_str : m_selectRule_v) {
    input = l_rule_str.find("&");
    if (input != (-1)) {

      and_method(collectDataVector_p, m_OR_collectDataVector,
                 m_AND_collectDataVector, m_workDataVector);
      continue;
    }

    input = l_rule_str.find("|");
    if (input != (-1)) {
      or_method(collectDataVector_p, m_OR_collectDataVector);
      continue;
    }

    /// first will be find date="2010"
    input = l_rule_str.find("=");
    if (input != (-1)) {
      equal(input, l_rule_str, l_dataBase_r, collectDataVector_p,
            m_workDataVector, firstRun);

      continue;
    }

    or_and_merge(collectDataVector_p, m_OR_collectDataVector,
                 m_AND_collectDataVector);
  }
}

void SELECT::or_method(vector<vector<string>> *f_collectDataVector_p,
                       vector<vector<string>> &f_OR_collectDataVector_r) {
  /// put collectDataVector_p contain to l_OR_collectDataVector_r by indirect
  f_collectDataVector_p = &f_OR_collectDataVector_r;
  f_collectDataVector_p->clear();
}

void SELECT::and_method(vector<vector<string>> *f_collectDataVector_p,
                        const vector<vector<string>> &f_OR_collectDataVector_r,
                        vector<vector<string>> &f_AND_collectDataVector_r,
                        vector<vector<string>> &f_workDataVector) {

  or_and_merge(f_collectDataVector_p, f_OR_collectDataVector_r,
               f_AND_collectDataVector_r);

  /// put collectDataVector_p contain to AND_collectDataVector_r by indirect
  f_collectDataVector_p = &f_AND_collectDataVector_r;

  f_workDataVector.clear();
  /// put the AND_collectDataVector_r contains to l_workDataVector by directly
  f_workDataVector = f_AND_collectDataVector_r;
  f_collectDataVector_p->clear();
}

void SELECT::or_and_merge(
    const vector<vector<string>> *f_collectDataVector_p,
    const vector<vector<string>> &f_OR_collectDataVector_r,
    vector<vector<string>> &f_AND_collectDataVector_r) {
  /// if the collectDataVector_p point to the OR_collectDataVector_r copy the
  /// OR_collectDataVector_r contain to AND_collectDataVector_r
  if ((void *)f_collectDataVector_p == &f_OR_collectDataVector_r) {
    f_AND_collectDataVector_r.insert(f_AND_collectDataVector_r.end(),
                                     f_OR_collectDataVector_r.begin(),
                                     f_OR_collectDataVector_r.end());
  }
}

void SELECT::equal(int input, string f_SelectRule_str,
                   const vector<vector<string>> &dataBase_r,
                   vector<vector<string>> *f_collectDataVector_p,
                   vector<vector<string>> &f_workDataVector, bool &firstRun) {
  /// date="2010"
  unsigned int l_columnNumber_ui = 0;
  /// cut "=2010" part
  string column = f_SelectRule_str.substr(0, input);
  /// cut "date=" part
  string row = f_SelectRule_str.substr(input + 1, f_SelectRule_str.size());

  /// find "date" number of column
  for (unsigned int l_it_y = 0; l_it_y < dataBase_r.at(0).size();
       l_it_y++) // Todo optimalize!!
  {
    string alma = dataBase_r.at(0).at(l_it_y);
    if (alma == column) {
      l_columnNumber_ui = l_it_y;
    }
  }

  if (firstRun == true) {
    /// if first time run the query, search the lines from original database
    /// else we search from workDataVector
    for (unsigned int l_it_x = 0; l_it_x < dataBase_r.size(); l_it_x++) {
      string word = dataBase_r.at(l_it_x).at(l_columnNumber_ui);
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
      string word = f_workDataVector.at(l_it_x).at(l_columnNumber_ui);
      if (word == row) {
        f_collectDataVector_p->push_back(f_workDataVector.at(l_it_x));
      }
    }
  }
}
