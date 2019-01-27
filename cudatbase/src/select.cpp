/*
 * select.cpp
 *
 *  Created on: 2018 nov. 3
 *      Author: freeart
 */

#include "select.h"


SELECT::SELECT() {
	// TODO Auto-generated constructor stub
	//setDatabaseName("/home/freeart/MscThesis/CuDatBase/cudatbase/src/example.txt");
	testFunction();
	m_dataList_v.empty();

	//For test without Qt
	m_dataBasePath_str = "/home/freeart/MscThesis/CuDatBase/cudatbase/src/honda_test.csv" ;
	m_delimeter_str = ";";
}

SELECT::SELECT(int a[5],int b[5],int c[5]) { //cuda_test call from qt
	// TODO Auto-generated constructor stub
	m_dataList_v.empty();

	//For test without Qt
	m_dataBasePath_str = "/home/freeart/MscThesis/CuDatBase/cudatbase/src/honda_test.csv" ;
	m_delimeter_str = ";";

	testFunction();
	callExample(a,b,c); //cuda_test
}

SELECT::~SELECT() {
	// TODO Auto-generated destructor stub
}

void SELECT::testFunction()
{
	testCuda();
}

void SELECT::loadDatabase(){
	CSVReader *reader = new CSVReader(m_dataBasePath_str,m_delimeter_str);
	m_dataList_v =  reader->getData();

	delete reader;

}

void SELECT::loadDatabase(const vector<vector<string> > &l_dataBase_v){
	m_dataList_v = l_dataBase_v;
}

void SELECT::showDatabase() const{

	for(vector<string> vec : m_dataList_v)
	    {
	        for(string m_dataList_v : vec)
	        {
	            cout<<m_dataList_v << " ; ";
	        }
	        cout<<std::endl;
	    }
}
