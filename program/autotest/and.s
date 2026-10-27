# TAG = and
	.text

	and x31, x31, x31
	addi x30, x30, 0x123
	addi x1, x1, 0x124
	and x31, x1, x30
	addi x1, x1, -1
	and x31, x1, x30

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000120
	# 00000123
	# pout_end
