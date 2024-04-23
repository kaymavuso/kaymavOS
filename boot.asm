ORG 0x7C00                  ; Tells the assembler to assemble the code as if it were located at the physical address 0x7C00. Ideally, the origin should be 0, then jump to the address.
BITS 16                     ; Indicates bit architecture so that the assembler only assembles instructions into 16-bit code. In real mode, the processor operates in 16-bit mode by default.

start:
    mov si, message         ; Loads the address of the message string into the SI register. The SI register is commonly used as a source pointer in string manipulation operations. 
    call print              ; Calls the print function to print the message.
    jmp $                   ; Causes an infinite loop, effectively halting the execution of the program at this point.

print:
    mov bx, 0               ; Clears the BX register.
.loop:
    lodsb                   ; Loads the byte from the memory location addressed by SI into AL and increments SI.
    cmp al, 0               ; Compares the byte loaded into AL with 0.
    je .done                ; Jumps to .done if the byte is 0 (end of string).
    call print_char         ; Calls the print_char function to print the character in AL.
    jmp .loop               ; Jumps back to .loop to continue printing characters.
.done:
    ret                     ; Returns from the print function subroutine.

print_char:
    mov ah, 0eh             ; Moves the value 0x0E into the AH register. This specifies the function for writing a character to the screen in BIOS interrupt calls.
    int 0x10                ; Generates a software interrupt 0x10, invoking the BIOS video services. The function specified in AH (0x0E) determines which specific video service will be performed, in this case, writing the character in AL to the screen.
    ret                     ; Returns from the print_char function.

message: db 'Hello World!', 0   ; Defines the message string.

times 510-($ - $$) db 0     ; Pads the code to ensure that the bootloader occupies exactly 512 bytes, as required by the boot sector standard. It fills the remaining space with zeros.

dw 0xAA55                   ; Places the boot signature (0xAA55) at the end of the bootloader. This signature is a marker recognized by the BIOS, indicating that the loaded sector is a valid boot sector.
