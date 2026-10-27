# TAG = sw
	.text

	la x30, test
	addi x31, x31, 256
	sw x31, (x30)
	addi x31, x31, 10
	lw x31, (x30)

	# max_cycle 50
	# pout_start
	# 00000100
	# 0000010A
	# 00000100
	# pout_end
	
test: .word 0
