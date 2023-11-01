.model tiny
code SEGMENT
ASSUME CS:code, DS:code, SS:code
ORG 100h
START:
   
	mov ah, 03Ch                ; create a file
	mov cx, 0                   ; file attributes
	mov dx, offset filename     ; ASCIZ filename
	int 21h

	jc file_create_error        ; error while creating a file
	mov fileHandle, ax          ; store handle
	
	mov ah, 40h                 ; write to a file
	mov bx, fileHandle          ; handle
	mov cx, 16                  ; number of bytes to write
	mov dx, offset buffer       ; data to write
	int 21h
	
	jc file_write_error         ; error while writing to a file
	
	call close_file             ; close file
	
	mov ah, 00h                 ; terminate program
	int 20h

close_file:
	mov ah, 3Eh                             ; close file
	mov bx, fileHandle                      ; handle
	int 21h
	ret

file_create_error:
	mov error_code, ax                      ; store error code
	mov ah, 09h                             ; write string to std output
	mov dx, offset file_create_error_msg    ; '$' terminated string
	int 21h 
	
	call write_error_code                   ; write returned error code
	
	mov ah, 0                               ; terminate program
	int 20h

file_write_error:
	mov error_code, ax                      ; store error code
	mov ah, 09h                             ; write string to std output
	mov dx, offset file_write_error_msg     ; '$' terminated string
	int 21h 
	
	call write_error_code                   ; write returned error code
	
	call close_file                         ; close file
	
	mov ah, 00h                             ; terminate program
	int 20h

write_error_code:
	mov bx, error_code                      ; load error code
	mov ah, 02h                             ; write character to std output
	mov dl, bh                              ; character to write
	int 21h
	
	mov ah, 02h                             ; write character to std output
	mov dl, bl                              ; character to write
	int 21h
	ret

	buffer db "Some data here!", 0
	fileHandle dw 0
	filename db "debug.txt", 0
	file_create_error_msg db "Error: could not create a file. Error code: $"
	file_write_error_msg db "Error: could not write to a file. Error code: $"
	error_code dw 0
	
code ends
end START
