org 7C00h

start:
    mov ax, 0
    mov ds, ax

    call print_header
    call print_vendor
    call print_full_name
    call print_cores
    call print_cache_line
    call print_stepping


print_header:
    mov ah, 2h
    mov dh, 0
    mov dl, 0
    xor bh, bh
    int 10h
    mov ax, 1301h
    mov bp, header
    mov cx, 34
    mov bl, 0bh
    int 10h
    ret


print_vendor:
    mov ah, 2h
    mov dh, 3
    mov dl, 0
    xor bh, bh
    int 10h
    mov ax, 1301h
    mov bp, vendor
    mov cx, 13
    mov bl, 0eh
    int 10h

    mov eax, 0
    cpuid
    push ecx
    push edx
    push ebx

    mov cx, 3
    loop3v:
        pop edx
        call print_edx

        dec cx
        cmp cx, 0
        jne loop3v
    ret


print_full_name:
    mov ah, 2h
    mov dh, 2
    mov dl, 0
    xor bh, bh
    int 10h
    mov ax, 1301h
    mov bp, name
    mov cx, 13
    mov bl, 0eh
    int 10h

    mov eax, 80000002h
    call print_full_name_part
    mov eax, 80000003h
    call print_full_name_part
    mov eax, 80000004h
    call print_full_name_part


print_full_name_part:
    cpuid
    push edx
    push ecx
    push ebx
    push eax

    mov cx, 4
    loop4n:
        pop edx
        call print_edx

        dec cx
        cmp cx, 0
        jne loop4n

    ret


print_cores:
    mov ah, 2h
    mov dh, 4
    mov dl, 0
    xor bh, bh
    int 10h
    mov ax, 1301h
    mov bp, cores
    mov cx, 13
    mov bl, 0eh
    int 10h

    mov eax, 1
    cpuid

    ror ebx, 16
    mov al, bl
    call print_al

    ret


print_cache_line:
    mov ah, 2h
    mov dh, 5
    mov dl, 0
    xor bh, bh
    int 10h
    mov ax, 1301h
    mov bp, cache_line
    mov cx, 13
    mov bl, 0eh
    int 10h

    mov eax, 1
    cpuid
    ror ebx, 8


    mov al, bl
    mov bl, 8
    mul bl
    call print_al

    ret

print_stepping:
    mov ah, 2h
    mov dh, 6
    mov dl, 0
    xor bh, bh
    int 10h
    mov ax, 1301h
    mov bp, stepping
    mov cx, 13
    mov bl, 0eh
    int 10h

    mov eax, 1
    cpuid

    and al, 15
    call print_al


    ret


print_edx:
    mov ah, 0eh

    mov bx, 4
    loop4r:
        mov al, dl
        int 10h
        ror edx, 8

        dec bx
        cmp bx, 0
        jne loop4r
    ret

print_al:
    mov ah, 0
    mov dl, 10
    div dl
    add ax, '00'
    mov dx, ax

    mov ah, 0eh
    mov al, dl
    cmp dl, '0'
    jz skip_fn
    int 10h
    skip_fn:
    mov  al, dh
    int 10h

    ret


vendor db 'Vendor:      ', 0
name db 'Full name:   ', 0
cores db 'CPU cores:   ', 0
stepping db 'Stepping ID: ', 0
header db 'CPU INFO | DASHEVSKY SERGEY P33212', 0
cache_line db 'Cache line: ', 0

times 510 - ($ - $$) db 0
db 0x55, 0xAA
