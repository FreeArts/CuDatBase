/*
 * select.cpp
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

#include "select.h"

using namespace std;

SELECT::SELECT() {
	// TODO Auto-generated constructor stub
	wrapper();
	collectData();
}

SELECT::~SELECT() {
	// TODO Auto-generated destructor stub
}

void SELECT::collectData(){

	typedef std::istream_iterator<std::string> istream_iterator;
	std::ifstream file("/home/freeart/MscThesis/CuDatBase/cudatbase/src/example.txt");
	std::vector<std::string> input;

	file >> std::noskipws;
	std::copy(istream_iterator(file), istream_iterator(),
	std::back_inserter(input));

	for (auto i = input.begin(); i != input.end(); ++i)
	    std::cout << *i << ' ';
}
