# TAG = jalr
	.text


	addi x31, x31, 10
	lui x30, 1
	jalr x31, 24(x30)
	addi x31, x31, 2
	addi x31, x31, 4
	addi x31, x31, 8
	xor x31, x31, x31
	addi x31, x31, 16
	
	

	# max_cycle 50
	# pout_start
	# 0000000A
	# 0000100C
	# 00000000
	# 00000010
	# pout_end
