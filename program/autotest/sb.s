# TAG = sb
	.text

	la x30, test
	li x31, 0x100
	sb x31, (x30)
	addi x31, x31, 10
	lw x31, (x30)

	# max_cycle 50
	# pout_start
	# 00000100
	# 0000010A
	# 00000000
	# pout_end
	
	
test: .word 0
