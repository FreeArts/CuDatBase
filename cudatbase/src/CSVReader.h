/*
 * CSVReader.h
 *
 *  Created on: 2019 jan. 24
 *      Author: freeart
 */
// In the future it will be on the Qt part
#ifndef CSVREADER_H_
#define CSVREADER_H_

#include <algorithm>
#include <boost/algorithm/string.hpp>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

using namespace std;

class CSVReader {

public:
  CSVReader(string filename, string delm = ";");
  virtual ~CSVReader();

  string m_fileName_str;
  string m_delimeter_str;

  void readData();
  // Function to fetch data from a CSV File
  std::vector<std::string> getHeaderOfDatabse() const;
  std::vector<std::vector<long int>> getDataBase() const;

private:
  std::vector<std::vector<long int>> m_dataList_v;
  std::vector<std::string> m_dataBaseHeader_v;
};

#endif /* CSVREADER_H_ */
