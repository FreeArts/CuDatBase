/*
 * select.h
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

#ifndef SELECT_H_
#define SELECT_H_

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

	void select_every(const string &target);
	void collectData();

	void testFunction();
private:
	void setDatabaseName(string name);
	string databaseName;

};

#endif /* SELECT_H_ */
