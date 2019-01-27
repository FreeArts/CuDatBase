/*
 * select.h
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

#ifndef SELECT_H_
#define SELECT_H_

#include "CSVReader.h"
#include "cuda_select.cuh"

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <iterator>
#include <algorithm>

using namespace std;

class SELECT {
public:
	SELECT();
	SELECT(int a[5],int b[5],int c[5]);
	virtual ~SELECT();

	void testFunction();

	void loadDatabase();
	void loadDatabase(const vector<vector<string> > &l_dataBase_v);

	void showDatabase() const;

private:

	string m_dataBasePath_str;
	string m_delimeter_str;
	vector<vector<string> > m_dataList_v;
};

#endif /* SELECT_H_ */
