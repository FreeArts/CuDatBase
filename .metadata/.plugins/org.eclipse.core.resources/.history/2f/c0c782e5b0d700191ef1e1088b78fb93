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

  // Function to fetch data from a CSV File
  vector<vector<string>> getData();
};

#endif /* CSVREADER_H_ */
