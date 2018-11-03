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

}

SELECT::~SELECT() {
	// TODO Auto-generated destructor stub
}

void SELECT::collectData(string databaseFile){
    // Store the words from the two files into these two vectors
    vector<string> DataArray;
    vector<string> QueryArray;

    // Create two input streams, opening the named files in the process.
    // You only need to check for failure if you want to distinguish
    // between "no file" and "empty file". In this example, the two
    // situations are equivalent.
    ifstream myfile("OHenry.txt");
    ifstream qfile("queries.txt");

    // std::copy(InputIt first, InputIt last, OutputIt out) copies all
    //   of the data in the range [first, last) to the output iterator "out"
    // istream_iterator() is an input iterator that reads items from the
    //   named file stream
    // back_inserter() returns an interator that performs "push_back"
    //   on the named vector.
    copy(istream_iterator<string>(myfile),
         istream_iterator<string>(),
         back_inserter(DataArray));
    copy(istream_iterator<string>(qfile),
         istream_iterator<string>(),
         back_inserter(QueryArray));

    try {
        // use ".at()" and catch the resulting exception if there is any
        // chance that the index is bogus. Since we are reading external files,
        // there is every chance that the index is bogus.
        cout<<QueryArray.at(20)<<"\n";
        cout<<DataArray.at(12)<<"\n";
    } catch(...) {
        // deal with error here. Maybe:
        //   the input file doesn't exist
        //   the ifstream creation failed for some other reason
        //   the string reads didn't work
        cout << "Data Unavailable\n";
    }
}