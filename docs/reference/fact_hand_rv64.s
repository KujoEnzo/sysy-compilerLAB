	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.file	"fact_hand.ll"
	.globl	fact                            # -- Begin function fact
	.p2align	1
	.type	fact,@function
fact:                                   # @fact
	.cfi_startproc
# %bb.0:                                # %entry
	mv	a1, a0
	li	a0, 1
	li	a2, 2
	blt	a1, a2, .LBB0_2
.LBB0_1:                                # %body
                                        # =>This Inner Loop Header: Depth=1
	mulw	a0, a0, a2
	addiw	a2, a2, 1
	bge	a1, a2, .LBB0_1
.LBB0_2:                                # %exit
	ret
.Lfunc_end0:
	.size	fact, .Lfunc_end0-fact
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -16
	.cfi_def_cfa_offset 16
	sd	ra, 8(sp)                       # 8-byte Folded Spill
	.cfi_offset ra, -8
	call	getint@plt
	call	fact@plt
	call	putint@plt
	li	a0, 10
	call	putch@plt
	li	a0, 0
	ld	ra, 8(sp)                       # 8-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
