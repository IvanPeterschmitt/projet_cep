# TAG = slti
	.text

	xor x31, x31, x31
	addi x29, x29, -2
	slti x31, x29, 20
	addi x29, x29, 22
	slti x31, x29, 20
	addi x29, x29, 1
	slti x31, x29, 20

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000001
	# 00000000
	# 00000000
	# pout_end
