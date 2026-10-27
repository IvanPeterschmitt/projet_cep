# TAG = sltu
	.text

	xor x31, x31, x31
	addi x29, x29, -2
	addi x30, x30, 20
	sltu x31, x29, x30
	addi x29, x29, 22
	sltu x31, x29, x30
	addi x29, x29, -10
	sltu x31, x29, x30

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000000
	# 00000000
	# 00000001
	# pout_end
