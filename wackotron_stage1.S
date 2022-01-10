.section NoName
.org 0x00000FC0
_start:
lui t0, 0x10000 		#	t0 = BOOTROM
addi t0, t0, 0x30		#	write to set offset, read to get data
lui t1, 0x00390		# 	4 byte words to load 
# needs to be shorter than 4kB so that it doesn't overwrite
# this initialisation code
srli t1, t1, 12
mv t2, x0
_load_loop:
	sw t2, 0(t0)
	lw t3, 0(t0)
	sw t3, 0(t2)
	addi t2, t2, 4
	bltu t2, t1, _load_loop
jr x0
