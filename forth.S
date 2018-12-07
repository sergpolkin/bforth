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
	len = . - msg

.section .data
bcmd:
	.quad bcmd_bad, bcmd_bye, bcmd_bad, bcmd_bad, bcmd_bad, bcmd_bad, bcmd_bad, bcmd_bad

prog_start:
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
