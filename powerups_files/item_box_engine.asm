;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Item Box Special - Version 1.1, by imamelia
;;
;; This patch allows you to do several things with the
;; item box.  See the readme for details.
;;
;; Credit to Kenny3900 for the original Item Box GFX Fix patch.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro flower_item(num,sfx,port)
	lda #$20
	sta $149B|!base2
	sta $9D
	lda #$04
	sta $71
	lda #<num>
	sta $19
	lda #$00
	sta !clipping_flag
	sta !collision_flag
	lda #$04
	ldy !1534,x
	bne +
	jsl $02ACE5|!base3
+	
	lda #<sfx>
	sta <port>|!base2
	jmp clean_ram
endmacro

macro cape_item(num,sfx,port)
	lda #$00
	sta !clipping_flag
	sta !collision_flag
	lda #<num>
	sta $19
	lda #<sfx>
	sta <port>|!base2
	lda #$04
	jsl $02ACE5|!base3
	jsl $01C5AE|!base3
	inc $9D
	jmp clean_ram
endmacro	


freecode

Statuses:			; sprite statuses, 4 possible
db $08,$01,$09,$00	; normal, init, stunned, nonexistent

CheckItem:
	phb
	phk
	plb 
	
	stz !1528,x

	lda !190F,x
	bmi .custom
	lda !9E,x
	sec 
	sbc #$74
	bra .next
.custom		
	lda !7FAB9E,x
	sec	
	sbc.b #!starting_slot
	clc 
	adc #$05
.next		
		
if !SA1		
	sta $2251
	lda #!max_powerup+1
	sta $2253
	lda #$00
	sta $2250
	sta $2252
	sta $2254
	xba 
	lda $19
	clc
	rep #$30
	adc $2306
else		
	sta $4202
	lda #!max_powerup+1
	sta $4203
	lda #$00
	xba 
	lda $19
	clc
	rep #$30
	adc $4216
endif
	tay	
	sep #$20
	lda.w PutInBox,y
	beq .noitem
	sta $00
	cmp #$01
	bne .store
	lda $0DC2|!base2
	beq .store
	cmp #$02
	bcs .noitem
.store		
	lda #$0B
	sta $1DFC|!base2
	lda $00
	sta $0DC2|!base2

if !dynamic_items == 1
	tax
	lda.l dynamic_item_tiles-1,x
	xba
	rep #$20
	and #$FF00
	lsr #3
	adc #powerup_items
	sta !item_gfx_pointer+4
	clc 
	adc #$0200
	sta !item_gfx_pointer+10
	sep #$20
	ldx $15E9
	lda !item_gfx_refresh
	ora #$01
	sta !item_gfx_refresh
endif

.noitem
	lda.w PowerIndex,y
	sep #$10
	plb
	cmp #$06
	bcs .notoriginal
.run_original
	cmp #$01
	beq +
	pha
	lda #$00
	sta !clipping_flag
	sta !collision_flag
	pla 
+	
	jml $01C550|!base3
.notoriginal	
	sec 
	sbc #$06
	pha 
	clc
	adc #$04
	cmp $19
	bne +
	pla 	
	jmp GiveNothing
+		
	pla
	jsl $0086DF|!base3

.PowerupPointers
	incsrc powerup_misc_data/get_powerup_codes.asm

GiveNothing:	
Return:		
clean_ram:	
	lda #$00
	sta !disable_spin_jump
	sta !mask_15
	sta !mask_17
	sta !flags
	sta !timer
	sta !misc
	sta !shell_immunity
	sta !cape_settings
	jml $01C560|!base3

ItemBoxFix:
	phx			;
	php			;
	lda !item_box_disable	; check the item disable RAM (duh)
	and #$02		; if bit 1 is set...
	bne NoDraw		; don't draw the item in the box
	ldy $01			; $01, I guess, holds the OAM index for the item tile?
	;lda #$00			; 00 --> A
	;xba			; clear the high byte of A
	lda #!ItemPosX1		;
	sta $0200|!base2,y	; set the X position of the item
	lda #!ItemPosY1		;
	sta $0201|!base2,y	; set the Y position of the item
	lda $0DC2|!base2	; use the value of the item box to determine
	rep #$30			; the item tile number and properties
	and #$00FF
	asl			; item number x2, because we're loading both bytes
	tax			; result into X
	lda.l ItemTilemap,x	; load the item tilemap and properties
	sta $0202|!base2,y	; store to extended OAM
NoDraw:				;
	plp			;
	plx 			;
	jml $0090C7|!base3	; finish with original code
NoItem:				;
	rtl			;

ActivateEffect:
	jsr ExecuteEffectPointer	;
	jmp EndItemDrop

ItemBoxDrop:
	lda !item_box_disable	; if the item box drop is disabled...
	and #$01		; (i.e. bit 0 of the disable RAM is set)
	bne NoItem		; treat the item box as if it were empty
	lda $0DC2|!base2	; load the item box value
	beq NoItem		; if it is zero, then the player has no item

	phx : phy : phb : phk : plb

	ldy $0DC2|!base2	; index all tables by Y, since X will have our sprite index
	lda.w Settings,y		; check the settings table
	bmi ActivateEffect		; if bit 7 is set, activate an effect instead of spawning a sprite

	lda #$0C			; play a sound effect
	sta $1DFC|!base2	; item box drop sound

	jsr FindFreeSlot		; find a free sprite slot

	phy			; preserve the table index
	lda.w Settings,y		; check the settings table
	and #$03		; use bits 0 and 1
	tay			; to determine the sprite status
	lda.w Statuses,y		;
	sta !14C8,x		; set the spawned sprite status
	ply			; pull back the table index

	lda.w Settings,y		; check the settings table
	and #$10		; if bit 4 is set...
	bne SpawnCustom		; we're spawning a custom sprite

SpawnNormal:			;
	lda.w SpriteNumber,y		;
	sta !9E,x			; set the sprite number
	phy			;
	jsl $07F7D2|!base3		; reset sprite tables
	ply			;
	lda !9E,x
	cmp #$19
	bne NotMessage
	lda #$09
	sta !14C8,x
	lda #$3E
	sta !9E,x
	phy			;
	jsl $07F7D2|!base3		; reset sprite tables
	ply		;
	lda #$01
	sta !151C,x
	lda $018467|!base3
	sta !15F6,x
	bra FinishSpawn		; finish the spawning routine

NotMessage:
	lda !9E,x
	cmp #$3E
	bne NotPSwitch
	stz !151C,x
	lda $018466|!base3
	bra FinishSpawn

NotPSwitch:
	lda !9E,x
	cmp #$53
	bne NotThrowBlock
	lda #$FF
	sta !1540,x

NotThrowBlock:
	bra FinishSpawn

SpawnCustom:		;
	lda.w SpriteNumber,y		;
	sta !7FAB9E,x		; set the sprite number
	phy			;
	jsl $07F7D2|!base3	; reset sprite tables
	jsl $0187A7|!base3	; get new table values for custom sprites
	ply			;
	lda Settings,y		;
	and #$0C		; get bits 2 and 3 of the settings table
	ora #$80			;
	sta !7FAB10,x		; store to sprite extra bit table

FinishSpawn:		;
	lda #!ItemPosX2		; base X position
	clc			;
	adc $1A			; add the screen position so that the sprite
	sta !E4,x			; always spawns relative to the screen
	lda $1B			; screen position high byte
	adc #$00		; handle overflow
	sta !14E0,x		;

	lda #!ItemPosY2		; base Y position
	clc			;
	adc $1C			; add the screen position so that the sprite
	sta !D8,x		; always spawns relative to the screen
	lda $1D			; screen position high byte
	adc #$00		; handle overflow
	sta !14D4,x		;

	lda.w Settings,y		; check the settings
	and #$20		; if bit 5 is set...
	beq EndItemDrop		; then increment a certain sprite table so the sprite will flash as it drops
	inc !1534,x		; This was done in the original SMW only with the mushroom and flower.
EndItemDrop:			;

	lda.w Settings,y
	and #$40
	beq .no_init_powerups

	stx $15E9|!base2
	lda #$01
	sta $02
	;jsl update_tilemap
	jsl init_item

.no_init_powerups

	stz $0DC2|!base2
	plb : ply : plx
	rtl

FindFreeSlot:		;
	ldx #$0B	; 12 sprites to loop through
SlotLoop:		;
	lda !14C8,x	; check the sprite status of the sprite in this slot
	beq FoundSlot	; if 00, then the slot is free
	dex		; decrement the index
	bpl SlotLoop	; loop if there are more slots to check
	dec $1861|!base2	; if none of the 12 sprite slots are free, then decrement...something.
	bpl FoundSlot	; I'm guessing $1861 has something to do with holding the oldest sprite index...
	lda #$01		; reset it if necessary
	sta $1861|!base2	; The way this subroutine works, there will *always* be a sprite slot for the item,
FoundSlot:		; even if it means overwriting another one.
	rts		; That's why I couldn't just use $02A9DE or $02A9E4 to get a free slot.

ClearDisable:
	lda #$00			;
	sta !item_box_disable	; clear all disable flags
	sta !item_gfx_refresh
	dec $0DB1|!base2	; restore
	bpl EndOWCode		; hijacked code
	jml $009F74|!base3		;
EndOWCode:		;
	jml $009F6E|!base3		;

ExecuteEffectPointer:
	lda.w SpriteNumber,y		; load the sprite number (or, in this case, the effect number)
	phx			; preserve X, because there is a very likely chance that it is already being used
	asl			; multiply the base value to get the desired index
	tax			; put the resulting value into X
	rep #$20			; set A to 16-bit
	lda.w EffectPointers,x	; load value from effect pointer table
	sta $0A			; and store that to scratch RAM
	sep #$20			; set A back to 8-bit
	plx			; pull X register back
	jmp ($000A|!base1)	; jump to address that was stored

EffectPointers:			;
	dw Effect00		;
	dw Effect01		;
	dw Effect02		;
	dw Effect03		;
	dw Effect04		;
	dw Effect05		;
	dw Effect06		;
	dw Effect07		;
	dw Effect08		;
	dw Effect09		;
	dw Effect0A		;
	dw Effect0B		;
	dw Effect0C		;
	dw Effect0D		;
	dw Effect0E		;
	dw Effect0F		;

Effect00:			;
Effect01:			;
Effect02:			;
Effect03:			;
Effect04:			;
Effect05:			;
Effect06:			;
Effect07:			;
Effect08:			;
Effect09:			;
Effect0A:			;
Effect0B:			;
Effect0C:			;
Effect0D:			;
Effect0E:			;
Effect0F:			;
RTS

incsrc powerup_misc_data/item_box_tables.asm