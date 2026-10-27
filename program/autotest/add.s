# TAG = add
	.text

	add x31, x31, x0    #test addition de x31 (=0) et x0 (=0)
	addi x1, x1, 0xa    #chargement d'une valeur (=10) dans x1 
	add x31, x1, x31    #test addition de x31 (=0) et x1 (=10)
	add x31, x31, x31   #test addition de x31 avec x31

	# max_cycle 50
	# pout_start
	# 00000000
	# 0000000A
	# 00000014
	# pout_end
