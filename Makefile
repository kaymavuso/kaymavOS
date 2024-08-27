all:
	nasm -f bin ./boot.asm -o ./boot.bin         # Assemble boot.asm into a binary file named boot.bin
	dd if=./message.txt >> ./boot.bin			 # Add message.txt to the boot sector.
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin # Pad the boot sector with zeros.