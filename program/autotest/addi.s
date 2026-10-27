# TAG = addi
	.text

	addi x31, x0, 0x1    #Test addition de x0 (=0) avec 1
	addi x1, x31, 0xa    #Test addition de x1 (=0) avec 10
	addi x31, x1, 0x1    #Test addition de 
	addi x31, x31, 0x3

	# max_cycle 50
	# pout_start
	# 00000001
	# 0000000C
	# 0000000F
	# pout_end
