
.cat_suit
	lda #$00
	sta !extra_tile_flag
	sta !extra_tile_frame
	
	lda !power_ram+2
	beq +
	lda !power_ram+6
	beq +
	lda !power_ram+5
	sta $7D
+	
	lda !power_ram+10
	beq +
	lda !power_ram+8
	sta $7D
	lda !power_ram+9
	sta $7B
	lda #$00
	sta !power_ram+10
+	
	
	lda !power_ram
	beq +
	sta $13E0|!base2
	sec
	sbc #$46
	bmi +
	cmp #$02
	bcs +
	sta $00
	tax

	lda ..tiles,x
	sta !extra_tile_frame

	ldx $76
	lda ..settings,x
	sta !extra_tile_flag

	lda $76
	asl
	tay 

	lda $00
	asl
	tax

	rep #$20
	lda ..y_disp,x
	sta !extra_tile_offset_y

	tyx
	lda ..x_disp,x
	sta !extra_tile_offset_x
	sep #$20	
	
	
+	
	rts

..settings
	db $01,$41
..y_disp
	dw $0008,$0010
..x_disp
	dw $FFE8,$0018
..tiles
	db $02,$04