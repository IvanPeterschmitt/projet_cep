# TAG = auipc
	.text

	auipc x31, 0       #test de la valeur initiale de pc
	auipc x31, 0x1     #test incrémentation de 0x00001000
	auipc x31, 0x01230 #test incrémentation de 0x01230000

	# max_cycle 50
	# pout_start
	# 00001000
	# 00002004
	# 01231008
	# pout_end
