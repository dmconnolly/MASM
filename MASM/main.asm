.586
.model flat, stdcall
.stack 4096
option casemap : none

include windows.inc
include masm32.inc
include kernel32.inc
include user32.inc

includelib masm32.lib
includelib kernel32.lib
includelib user32.lib

.data
str_1 db "Test string 1", 0
str_2 db "Test string 2", 0

.const
IntStr db 0, 0
NewLine db 10, 0

.code
main PROC
	lea eax, str_1
	push eax
	call strlen

	lea eax, str_2
	push eax
	lea eax, str_1
	push eax
	call strcmp

	invoke ExitProcess, 0

strlen:
	push ebp ; push current stack pointer onto stack
	mov ebp, esp ; set base pointer to stack pointer
	
	mov edi, [ebp+8] ; get pointer to start of string from stack
	mov ebx, edi ; save original pointer in EBX

	xor al, al ; set AL to 0
	mov ecx, -1 ; set ECX to -1 (maximum value)

	repne scasb ; scan string until null-byte

	not ecx ; ecx = decrement and negate ECX
	dec ecx ; decrement ECX again
	mov eax, ecx ; copy string length into EAX for returning

	mov esp, ebp ; restore stack pointer
	pop ebp ; restore base pointer from stack
    ret 4 ; one parameter

strchr:
	push ebp ; push current stack pointer onto stack
	mov ebp, esp ; set base pointer to stack pointer

	mov edi, [ebp+8] ; get pointer from stack
	mov bl, [ebp+12] ; get character from stack

	xor al, al ; set al to null byte

	strchr_start_loop:
		mov cl, [edi] ; store current character from pointer
		cmp bl, cl ; check if character matches search character
		jz strchr_end_loop ; if so, exit loop
		scasb ; check for null byte (end of string)
		jnz strchr_start_loop ; loop if this is not the null byte
		xor edi, edi ; if this is the null byte, set EDI to 0 (return null)
	strchr_end_loop:

	test bl, bl ; check if search character is 0
	jnz strchr_return ; if not, return the value in edi

	; otherwise, decrement EDI0 to return pointer
	; to the end of the string
	dec edi

	strchr_return:
	mov eax, edi ; store return value in eax

	mov esp, ebp ; restore stack pointer
	pop ebp ; restore base pointer from stack
	ret 8 ; two parameters

memcpy_b:
	push ebp ; push current stack pointer onto stack
	mov ebp, esp ; set base pointer to stack pointer

	mov edi, [ebp+8] ; Get destination pointer from stack
	mov esi, [ebp+12] ; Get source pointer from stack
	mov ecx, [ebp+16] ; Get size in bytes from stack
	mov eax, edi ; Save initial destination pointer in EAX for returning

	rep movsb ; copy ECX bytes from source to destination

	mov esp, ebp ; restore stack pointer
	pop ebp ; restore base pointer from stack
    ret 12 ; three parameters

memset_b:
	push ebp ; push current stack pointer onto stack
	mov ebp, esp ; set base pointer to stack pointer

	mov edi, [ebp+8] ; Get pointer from stack
	mov ecx, [ebp+12] ; Get size in bytes from stack
	mov al, [ebp+16] ; Get byte value from stack
	mov ebx, edi ; Save initial pointer in EBX

	rep stosb ; copy ECX bytes into location at pointer

	mov eax, ebx ; Store initial pointer in eax for returning

	mov esp, ebp ; restore stack pointer
	pop ebp ; restore base pointer from stack
    ret 12 ; three parameters

strcmp:
	push ebp ; push current stack pointer onto stack
	mov ebp, esp ; set base pointer to stack pointer

	mov esi, [ebp+8] ; get first string pointer from stack
	mov edi, [ebp+12] ; get second string pointer from stack

	strcmp_start_loop:
		mov al, [esi] ; store next char from s1
		mov bl, [edi] ; store next char from s2

		test al, al ; check s1 char for null byte
		jz strcmp_s1_end ; exit loop if null byte

		cmp al, bl ; compare current char from s1 and s2
		jb strcmp_less ; s1 char is lesser, return -1
		ja strcmp_greater ; s1 char is greater, return 1

		inc esi ; increment s1 pointer
		inc edi ; increment s2 pointer

		jmp strcmp_start_loop ; return to start of loop

	strcmp_s1_end:
	test bl, bl ; check if s2 char is null
	jz strcmp_equal ; strings are equal, return 0
	jmp strcmp_less ; s1 is lesser, return -1
	
	; store -1, 0 or 1 in EAX for returning
	; depending on whether s1 <==> s2
	strcmp_less:
	mov eax, -1
	jmp strcmp_return
	strcmp_equal:
	xor eax, eax
	jmp strcmp_return
	strcmp_greater:
	mov eax, 1

	strcmp_return:
	mov esp, ebp ; restore stack pointer
	pop ebp ; restore base pointer from stack
	ret 8 ; two parameters

strset:
	push ebp ; push current stack pointer onto stack
	mov ebp, esp ; set base pointer to stack pointer

	mov edi, [ebp+8] ; get pointer from stack
	mov al, [ebp+12] ; get character from stack

	strset_startloop:
	mov cl, [edi] ; store current character in cl
	test cl, cl ; check if current character is null byte
	jz strset_endloop ; if this is the null byte, exit loop
	stosb ; copy character to pointer location in string
	jmp strset_startloop ; return to start of loop
	strset_endloop:

	mov esp, ebp ; restore stack pointer
	pop ebp ; restore base pointer from stack
    ret 8 ; two parameters

main ENDP
END main
