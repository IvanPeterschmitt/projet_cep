# TAG = jal
	.text

debut:
	addi x31, x31, 10
	jal x30, enfaitnoncetaitpaslafin
fin:
	xor x31, x31, x31
	jal vraifinparcequecellelacestpaslavraie
enfaitnoncetaitpaslafin:
	addi x31, x31, -2
	jal fin
vraifinparcequecellelacestpaslavraie:
	addi x31, x31, 72
	mv x31, x30
	

	# max_cycle 50
	# pout_start
	# 0000000A
	# 00000008
	# 00000000
	# 00000048
	# 00001008
	# pout_end
