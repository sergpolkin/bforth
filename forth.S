.intel_syntax noprefix
.section .data
msg:
.ascii "Hello, world!\n"
len = . - msg
.section .text
.global _start
_start:
	mov rax, 1
	mov rdi, 1
	mov rsi, OFFSET FLAT:msg
	mov rdx, len
	syscall

	mov rax, 60
	xor rdi, rdi
	syscall