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
	setDatabaseName("/home/freeart/MscThesis/CuDatBase/cudatbase/src/example.txt");
	testFunction();
	testCuda();
}

SELECT::~SELECT() {
	// TODO Auto-generated destructor stub
}

void SELECT::select_every(const string &target)
{

}

void SELECT::collectData(){


}

void SELECT::setDatabaseName(string name)
{
	databaseName = name;
}

void SELECT::testFunction()
{
	testCuda();
	std::vector<std::string> output;
	typedef std::istream_iterator<std::string> istream_iterator;
	std::ifstream file(databaseName);
	std::vector<std::string> input;

	std::copy(istream_iterator(file), istream_iterator(),
	std::back_inserter(input));

	for (auto i = input.begin(); i != input.end(); ++i)
		std::cout << *i << ' ';
}
