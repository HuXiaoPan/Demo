# hello:
# 	echo "hello make!!!"

files := file1.cpp file2.cpp file3.cpp

all: $(files)

$(files):
	echo $@

# all: test_file

# test_file: test
# 	echo "touch some source files:" $(files)
# 	touch $(files)

# test: test.o
# 	cc test.o -o test

# test.o: test.c
# 	cc -c test.c -o test.o

# test.c:
# 	echo "int main() { return 0; }" >> test.c

clean:
	rm -f $(files)