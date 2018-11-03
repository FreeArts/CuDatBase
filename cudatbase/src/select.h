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
	virtual ~SELECT();

	void collectData(string databaseFile);

private:

};

#endif /* SELECT_H_ */