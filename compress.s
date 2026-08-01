.intel_syntax noprefix
.global asm_compress
.global asm_decompress
.type asm_compress, @function
.type asm_decompress, @function

asm_compress:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r8, rdi
    mov r9, rsi
    mov r10, rdx

    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor rax, rax

.L_comp_loop:
    cmp r11, r10
    jge .L_comp_flush

    movzx ebx, byte ptr [r9 + r11]

    cmp bl, ' '
    je .L_code_space
    cmp bl, 'a'
    jl .L_check_upper
    cmp bl, 'z'
    jg .L_code_other
    sub bl, 'a'
    inc bl
    jmp .L_got_code

.L_check_upper:
    cmp bl, 'A'
    jl .L_code_other
    cmp bl, 'Z'
    jg .L_code_other
    sub bl, 'A'
    inc bl
    jmp .L_got_code

.L_code_space:
    mov bl, 0
    jmp .L_got_code

.L_code_other:
    mov bl, 27

.L_got_code:
    and ebx, 0x1F
    mov cl, r12b
    shl rbx, cl
    or r13, rbx
    add r12, 5

.L_write_bytes:
    cmp r12, 8
    jl .L_next_char
    mov byte ptr [r8 + rax], r13b
    inc rax
    shr r13, 8
    sub r12, 8
    jmp .L_write_bytes

.L_next_char:
    inc r11
    jmp .L_comp_loop

.L_comp_flush:
    cmp r12, 0
    jle .L_comp_done
    mov byte ptr [r8 + rax], r13b
    inc rax

.L_comp_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

asm_decompress:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r8, rdi
    mov r9, rsi
    mov r10, rdx
    mov r14, rcx

    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor rax, rax

.L_decomp_loop:
    cmp rax, r14
    jge .L_decomp_done

.L_fill_bits:
    cmp r12, 5
    jge .L_extract_code
    cmp r11, r10
    jge .L_extract_code
    movzx ebx, byte ptr [r9 + r11]
    mov cl, r12b
    shl rbx, cl
    or r13, rbx
    add r12, 8
    inc r11
    jmp .L_fill_bits

.L_extract_code:
    cmp r12, 5
    jl .L_decomp_done
    mov ebx, r13d
    and ebx, 0x1F
    shr r13, 5
    sub r12, 5

    cmp bl, 0
    je .L_char_space
    cmp bl, 26
    jbe .L_char_alpha
    mov byte ptr [r8 + rax], '.'
    jmp .L_char_written

.L_char_space:
    mov byte ptr [r8 + rax], ' '
    jmp .L_char_written

.L_char_alpha:
    add bl, 'a'
    dec bl
    mov byte ptr [r8 + rax], bl

.L_char_written:
    inc rax
    jmp .L_decomp_loop

.L_decomp_done:
    mov byte ptr [r8 + rax], 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
