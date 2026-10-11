	.text
	.align 1
	.globl fact
	.type fact, @function
fact:
	# RV64 integer calling convention:
	#   a0 = sign-extended int n on entry, and int return value on exit.
	# This leaf function calls nobody, so it needs no stack frame.
	li      t0, 2                  # int i = 2
	li      t1, 1                  # int result = 1
.Lfact_loop:
	blt     a0, t0, .Lfact_done    # signed test: if (n < i) break
	mulw    t1, t1, t0            # 32-bit int multiplication
	addiw   t0, t0, 1             # 32-bit int increment
	j       .Lfact_loop
.Lfact_done:
	mv      a0, t1
	ret
	.size fact, .-fact

	.align 1
	.globl main
	.type main, @function
main:
	# main is non-leaf. Keep sp 16-byte aligned and preserve ra.
	addi    sp, sp, -16
	sd      ra, 8(sp)

	call    getint                 # a0 = getint()
	call    fact                   # a0 = fact(a0)
	call    putint                 # putint(a0)
	li      a0, 10
	call    putch                  # putch('\n')

	li      a0, 0                  # return 0
	ld      ra, 8(sp)
	addi    sp, sp, 16
	ret
	.size main, .-main

	.section .note.GNU-stack,"",@progbits
