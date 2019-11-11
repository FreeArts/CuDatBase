/*
 * select.cpp
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

//---------------------------O-N-L-Y-F-O-R-D-E-B-U-G-!!!!--------------
//#include "CSVReader.h"
//--------------------------------------------------------

#include "select.h"

//--------------------------O-N-L-Y-F-O-R-D-E-B-U-G-!!!!--------------
/*
void SELECT::loadCSV() {

  CSVReader *reader = new CSVReader(
      "/home/freeart/MscThesis/CuDatBase/cudatbase/src/simple_test.csv", ";");

  reader->readData();

  std::vector<std::vector<long int>> m_dataList_v = reader->getDataBase();
  std::vector<std::string> m_headerOfDataBase_v = reader->getHeaderOfDatabse();

  loadDatabase(m_dataList_v, m_headerOfDataBase_v);

  delete reader;

}

void SELECT::testRun() {

  loadCSV();
  std::vector<std::string> l_selectRule_stdv;

  // SELECT name,brand where date="2010" & sex="1" | brand="3"
  l_selectRule_stdv.push_back("date=2010");
  l_selectRule_stdv.push_back("&");
  l_selectRule_stdv.push_back("sex=1");
  l_selectRule_stdv.push_back("|");
  l_selectRule_stdv.push_back("brand=3");

  readSelectRule(l_selectRule_stdv);

  run();
  showDatabase();

  CudaSelect cudaTest;

  cudaTest.CudaRun(l_selectRule_stdv, m_dataList_v, m_databaseHeader);

}
*/
//-------------------------------------------------
SELECT::SELECT() {

  m_dataList_v.empty();
  m_firstRun_b = true;
  m_firstMethodWasOr_b = true;
  m_AND_collectDataVector.clear();

  //--------------------------O-N-L-Y-F-O-R-D-E-B-U-G-!!!!--------------
  // testRun();
  //-------------------------------------------------------------------
}

SELECT::~SELECT() {
  // TODO Auto-generated destructor stub
}

void SELECT::loadDatabase(const vector<vector<long int>> &f_dataBase_v,
                          const vector<string> f_headerOfDataBase) {
  m_dataList_v = f_dataBase_v;
  m_databaseHeader = f_headerOfDataBase;
}

void SELECT::showDatabase() const {

  for (vector<long int> vec : m_AND_collectDataVector) {
    for (long int vector_member : vec) {
      cout << vector_member << ";";
    }
    cout << std::endl;
  }
}

void SELECT::readSelectRule(vector<string> f_selectRule_v) {
  m_selectRule_v = f_selectRule_v;
  // CopySelectRuleToDevice(f_selectRule_v);
}

vector<vector<long int>> SELECT::parallelRun() {
  CudaSelect cudaSelect;
  cudaSelect.CudaRun(m_selectRule_v, m_dataList_v, m_databaseHeader);

  vector<vector<long int>> l_cudaResult_v = cudaSelect.getQueryResult();
  return l_cudaResult_v;
}

// ToDo refactore
void SELECT::run() {

  // init:
  m_AND_collectDataVector.clear();
  m_OR_collectDataVector.clear();
  m_workDataVector.clear();

  // date="2010" & sex="men" | brand="ktm"
  m_firstRun_b = true;
  m_firstMethodWasOr_b = true;

  int input; // Todo destroy it...
  collectDataVector_p = &m_AND_collectDataVector;

  const vector<vector<long int>> &l_dataBase_r = m_dataList_v;

  for (string l_rule_str : m_selectRule_v) {
    input = l_rule_str.find("&");
    if (input != (-1)) {

      and_method(collectDataVector_p, m_OR_collectDataVector,
                 m_AND_collectDataVector, m_workDataVector);

      if (m_firstMethodWasOr_b)
        m_firstMethodWasOr_b = false;

      continue;
    }

    input = l_rule_str.find("|");
    if (input != (-1)) {

      continue;
    }

    /// first will be find date="2010"
    input = l_rule_str.find("=");
    if (input != (-1)) {

      equal(input, l_rule_str, l_dataBase_r, collectDataVector_p,
            m_workDataVector);
      continue;
    }
  }
}

void SELECT::and_method(
    vector<vector<long int>> *f_collectDataVector_p,
    const vector<vector<long int>> &f_OR_collectDataVector_r,
    vector<vector<long int>> &f_AND_collectDataVector_r,
    vector<vector<long int>> &f_workDataVector) {

  // or_and_merge(f_collectDataVector_p, f_OR_collectDataVector_r,
  // f_AND_collectDataVector_r);

  f_workDataVector.clear();

  /// put collectDataVector_p contain to AND_collectDataVector_r by indirect
  /// (Redundant step!)
  f_collectDataVector_p = &f_AND_collectDataVector_r;

  /// put the AND_collectDataVector_r contains to l_workDataVector by directly
  f_workDataVector = f_AND_collectDataVector_r;

  f_collectDataVector_p->clear();
}

void SELECT::equal(int whereIsTheTargetCharacter, string f_SelectRule_str,
                   const vector<vector<long int>> &dataBase_r,
                   vector<vector<long int>> *f_collectDataVector_p,
                   vector<vector<long int>> &f_workDataVector) {
  /// date="2010"
  unsigned int l_columnNumber_ui = 0;
  /// cut "=2010" part
  string column = f_SelectRule_str.substr(0, whereIsTheTargetCharacter);
  /// cut "date=" part
  string tmp_row = f_SelectRule_str.substr(whereIsTheTargetCharacter + 1,
                                           f_SelectRule_str.size());
  long int row = std::stol(tmp_row);

  /// find "date" number of column //PC side
  for (unsigned int l_it_y = 0; l_it_y < m_databaseHeader.size();
       l_it_y++) // Todo optimalize!!
  {
    string l_column = m_databaseHeader.at(l_it_y);
    if (l_column == column) {
      l_columnNumber_ui = l_it_y;
    }
  }

  if ((m_firstRun_b == true) || (m_firstMethodWasOr_b == true)) {
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
    m_firstRun_b = false;
  }

  else {
    for (unsigned int l_it_x = 0; l_it_x < f_workDataVector.size(); l_it_x++) {
      long int word = f_workDataVector.at(l_it_x).at(l_columnNumber_ui);
      if (word == row) {
        f_collectDataVector_p->push_back(f_workDataVector.at(l_it_x));
      }
    }
  }
}

vector<vector<long int>> SELECT::getQueryResult() const {
  return m_AND_collectDataVector;
}
