objects = main.o add.o minus.o
target = main

#main : main.o add.o minus.o
main : $(objects)
	cc -o $(target) main.o add.o minus.o
main.o : source/main.cpp 
	cc -I header/ -c source/main.cpp
add.o : c/add.cpp
	cc -I header/ -c c/add.cpp
minus.o : c/minus.cpp 
	cc -I header/ -c c/minus.cpp
clean : 
	rm $(target) $(objects)
