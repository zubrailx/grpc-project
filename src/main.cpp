#include <iostream>

// namespace meta;

namespace n {
struct hello {};
int world;
}// namespace n

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

int main() {
	print("HELLO", "WORLD");
	print("HELLO", "WORLD");
}
