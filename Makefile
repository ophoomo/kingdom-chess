

default: run

run: 
	zig build run

build: 
	zig build -Dtarget=x86_64-windows -Dcpu=x86_64_v3 -Doptimize=ReleaseSafe
