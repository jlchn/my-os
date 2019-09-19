nasm -o mbr.bin mbr.S 

dd if=mbr.bin of=hd60.img bs=512 count=1 conv=notrunc


