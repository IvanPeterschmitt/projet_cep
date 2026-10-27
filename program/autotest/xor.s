# TAG = xor
	.text

	xor x31, x31, x31
	addi x30, x30, 0x123
	addi x29, x29, 0x236
	xor x31, x29, x30
	addi x29, x29, 10
	xor x31, x29, x30

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000315
	# 00000363
	# pout_end
