/*
 * CSVReader.cpp
 *
 *  Created on: 2019 jan. 24
 *      Author: freeart
 */

#include "CSVReader.h"

CSVReader::CSVReader(string filename, string delm) :
    m_fileName_str(filename), m_delimeter_str(delm)
{ }

CSVReader::~CSVReader() {
	// TODO Auto-generated destructor stub
}

vector<vector<string> > CSVReader::getData()
{
    ifstream file(m_fileName_str);
    vector<vector<string> > l_dataList_v;

    std::string line = "";
    // Iterate through each line and split the content using delimeter
    while (getline(file, line))
    {
        vector<std::string> vec;
        boost::algorithm::split(vec, line, boost::is_any_of(m_delimeter_str));
        l_dataList_v.push_back(vec);
    }
    // Close the File
    file.close();

    return l_dataList_v;
}


