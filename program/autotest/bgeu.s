# TAG = bgeu
	.text

debut:
	addi x31, x31, -10
	addi x30, x30, 11
	bgeu x31, x30, fin
	addi x31, x31, 50
	j debut
fin:
	xor x31, x31, x31
	addi x31, x31, 1234

	# max_cycle 50
	# pout_start
	# FFFFFFF6
	# 00000000
	# 000004D2
	# pout_end
