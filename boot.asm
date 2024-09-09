ORG 0   ; Assemble code as if it starts at address 0x0000. 
        ; However, during boot, the BIOS will load this code at physical address 0x7C00.
        ; The ORG 0 directive allows for simpler offset calculations in the code, 
        ; while the code will actually execute starting from 0x7C00.

BITS 16             ; Assemble for 16-bit architecture (real mode).
_start:
    jmp short start; Jump to start label.
    nop             ; This command tells the assembler to do nothing (No operation).

times 33 db 0       ; Padding with 33 bytes of zeros to create space for the BIOS parameter block in the boot sector
                    ; at physical address 0x7C00. The boot sector is only 512 bytes in size,
                    ; and it must contain both the bootloader code and the BPB. This padding is necessary to ensure
                    ; for BIOSes that require a BPB, the BPB has its designated space in the boot sector. This also ensures that the
                    ; bootloader and file system will co-exist coexist correctly in the first 512 bytes of the boot sector.

start:
jmp 0x7C0:step2     ; Ensuring the Code Segment register starts at physical address 0x7C00 and jump to step2.



step2:
    cli             ; Disable interrupts for critical operations.

    ;===== Initialize segment registers to be in control of how BIOS sets up the registers =====
    mov ax, 0x7C0   ; Load segment base address (0x07C0) into AX.
    mov ds, ax      ; Set Data Segment (DS) register.
    mov es, ax      ; Set Extra Segment (ES) register.
    mov ax, 0x00    ; Clear AX register.
    mov ss, ax      ; Set Stack Segment (SS) register.
    ;===== End of segment initialization =====

    mov sp, 0x7C00  ; Set Stack Pointer (SP) to 0x7C00 to ensure that the stack operates in the correct memory area.
    sti             ; Re-enable interrupts.

    mov ah, 2       ; Set function for BIOS interrupt (read sector COMMAND).
    mov al, 1       ; Set number of sectors to read.
    mov ch, 0       ; Set cylinder number to 0. Cylinder low eight bits.
    mov cl, 2       ; Set sector number to 2. Read sector 2.
    mov ch, 0       ; Set cylinder number to 0. Cylinder high eight bits.
    mov bx, buffer  ; Set address of buffer to load the sector into.
    int 0x13        ; Invoke the read sector interrupt handler.
    jc error        ; Jump to error if CF is set.

    mov si, buffer  ; Load address of buffer into SI.
    call print      ; Call print function to display the message.
    jmp $           ; Infinite loop to halt execution.

error:
    mov si, error_message ; Load address of error_message into SI.
    call print            ; Call print function to display the error message.

    jmp $           ; Infinite loop to halt execution.

print:              ; print is a subroutine, a reusable piece of code.
    mov bx, 0       ; Clear BX register.
.loop:
    lodsb           ; Load byte from SI into AL, increment SI.
    cmp al, 0       ; Compare AL with 0 (end of string).
    je .done        ; Jump to .done if AL is 0.
    call print_char ; Print character in AL.
    jmp .loop       ; Repeat until end of string.
.done:
    ret             ; Return from print function. Return to the calling code.

print_char:         ; print_char is a subroutine, a reusable piece of code.
    mov ah, 0Eh     ; Set function for BIOS interrupt (print char).
    int 0x10        ; Interrupt the flow of execution to call BIOS video service to print AL.
    ret             ; Return from print_char function. Return to the calling code.

error_message: db 'Failed to load sector', 0 ; Message string with null terminator.

times 510-($ - $$) db 0 ; Pad code to 512 bytes for boot sector.

dw 0xAA55 ; Boot signature required by BIOS.

buffer:
