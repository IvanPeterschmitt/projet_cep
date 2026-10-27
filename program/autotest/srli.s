# TAG = srli
	.text

	srl x31, x31, 0x0       #test décalage de 0 bits vers la droite dans x31     
	srl x31, x31, 0x1       #test de décalage de 1 bit sur x31 (=0)
	addi x31, x31, 0x0123  #on met x31 à 00000123
	srl x31, x31, 0x1      #test de décalage de 1 bit à gauche de x31
	srl x31, x31, 0x2       #test de décalage de 2 bits vers la gauche de x31
	xor x31, x31, x31
	addi x31, x31, -100
	srl x31, x31, 0x2

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000000
	# 00000123
	# 00000091
	# 00000024
	# 00000000
	# FFFFFF9C
	# 3FFFFFE7
	# pout_end
