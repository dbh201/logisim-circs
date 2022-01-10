.section NoName
.org 0x00000FC0
_start:
lui t0, 0x10000 		#	t0 = BOOTROM
addi t0, t0, 0x30		#	write to set offset, read to get data
lui t1, 0x83444		# 	bytes to load 
srli t1, t1, 12
# needs to be shorter than 4kB so that it doesn't overwrite
# this initialisation code

lui t2, 0x80200
mv t4, x0
add t1, t1, t2
_load_loop:
	sw t4, 0(t0)
	lw t3, 0(t0)
	sw t3, 0(t2)
	addi t4, t4, 4
	addi t2, t2, 4
	bltu t2, t1, _load_loop
lui t2, 0x80200
jr t2
