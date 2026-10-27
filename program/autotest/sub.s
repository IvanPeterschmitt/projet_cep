# TAG = sub
	.text

	sub x31, x31, x0    #test soustraction de x31 (=0) et x0 (=0)
	addi x1, x1, 0xa    #chargement d'une valeur (=10) dans x1 
	addi x29, x29, 0x123
	sub x31, x29, x1    #test soustraction de x29 (=0x123) et x1 (=10)
	sub x31, x31, x31   #test soustraction de x31 avec x31

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000119
	# 00000000
	# pout_end
