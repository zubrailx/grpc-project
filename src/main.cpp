#include <iostream>

using namespace std;

template<typename T>
void print(T value) {
	cout << __PRETTY_FUNCTION__ << endl;
	cout << value << endl;
}

template<typename T, typename... Args>
void print(T value, Args... args) {
	cout << __PRETTY_FUNCTION__ << endl;
	cout << value << endl;
	print(args...);
}

int main() { print("abcde", 101, 101.4, true, 4, 91); }
