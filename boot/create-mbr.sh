cd boot
nasm -I include/ -o mbr.bin mbr.S 
nasm -I include/ -o loader.bin loader.S 
dd if=mbr.bin of=hd60.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=hd60.img bs=512 count=4 seek=2 conv=notrunc

cd ../lib
#nasm -f elf -o kernel/print.o kernel/print.S
cd ../

#cd ../kernel
REMOTE_IP=192.168.0.108
REMOTE_DIR=/home/jiangli/workspace/
rsync -az "$PWD" $REMOTE_IP:$REMOTE_DIR
ssh jiangli@$REMOTE_IP 'cd '$REMOTE_DIR'my-os/;nasm -f elf -o lib/kernel/print.o lib/kernel/print.S; gcc -m32 -I lib/kernel/ -c -o kernel/main.o kernel/main.c; ld -melf_i386  -Ttext 0xc0001500 -e main -o kernel.bin kernel/main.o lib/kernel/print.o; '
rsync -az $REMOTE_IP:$REMOTE_DIR'my-os/kernel.bin' ./kernel/
#gcc -o kernel.bin main.c 
dd if=kernel/kernel.bin of=boot/hd60.img bs=512 count=200 seek=9 conv=notrunc


