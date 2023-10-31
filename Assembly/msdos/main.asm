.model tiny
code SEGMENT
ASSUME CS:code, DS:code, SS:code
ORG 100h
START:
    mov ah, 09h
    mov dx, offset message
    int 21h

    mov di, offset buffer
    mov bx, offset buffer_last_char
    mov [bx], di 			; buffer_last_char = offset buffer

generate_characters:
    call expand_buffer

    ; Check if 'ascii' exceeds your desired limit
    cmp ascii, 122
    jae display_buffer

    inc ascii

    jmp generate_characters

display_buffer:
	; set last symbol to $
	mov bx, buffer_last_char
	mov al, 24h ; "$"
	mov [bx], al
	
	; Display the buffer
    mov ah, 09h
    mov dx, offset buffer
    int 21h

    mov ah, 0
    int 20h

message db "Buffer: $"
buffer db 100 dup (0)
buffer_last_char dw 0
ascii db 65

expand_buffer:
    mov bx, buffer_last_char ; offset buffer+length
    mov al, ascii

    ; Store the character in the buffer
    mov [bx], al
    inc bx

    ; Update buffer_last_char
	mov si, offset buffer_last_char
    mov [si], bx

    ret

code ends
end START
