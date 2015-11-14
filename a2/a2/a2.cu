//Calculate prime numbers within a certain range provided by the user, or use default
//values of 0-1000

#include <iostream>
#include <cstdint>	//required for uint64_t
#include <sstream>	//convert runtime params into uint64 using istringstream
#include <ctime>
#include <chrono>
#include <cstdlib>
#include <cuda_runtime.h>
const int MAX_THREADS = 1024;
using namespace std::chrono;

/*double inline __declspec (naked) __fastcall sqrt(double n)
{
_asm fld qword ptr[esp + 4]
_asm fsqrt
_asm ret 8
}*/

void reportTime(const char* msg, steady_clock::duration span) {
	auto ms = duration_cast<milliseconds>(span);
	std::cout << msg << " - took - " <<
		ms.count() << " millisecs" << std::endl;
}

uint64_t genPrime(uint64_t a, uint64_t b) {
	//Keep track of results
	uint64_t count = 0;
	//Outer loop
	for (uint64_t i = a; i < b; i++)
		//Inner loop
		for (uint64_t j = 2; j*j <= i; j++) {
			if (i % j == 0)
				break;
			else if (j + 1 > sqrt(i)) {
				//Actual output
				//std::cout.precision(0);
				std::cout << std::fixed << i << "\n";
				count++;
			}
		}
	return count;	//Return total number of primes generated in the range specified
}

int main(int argc, char* argv[]) {
	std::cout << "***Team /dev/null GPU610 PRIME NUMBER GENERATOR v1.2***\n";

	//In case the user didn't provide arguments
	uint64_t start = 0; //orig 21474836470000
	uint64_t end = 1000;  //orig 214748364700000

	//Save runtime params into local variables, if provided
	if (argc == 2) {
		std::istringstream ss1(argv[1]);
		if (!(ss1 >> end))
			std::cout << "Bad input for end parameter\n";
	}

	if (argc == 3) {
		std::istringstream ss2(argv[1]);
		if (!(ss2 >> start))
			std::cout << "Bad input for start parameter\n";

		std::istringstream ss3(argv[2]);
		if (!(ss3 >> end))
			std::cout << "Bad input for end parameter\n";
	}
	else std::cout << "No range given (or bad input), using preset values\n";
	if (start >= end) {
		std::cerr << "***Invalid input, start must be less than end***\n";
	}
	std::cout << "Generating from range (" << start << "~" << end << ")\n";
	std::cout << "--------------------------------------------------------------------------------\n";
	//Keep track of time spent doing calculations
	steady_clock::time_point ts, te;
	ts = steady_clock::now();

	//Generate primes
	//Starting with the thread calculations
	uint64_t threadStart = 0; //The first portion, where each thread begins
	uint64_t threadEnd, taskLength;
	int threadAmount = MAX_THREADS; //Replace MAX_THREADS with amount of threads once we find the function
	taskLength = (end - start) / threadAmount; //Assigns the length of each portion of the task. This is how much of the total function runs in each thread.
	threadEnd = taskLength;
	//CUDA Allocation (please freaking work)
	double* h_a = new double[start];
	double* h_b = new double[end];
	double* d_a, d_b;
	cudaMalloc((void**)&d_a, taskLength * sizeof(double));

	//End cuda allocation

	//Function call

	uint64_t count = genPrime(start, end);	//REPLACE WITH CUDA KERNEL CALL
	te = steady_clock::now();

	std::cout << "\n--------------------------------------------------------------------------------\n"
		<< "There are " << count << " prime numbers in the calculated range.\n";
	reportTime("Took: {0} seconds", te - ts);
	return 0;
}

/* Original code
int main()
{
for (int i = 2; i<100; i++)
for (int j = 2; j*j <= i; j++)
{
if (i % j == 0)
break;
else if (j + 1 > sqrt(i)) {
std::cout << i << " ";
}
}
return 0;
}
*/

//Changelog
/*
v1 - Generating from simple double loop
v1.0.1 - Command line parameter input
v1.1 - Nicer output format and error feedback
v1.2 - Full 64 bit integer compatibility

*/

/*TODO
	- Write kernel function to replace genPrime()
	-complete/correct CUDA memory and thread allocation
	-Write new function call for genPrime<<<>>> //The <<<>>> mean kernel function
	-... Yeah that's it.
	
*/