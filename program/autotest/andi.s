# TAG = andi
	.text

	andi x31, x31, 0x0
	addi x29, x29, 0x236
	andi x31, x29, 0x123
	addi x29, x29, 10
	andi x31, x29, 0x564

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000022
	# 00000040
	# pout_end
