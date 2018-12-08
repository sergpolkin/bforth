.intel_syntax noprefix

.equ stack_size, 1024

.section .rodata
msg_bad_byte:
	.ascii "Bad byte code!\n"
	msg_bad_byte_len = . - msg_bad_byte
msg_bye:
	.ascii "Bye!\n"
	msg_bye_len = . - msg_bye
msg:
	.ascii "Hello, world!\n"
	msg_len = . - msg

.section .data
bcmd:
	.quad bcmd_bad,     bcmd_bye,      bcmd_type,     0,              0, 0, 0, 0
	.quad bcmd_lit8,    bcmd_lit16,    bcmd_lit32,    bcmd_lit64,     0, 0, 0, 0
	.quad bcmd_branch8, bcmd_branch16, bcmd_qbranch8, bcmd_qbranch16, 0, 0, 0, 0
	.quad bcmd_dup,     0,             0,             0,              0, 0, 0, 0
	.quad bcmd_wm,      0,             0,             0,              0, 0, 0, 0
_fill_len = 256 - (. - bcmd) / 8
	.fill _fill_len, 8, 0

prog_start:
	.byte b_lit8
	.byte 10
m0:
	.byte b_lit64
	.quad msg
	.byte b_lit8
	.byte msg_len
	.byte b_type

	.byte b_wm
	.byte b_dup
	.byte b_qbranch8
	.byte m0 - .

	.byte b_bye
	.byte b_bad

.section .text
.global _start
_start:
	mov rbp, rsp
	sub rbp, stack_size
	lea r8, prog_start
	jmp _next
_next:
	movzx rcx, byte ptr [r8]
	inc r8
	jmp [bcmd + rcx*8]

b_bad = 0x00
bcmd_bad:
	# write
	mov rdx, msg_bad_byte_len
	mov rsi, OFFSET FLAT:msg_bad_byte
	mov rdi, 1
	mov rax, 1
	syscall
	# exit 1
	mov rdi, 1
	mov rax, 60
	syscall

b_bye = 0x01
bcmd_bye:
	# write
	mov rdx, msg_bye_len
	mov rsi, OFFSET FLAT:msg_bye
	mov rdi, 1
	mov rax, 1
	syscall
	# exit 0
	xor rdi, rdi
	mov rax, 60
	syscall

b_type = 0x02
bcmd_type:
	pop rdx
	pop rsi
	mov rdi, 1
	mov rax, 1
	syscall
	jmp _next

b_lit8 = 0x08
bcmd_lit8:
	movsx rax, byte ptr [r8]
	inc r8
	push rax
	jmp _next

b_lit16 = 0x09
bcmd_lit16:
	movsx rax, word ptr [r8]
	inc r8
	inc r8
	push rax
	jmp _next

b_lit32 = 0x0A
bcmd_lit32:
	movsx rax, dword ptr [r8]
	add r8, 4
	push rax
	jmp _next

b_lit64 = 0x0B
bcmd_lit64:
	mov rax, [r8]
	add r8, 8
	push rax
	jmp _next

b_branch8 = 0x10
bcmd_branch8:
	movsx rax, byte ptr [r8]
	add r8, rax
	jmp _next

b_branch16 = 0x11
bcmd_branch16:
	movsx rax, word ptr [r8]
	add r8, rax
	jmp _next

b_qbranch8 = 0x12
bcmd_qbranch8:
	pop rax
	or rax, rax
	jnz bcmd_branch8
	inc r8
	jmp _next

b_qbranch16 = 0x13
bcmd_qbranch16:
	pop rax
	or rax, rax
	jnz bcmd_branch16
	inc r8
	inc r8
	jmp _next

b_dup = 0x18
bcmd_dup:
	push [rsp]
	jmp _next

b_wm = 0x20
bcmd_wm:
	decq [rsp]
	jmp _next
