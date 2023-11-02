.8086
.model tiny
code SEGMENT
ASSUME CS:code, DS:code, SS:code
ORG 100h
START:
	; clear console
	;mov ah, 07h
	;mov al, 0
	;mov bh, 07h
	;mov ch, 0
	;mov cl, 0
	;mov dh, 24
	;mov dl, 79
	;int 10h
	; set cursor position
	;mov ah, 02h
	;mov bh, 0
	;mov dh, 0
	;mov dl, 0
	;int 10h
	
	mov ah, 09h										; 
	mov dx, offset enter_passwd_message
	int 21h
	
	mov di, offset user_password_buffer				; address of password buffer
	mov bx, offset user_passwd_last_char_address	; address of byte to write at in password buffer
	mov [bx], di									; store address of user password buffer in last_char_address
	
input_loop:
	mov ah, 01h
	int 16h					; check buffer
	jz input_loop 			; buffer is empty
	
	mov ah, 00h				; read keyboard buffer
	int 16h					
	mov key_pressed, al		; save pressed key
	
	
	cmp key_pressed, 8 		; backspace key compare
	je handle_backspace		; backspace key processing
	
	cmp key_pressed, 13		; enter key compare
	je exit_program			; enter key processing
	
	call validate_key		; validate pressed key
	cmp al, 0				; success code: 0, fail code: 1
	jne input_loop			; invalid key pressed
	
	call display_key		; display pressed key
	call append_password	; update password buffer and it's length
	
	jmp input_loop			; loop
	
exit_program:
	mov bx, user_passwd_last_char_address
	mov al, 24h		; store  "$" symbol
	mov [bx], al	; append "$" to the password
	
	; bios alternative
	mov ah, 0Eh
	mov al, 10
	mov bh, 0
	mov bl, 07h
	int 10h
	
	; bios alternative
	mov ah, 0Eh
	mov al, 13
	mov bh, 0
	mov bl, 07h
	int 10h
	
	mov ah, 03Ch				; create a file
	mov cx, 0					; file attributes
	mov dx, offset filename		; ASCIZ filename
	int 21h
	
	jc error_create_file
	mov fileHandle, ax			; store handle
	
	mov ah, 40h					; write to a file
	mov bx, fileHandle			; handle
	mov cx, 100					; number of bytes to write
	mov dx, offset user_password_buffer		; data to write
	int 21h
	
	jc error_write_file
	
	mov ah, 3Eh								; close file
	mov bx, fileHandle						; handle
	int 21h
	
	mov ah, 0
	int 20h
	
	key_pressed db ?
	enter_passwd_message db "Enter password to log in:$"
	allowed_characters db "1234567890" ; not in use yet
	max_passwd_length equ 32
	user_password_buffer db 100 dup (0)
	current_passwd_length db 0
	user_passwd_last_char_address dw 0
	
	tempdata db "TempDataTest$"
	
	filename db "C:\debug.txt",0
	fileHandle dw 0
	write_error db "Error writing to a file$"
	error_create_file_msg db "Error while creating a file. Error code: $"
	error_write_file_msg db "Error while writing to a file. Error code: $"
	error_code dw 0

append_password:
	mov bx, user_passwd_last_char_address 			; offset buffer+length value
	; check current and max passwd length
	mov al, key_pressed
	
	mov [bx], al 									; put value in password buffer
	
	inc bx											; next byte
	mov di, offset user_passwd_last_char_address	; store address of last_char_address value
	mov [di], bx									; update user_passwd_last_char_address
	
	inc current_passwd_length						; update length of the password
	ret

shrink_passwd:
	mov bx, user_passwd_last_char_address 			; offset buffer+length value
	; check if ne passwd is zero length
	mov al, 32
	dec bx											; previous byte
	mov [bx], al 									; put value in password buffer
	
	mov user_passwd_last_char_address, bx
	
	dec current_passwd_length						; update length of the password
	ret

validate_key:
	mov al, 0 ; success code
	ret

display_key:
	mov ah, 02h				; print keyboard character to the screen
	mov dl, key_pressed		; load pressed key
	int 21h
	ret

handle_backspace:
	mov bx, offset user_passwd_last_char_address	;
	mov ax, offset user_password_buffer		;
	cmp ax, [bx]								;
	je input_loop
	
	mov ah, 03h		; get cursor position
	mov bh, 0		;
	int 10h

	dec dl 			; decrement column
	mov ah, 02h		; set cursor position
	int 10h
	
	mov ah, 0Eh
	mov al, ' '
	mov bh, 0
	mov bl, 07h
	int 10h			; teletype output
	
	call shrink_passwd
	call display_key
	
	jmp input_loop

error_create_file:
	mov error_code, ax

	mov ah, 09h
	mov dx, offset error_create_file
	int 21h
	
	mov bx, error_code
	
	mov ah, 02h
	mov dl, bh
	int 21h
	
	mov ah, 02h
	mov dl, bl
	int 21h
	
	mov ah, 00h
	int 21h
	
error_write_file:
	mov error_code, ax
	
	mov ah, 09h
	mov dx, offset error_write_file_msg
	int 21h
	
	mov bx, error_code
	
	mov ah, 02h
	mov dl, bh
	int 21h
	
	mov ah, 02h
	mov dl, bl
	int 21h
	
	ret
	
	

code ends
end START
