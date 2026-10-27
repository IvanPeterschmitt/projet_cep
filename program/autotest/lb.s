# TAG = lb
	.text

	la x30, test
	li x31, 0x12A5
	sw x31, 0(x30)
	addi x31, x31, 10
	lb x31, 0(x30)

	# max_cycle 50
	# pout_start
	# 00001000
	# 000012A5
	# 000012AF
	# FFFFFFA5
	# pout_end
	
	
test: .word 0
