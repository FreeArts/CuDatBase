/*
 * CSVReader.h
 *
 *  Created on: 2019 jan. 24
 *      Author: freeart
 */

#ifndef CSVREADER_H_
#define CSVREADER_H_

#include <fstream>
#include <vector>
#include <iterator>
#include <string>
#include <algorithm>
#include <boost/algorithm/string.hpp>

class CSVReader
{

public:
    CSVReader(std::string filename, std::string delm = ";");
	virtual ~CSVReader();

    std::string m_fileName_s;
    std::string m_delimeter_s;

    // Function to fetch data from a CSV File
    std::vector<std::vector<std::string> > getData();
};

#endif /* CSVREADER_H_ */
