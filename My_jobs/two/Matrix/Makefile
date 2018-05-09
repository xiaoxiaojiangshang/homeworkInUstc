
all: bcast_test

bcast_test: bcast_test.c
	mpicc -std=c99 -o bcast_test bcast_test.c

run:
	mpirun -np 128 --hostfile nodes.txt --display-map bcast_test
