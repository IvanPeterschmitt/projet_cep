# TAG = lh
	.text

	la x30, test
	li x31, 0x280A5
	sw x31, 0(x30)
	addi x31, x31, 10
	lh x31, 0(x30)

	# max_cycle 50
	# pout_start
	# 00028000
	# 000280A5
	# 000280AF
	# FFFF80A5
	# pout_end
	
	
test: .word 0
