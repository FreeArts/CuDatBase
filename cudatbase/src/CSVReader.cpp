/*
 * CSVReader.cpp
 *
 *  Created on: 2019 jan. 24
 *      Author: freeart
 */

#include "CSVReader.h"

CSVReader::CSVReader(std::string filename, std::string delm) :
    m_fileName_s(filename), m_delimeter_s(delm)
{ }

CSVReader::~CSVReader() {
	// TODO Auto-generated destructor stub
}

std::vector<std::vector<std::string> > CSVReader::getData()
{
    std::ifstream file(m_fileName_s);

    std::vector<std::vector<std::string> > l_dataList_v;

    std::string line = "";
    // Iterate through each line and split the content using delimeter
    while (getline(file, line))
    {
        std::vector<std::string> vec;
        boost::algorithm::split(vec, line, boost::is_any_of(m_delimeter_s));
        l_dataList_v.push_back(vec);
    }
    // Close the File
    file.close();

    return l_dataList_v;
}


