#!/bin/bash
if [ ! -d "./build" ]; then
      mkdir build
fi

if [ ! -d "./build/boot" ];then 
    mkdir build/boot
fi 
if [ ! -d "./build/kernel" ];then 
    mkdir build/kernel 
fi 

nasm -I ./boot/include/ -o ./build/boot/mbr.bin ./boot/mbr.S && dd if=./build/boot/mbr.bin of=./hd60.img bs=512 count=1  conv=notrunc

nasm -I ./boot/include/ -o ./build/boot/loader.bin ./boot/loader.S && dd if=./build/boot/loader.bin of=./hd60.img bs=512 count=4 seek=2 conv=notrunc

nasm -f elf -o build/kernel/print.o lib/kernel/print.S

nasm -f elf -o build/kernel/kernel.o kernel/kernel.S

gcc -m32 -I lib/kernel -c -o build/timer.o device/timer.c 

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-stack-protector -o build/kernel/main.o kernel/main.c

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-stack-protector -o build/interrupt.o kernel/interrupt.c

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-stack-protector -o build/init.o kernel/init.c

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-stack-protector -o build/debug.o kernel/debug.c

ld -melf_i386  -Ttext 0xc0001500 -e main -o ./build/kernel/kernel.bin \
    build/kernel/main.o build/kernel/print.o build/init.o build/interrupt.o build/kernel/kernel.o build/timer.o build/debug.o  \
    && dd if=./build/kernel/kernel.bin of=./hd60.img bs=512 count=200 seek=9 conv=notrunc

