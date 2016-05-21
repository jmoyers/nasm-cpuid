build:
	nasm -f macho cpuid.asm
	ld -o cpuid -e main cpuid.o
