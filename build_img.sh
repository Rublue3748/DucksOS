#! /bin/bash

cp ./bootloader/bootsector ./final.img
dd if=./bootloader.bin of=./final.img seek=1
file_size=$(stat -c %s final.img)
needed_bytes=$((512-(file_size%512)))
dd if=/dev/zero of=./final.img obs=1 seek=$file_size ibs=1 count=$needed_bytes
cat kernel.elf >> final.img
dd if=/dev/null of=./final.img bs=1 count=1 seek=161280