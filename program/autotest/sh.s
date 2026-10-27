# TAG = sh
	.text
	
	la x30, test
	li x31, 0x12345
	sh x31, (x30)
	addi x31, x31, 10
	lw x31, (x30)

	# max_cycle 50
	# pout_start
	# 00012000
	# 00012345
	# 0001234F
	# 00002345
	# pout_end
	
test: .word 0
