# hello:
# 	echo "hello make!!!"
CPPFLAGS = -Iinclude

sources := $(wildcard ./src/*.cpp)
headers := $(wildcard ./include/*.hpp)
objs := $(patsubst %.cpp, %.o, $(sources))

all: a.out

a.out: $(objs)

$(objs): $(sources)
# $(wildcard *.cpp):
# 	echo $@
# print: $(sources) $(headers)
# 	echo $^

# create_files:
# 	touch a.cpp b.cpp c.cpp

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

# CC = gcc # 隐式规则标志
# CFLAGS = -g # 隐式规则的标志。打开调试信息

# # 隐式规则 #1：blah是通过C链接器隐式规则构建的
# # 隐式规则 #2: blah.o是通过C编译隐式规则构建的，因为blah.c存在
# blah: blah.o

# all: print

# aaa: test.o main_cpp_primer.o



# objects = foo.o bar.o all.o
# all: $(objects)

# # 这些文件通过上面隐式规则进行编译
# foo.o: foo.c
# bar.o: bar.c
# all.o: all.c

# all.c:
# 	echo "int main() { return 0; }" > all.c

# %.c:
# 	touch $@

# clean:
# 	rm -f *.c *.o all