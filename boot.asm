ORG 0   ; Assemble code as if it starts at address 0x0000. 
        ; However, during boot, the BIOS will load this code at physical address 0x7C00.
        ; The ORG 0 directive allows for simpler offset calculations in the code, 
        ; while the code will actually execute starting from 0x7C00.

BITS 16             ; Assemble for 16-bit architecture (real mode).

jmp 0x7C0:start     ; Ensuring the code segment starts at physical address 0x7C00.

start:
    cli             ; Disable interrupts for critical operations.

    ;===== Initialize segment registers to be in control of how BIOS sets up the registers =====
    mov ax, 0x7C0   ; Load segment base address (0x07C0) into AX.
    mov ds, ax      ; Set Data Segment (DS) register.
    mov es, ax      ; Set Extra Segment (ES) register.
    mov ax, 0x00    ; Clear AX register.
    mov ss, ax      ; Set Stack Segment (SS) register.
    ;===== End of segment initialization =====

    mov sp, 0x7C00  ; Set Stack Pointer (SP) to 0x7C00.

    sti             ; Re-enable interrupts.
    mov si, message ; Load address of message into SI.
    call print      ; Call print function to display the message.
    jmp $           ; Infinite loop to halt execution.

print:
    mov bx, 0       ; Clear BX register.
.loop:
    lodsb           ; Load byte from SI into AL, increment SI.
    cmp al, 0       ; Compare AL with 0 (end of string).
    je .done        ; Jump to .done if AL is 0.
    call print_char ; Print character in AL.
    jmp .loop       ; Repeat until end of string.
.done:
    ret             ; Return from print function.

print_char:
    mov ah, 0Eh     ; Set function for BIOS interrupt (print char).
    int 0x10        ; Call BIOS video service to print AL.
    ret             ; Return from print_char function.

message: db 'Hello World, from kaymavOS! :-', 0 ; Message string with null terminator.

times 510-($ - $$) db 0 ; Pad code to 512 bytes for boot sector.

dw 0xAA55 ; Boot signature required by BIOS.
