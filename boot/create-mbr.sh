cd boot
nasm -I include/ -o mbr.bin mbr.S 
nasm -I include/ -o loader.bin loader.S 
dd if=mbr.bin of=hd60.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=hd60.img bs=512 count=4 seek=2 conv=notrunc

cd ../kernel
REMOTE_IP=192.168.0.108
REMOTE_DIR=/home/jiangli/workspace/my-os/
rsync -az ./main.c $REMOTE_IP:$REMOTE_DIR
ssh jiangli@$REMOTE_IP 'cd '$REMOTE_DIR';rm-rf *.bin; rm -rf *.o; gcc -c -o main.o main.c; ld main.o -Ttext 0xc0001500 -e main -o kernel.bin; ls -l '
rsync -az $REMOTE_IP:$REMOTE_DIR'kernel.bin' ./ 
#gcc -o kernel.bin main.c 
dd if=kernel.bin of=../boot/hd60.img bs=512 count=200 seek=9 conv=notrunc
cd ../

