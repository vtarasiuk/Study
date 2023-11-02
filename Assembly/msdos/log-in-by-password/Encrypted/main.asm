.8086
.model tiny
code SEGMENT
ASSUME CS:code, DS:code, SS:code
ORG 100h
START:	
	mov ah, 09h								; write string to std output 
	mov dx, offset enter_passwd_message		; '$' terminated string
	int 21h
	
input_loop:
	mov ah, 01h								; check for keystroke
	int 16h
	jz input_loop 							; no keystroke available
	
	mov ah, 00h								; get keystroke
	int 16h					
	mov key_pressed, al						; save pressed key
	
	call handle_backspace					; backspace key processing
	cmp al, 0								; backspace keystroke case
	je input_loop							; start over
	
	cmp key_pressed, 13						; enter key processing
	je input_loop_Done						; break loop
	cmp key_pressed, 10						; enter key processing
	je input_loop_Done						; break loop
	
	call validate_key						; validate keystroke
	cmp al, 0								; valid code: 0, invalid code: 1
	jne input_loop							; invalid keystroke case
	
	call append_password					; update password buffer and it's length
	cmp al, 0								; append success case
	jne input_loop							; avoid overfitting buffer
	
	call display_key						; display pressed key
	
	jmp input_loop							; loop
	
input_loop_Done:	
	; bios alternative for ms-dos int 21h/AH=02h
	mov ah, 0Eh								; teletype output
	mov al, 13								; \r character
	mov bh, 0								; page number
	mov bl, 07h								; color: while on black
	int 10h
	
	mov ah, 0Eh								; teletype output
	mov al, 10								; \n character
	mov bh, 0								; page number
	mov bl, 07h								; color: while on black
	int 10h
	
	jmp compare_passwd						; compare password
	
	mov ah, 00h								; terminate program
	int 20h

compare_passwd:
	mov si, offset admin_passwd_buffer		; load system password 
	mov di, offset user_password_buffer		; load user password
	
	compare_loop:
		mov bh, [si]
		mov bl, [di]
		cmp bh, bl							; compare two bytes
		jne wrong_password_exit				; different values case
		
		cmp bh, 0 							; check null-terminated case
		je log_in_system					; passwords are equal
		
		inc si								; increment address
		inc di								; increment address
		jmp compare_loop					; loop

wrong_password_exit:
	mov ah, 09h								; write string to std output
	mov dx, offset wrong_passwd_msg			; '$' terminated string
	int 21h
	
	mov ah, 00h								; terminate program
	int 21h

log_in_system:
	mov ah, 07h								; scroll down window
	mov al, 0								; clear entire window
	mov bh, 07h								; attribute used to write blank lines at top of window
	mov ch, 0								; row of upper left corner
	mov cl, 0								; column of upper left corner
	mov dh, 24								; row of lower right corner
	mov dl, 79								; column of lower right corner
	int 10h
	
	mov ah, 02h								; set cursor position
	mov bh, 0								; page number
	mov dh, 0								; row
	mov dl, 0								; column
	int 10h
	
	mov ah, 09h								; write string to std output
	mov dx, offset system_msg				; '$' terminated string
	int 21h
	
	mov ah, 00h								; terminate program
	int 21h

append_password:
	mov bx, current_passwd_length					; load current length of password buffer
	cmp bx, max_passwd_length						; buffer overflow case
	jge exit_code_one								; return al=1
	
	mov di, offset user_password_buffer				; load address of the password buffer
	lea di, [di + bx]								; calculate and store address of length's byte of the password buffer
	mov al, key_pressed								; load pressed key
	mov [di], al									; store presed key into password buffer
	
	inc current_passwd_length						; update password length
	jmp exit_code_zero								; return al=0

exit_code_one:										; return 1 procedure
	mov al, 1
	ret
	
exit_code_zero:										; return 0 procedure
	mov al, 0
	ret

shrink_passwd:
	mov bx, current_passwd_length					; load length of the password buffer
	cmp bx, 0										; empty buffer case
	je exit_code_one								; return al=1
	
	mov bx, current_passwd_length					; load length of the password buffer
	mov di, offset user_password_buffer				; load address of the password buffer
	lea di, [di + bx]								; calculate and store address of length's byte of the password buffer
	mov al, 0										; null ascii
	mov [di], al									; save null byte into password buffer
	
	dec current_passwd_length						; update password length
	jmp exit_code_zero								; return al=0

validate_key:
	mov al, 0										; TODO: add restrictions on password symbols
	ret

display_key:
	mov ah, 02h										; write keyboard character to std output
	mov dl, key_pressed								; load pressed key
	int 21h
	ret

handle_backspace:
	cmp key_pressed, 8								; not a backspace keystroke case
	jne exit_code_one								; return al=1
	
	call shrink_passwd								; pop password buffer
	cmp al, 1										; empty password buffer case
	je exit_code_zero								; return al=0
	
	mov ah, 03h										; get cursor position and size
	mov bh, 0										; page number
	int 10h

	dec dl 											; decrement column
	mov ah, 02h										; set cursor position
	int 10h
	
	mov ah, 0Eh										; teletype output
	mov al, ' '										; load space character
	mov bh, 0										; page number
	mov bl, 07h										; color: while on black
	int 10h
	
	call display_key								; update screen password state
	jmp exit_code_zero								; return al=0
	
	
	enter_passwd_message db "Enter password to log in:$"	; Welcome message
	allowed_keystrokes db "1234567890"						; TODO
	
	user_password_buffer db 16 dup (0)						; user password
	max_passwd_length equ 15								; max length
	current_passwd_length dw 0								; current length
	key_pressed db ?										; current keystroke
	
	admin_passwd_buffer db "hello", 0						; system password
	wrong_passwd_msg db "Wrong password!$"					; wrong password message
	system_msg db "Welcome, Mr. Vladus.",13,10,				; System welcome message
				  "I hope you have a good day$"				
				  
code ends
end START
