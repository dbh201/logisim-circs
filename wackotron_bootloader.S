_start:
	lui a0,0x20000# LED MMIO
	mv a1,x0			# LED status register
	ori  a1, a1, 1
	sw a1, 0(a0)

	lui t2, 0x80000 	#destination 	0x80000000
	lui t1, 0x12c00	#size<<12
	srli t1, t1, 12	#shift right to adjust for lui

	lui s11, 0x84000	#buffer

	lui t5, 0x10000 	#source(bus)	0x10000000




	xor t3, t3, t3		#generic counter



	mv t0, t1				#vram bytes

	mv t4, t2
	j _skip_clear_vram
	lui t6, 0xFF000
	mv t6, x0
	_clear_vram:
		sw t6, 0(t4)
		srli t6, t6, 8
		addi t3, t3, 0x04
		add t4, t2, t3
		sw t6, 0(t4)
		srli t6, t6, 8
		addi t3, t3, 0x04
		add t4, t2, t3
		sw t6, 0(t4)
		srli t6, t6, 8
		addi t3, t3, 0x04
		add t4, t2, t3
		sw t6, 0(t4)
		lui t6, 0xFF000
		mv t6, x0
		addi t3, t3, 0x04
		add t4, t2, t3
		blt t3, t1, _clear_vram
	_skip_clear_vram:
	ori a1, a1, 2
	sw a1, 0(a0)

	mv t6, x0
	lui s9, 0x000A0	 	# pixels per scanline
	srli s9, s9, 12
	mv s7, x0				# pixels written in current scanline
	lui s8, 0x000A0		# hblank in pixels
	srli s8, s8, 12
	lui s6, 0x00050		# total hblank offset counter
	srli s6, s6, 12
	add t2, t2, t1
	addi t2, t2, -640
	mv t3, x0
	lui t1, 0xE100
	srli t1, t1, 12
	# MEMORY LAYOUT:
	# BB GG RR 00
	# 0x00RRGGBB
	_load_store:
		add t4, t2, t3 	# t4 vram destination address
		add t4, t4, s6		# scanline offset
		addi t3, t3, 54 	# skip header for file load (54 bytes)
		sw t3, 0(t5)
		lw t6, 0(t5)
		sw t6, 0(s11)
		addi t3, t3, 0x04
		sw t3, 0(t5)
		lw t6, 0(t5)
		sw t6, 4(s11)
		addi t3, t3, 0x04
		sw t3, 0(t5)
		lw t6, 0(t5)
		sw t6, 8(s11)
		addi t3, t3, -50	#reset for vram store (-54 + 4 for increment)

		#pixel 1
		mv t6, x0
		#not t6, t6 #set to 0xFFFFFFFF and override later
		sb t6, 3(t4)
		#red
		lbu s10, 1(s11)
		slli s10, s10, 16
		or t6, t6, s10
		#green
		lbu s10, 0(s11)
		slli s10, s10, 8
		or t6, t6, s10
		#blue
		lbu s10, 2(s11)
		or t6, t6, s10
		sw t6, 0(t4)

		#pixel 2
		mv t6, x0
		#not t6, t6
		#red
		lbu s10, 4(s11)
		slli s10, s10, 16
		or t6, t6, s10
		#green
		lbu s10, 3(s11)
		slli s10, s10, 8
		or t6, t6, s10
		#blue
		lbu s10, 5(s11)
		or t6, t6, s10
		sw t6, 4(t4)

		#pixel 3
		mv t6, x0
		#not t6, t6
		#red
		lbu s10, 7(s11)
		slli s10, s10, 16
		or t6, t6, s10
		#green
		lbu s10, 6(s11)
		slli s10, s10, 8
		or t6, t6, s10
		#blue
		lbu s10, 8(s11)
		or t6, t6, s10
		sw t6, 8(t4)

		#pixel 4
		mv t6, x0
		#not t6, t6
		#red
		lbu s10, 10(s11)
		slli s10, s10, 16
		or t6, t6, s10
		#green
		lbu s10, 9(s11)
		slli s10, s10, 8
		or t6, t6, s10
		#blue
		lbu s10, 11(s11)
		or t6, t6, s10
		sw t6, 12(t4)

		addi s7, s7, 4
		bltu s7, s9, _no_scanline_offset_inc
			mv s7, x0
			add s6, s6, s8
			addi t2, t2, -1280
			blt x0, t2, 		# I complete forget what I was doing
		bltu t3, t1, _load_store

	ori a1, a1, 4
	sw a1, 0(a0)

	_finish:
		lui a2, 0x00002
		srli a2, a2, 4
		_finish_loop:
			addi a2, a2, -1
			bltu x0, a2, _finish_loop
			xori a1, a1, 0x200
			sw a1, 0(a0)
			lui a2, 0x00001
			srli a2, a2, 5
			j _finish

	_copy_fail:
		lui a2, 0x00004
		srli a2, a2, 5
		_copy_fail_loop:
			addi a2, a2, -1
			bnez a2, _copy_fail_loop
			xor a1, a1, t2
			sw a1, 0(a0)
			j _copy_fail

# dead code dungeon

	mv t2, s6
	xor t3, t3, t3
	add t4, t2, t3
	# check values
	_check_store:
		sw t3, 0(t5)
		lw t6, 0(t5)
		lw s1, 0(t4)
		bne t6, s1, _copy_fail
		addi t3, t3, 0x04
		add t4, t2, t3
		blt t3, t1, _check_store
		ori a1, a1, 4


	xori a1, a1, 0x100 	#clock disable; re-enable by flipping the DIP switch
	sw a1, 0(a0)


# expand 4 bytes of 24-bit RGB to 3 pixels 32-bit ARGB
		sw t3, 0(t5)
		lw t6, 0(t5)
		sw t6, 4(s11)
		addi t3, t3, 0x04
		sw t3, 0(t5)
		lw t6, 0(t5)
		sw t6, 4(s11)
		addi t3, t3, 0x04
		sw t3, 0(t5)
		lw t6, 0(t5)
		sw t6, 8(s11)
		addi t3, t3, 0x04

		# gross...
		addi t6, t6, -1
		sb t6, 0(t4)
		lbu t6, 0(s11)
		sb t6, 1(t4)
		lbu t6, 1(s11)
		sb t6, 2(t4)
		lbu t6, 2(s11)
		sb t6, 3(t4)

		addi t6, t6, -1
		sb t6, 4(t4)
		lbu t6, 3(s11)
		sb t6, 5(t4)
		lbu t6, 4(s11)
		sb t6, 6(t4)
		lbu t6, 5(s11)
		sb t6, 7(t4)


		addi t6, t6, -1
		sb t6, 8(t4)
		lbu t6, 6(s11)
		sb t6, 9(t4)
		lbu t6, 7(s11)
		sb t6, 10(t4)
		lbu t6, 8(s11)
		sb t6, 11(t4)
