# hello:
# 	echo "hello make!!!"

test: test.o
	cc test.o -o test

test.o: test.c
	cc -c test.c -o test.o

test.c:
	echo "int main() { return 0; }" >> test.c

clean:
	rm -f test test.o test.c