# TAG = slli
	.text

	sll x31, x31, 0x0       #test décalage de 0 bits vers la gauche dans x31      
	sll x31, x31, 0x1       #test de décalage de 1 bit sur x31 (=0)
	addi x31, x31, 0x0123  #on met x31 à 00000123
	sll x31, x31, 0x1       #test de décalage de 1 bit à gauche de x31
	sll x31, x31, 0x2       #test de décalage de 2 bits vers la gauche de x31

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000000
	# 00000123
	# 00000246
	# 00000918
	# pout_end
