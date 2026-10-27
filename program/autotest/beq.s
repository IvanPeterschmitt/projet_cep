# TAG = beq
	.text

debut:
	addi x31, x31, 10
	addi x30, x30, 11
	beq x31, x30, fin
	addi x31, x31, 2
	j debut
fin:
	xor x31, x31, x31
	addi x31, x31, 1234

	# max_cycle 50
	# pout_start
	# 0000000A
	# 0000000C
	# 00000016
	# 00000000
	# 000004D2
	# pout_end
