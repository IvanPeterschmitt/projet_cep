# TAG = lw
	.text

	la x30, test
	addi x31, x31, 1
	sw x31, 0(x30)
	addi x31, x31, 1
	lw x31, 0(x30)

	# max_cycle 50
	# pout_start
	# 00000001
	# 00000002
	# 00000001
	# pout_end
	
	
test: .word 0
