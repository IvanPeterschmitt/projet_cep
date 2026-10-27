# TAG = blt
	.text

debut:
	addi x31, x31, 11
	addi x30, x30, -10
	blt x31, x30, fin
	addi x31, x31, -50
	j debut
fin:
	xor x31, x31, x31
	addi x31, x31, 1234

	# max_cycle 50
	# pout_start
	# 0000000B
	# FFFFFFD9
	# FFFFFFE4
	# 00000000
	# 000004D2
	# pout_end
