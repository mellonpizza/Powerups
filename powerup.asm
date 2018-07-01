
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Custom powerups patch by MarioE
; Asar version by Lui37
; Modified by LX5
; 
; This does exactly what the title says and it adds in some more very useful
; stuff.
;
; Absolutely no credit required.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro insert_gfx(filename,add)
	org ($00A304+!base3+($<add>*3))
		if read2($00D067|!base3) == $DEAD
			autoclean dl <filename>_gfx
		else
			dl <filename>_gfx
		endif
	warnpc $00A38B|!base3
freedata
	<filename>_gfx:
		incbin powerups_files/graphics/<filename>.bin
endmacro

macro insert_extra_gfx(filename,add)
	org ($00F63A+!base3+($<add>*3))
		if read2($00D067|!base3) == $DEAD
			autoclean dl <filename>_gfx
		else
			dl <filename>_gfx
		endif
	warnpc $00F69F|!base3
freedata
	<filename>_gfx:
		incbin powerups_files/graphics/<filename>.bin
endmacro

macro insert_palette(filename)
	incbin powerups_files/powerup_misc_data/palette_files/<filename>.mw3:10C-120
endmacro

macro insert_big_gfx(filename,add)
    org ($00A304+!base3+($<add>*3))
		if read2($00D067|!base3) == $DEAD
			autoclean dl <filename>_gfx
		else
			dl <filename>_gfx
		endif
    warnpc $00A38B|!base3
        incbin powerups_files/graphics/<filename>.bin -> <filename>_gfx
endmacro

macro protect_data(filename)
	prot <filename>_gfx
endmacro

macro insert_addon_code(filename)
	incsrc powerups_files/addons/<filename>.asm
endmacro

macro insert_addon_hack(filename)
	incsrc powerups_files/addons/hijacks/<filename>.asm
endmacro


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Defines, do not edit these
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!a = autoclean

	incsrc powerup_defs.asm


if !i_read_the_readme == 0
	print "Custom powerups patch."
	print "Version 3.1.0"
	print ""
	print "Nothing was inserted."
	print "Please read the Readme file included in this patch."
else

if !SA1 = 1
	sa1rom
endif
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hijacks, do not edit these
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/hijacks/main_engine.asm
	incsrc powerups_files/hijacks/image_engine.asm
	incsrc powerups_files/hijacks/mario_exgfx_engine.asm
	incsrc powerups_files/hijacks/item_gfx_engine.asm
	incsrc powerups_files/hijacks/dma_engine.asm
	incsrc powerups_files/hijacks/control_hack.asm
	incsrc powerups_files/hijacks/palette_engine.asm
	incsrc powerups_files/hijacks/walking_frames_code.asm
	incsrc powerups_files/hijacks/spin_jump_edit.asm
	incsrc powerups_files/hijacks/goal_tape_item_engine.asm
	incsrc powerups_files/hijacks/clear_7E2000.asm
	incsrc powerups_files/hijacks/shell_immunity_code.asm
	incsrc powerups_files/hijacks/custom_collision_engine.asm
	incsrc powerups_files/hijacks/cape_engine.asm
	incsrc powerups_files/hijacks/item_box_engine.asm
	incsrc powerups_files/hijacks/custom_interaction_engine.asm
	incsrc powerups_files/hijacks/ride_yoshi.asm
	incsrc powerups_files/hijacks/instant_kill_flag.asm
	incsrc powerups_files/hijacks/ducking_flag.asm
	incsrc powerups_files/hijacks/slide_flag.asm
	incsrc powerups_files/hijacks/water_splash_edit.asm
	incsrc powerups_files/hex_edits.asm
	incsrc powerups_files/ow_mario.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add-on hijacks installer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/addon_hijack_installer.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00A38B|!base3
	if read1($00D067|!base3) == $DEAD
		autoclean dl powerup_items
	else
		dl powerup_items
	endif

org $00A304|!base3
	PowerupGFX:
org $00F63A|!base3
	ExtraTilesGFX:

freecode
	prot powerup_items

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prot area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	%protect_data(small_mario)
	%protect_data(big_mario)
	%protect_data(hammer_mario)
	%protect_data(boomerang_mario)
	%protect_data(raccoon_mario)
	%protect_data(tanooki_mario)
	%protect_data(frog_mario)
	%protect_data(mini_mario)
	%protect_data(penguin_mario)
	%protect_data(propeller_mario)
	%protect_data(shell_mario)
	%protect_data(cape_tiles)
	%protect_data(tail_tiles)
	%protect_data(propeller_tiles)
	%protect_data(cloud_tiles)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Powerup code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	incsrc powerups_files/main_engine.asm
	%foreach2("powerup_",": : incsrc powerups_files/powerup_main_code/powerup_",".asm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle player tile data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/image_engine.asm
	%foreach2("powerup_","_img: : incsrc powerups_files/powerup_image_code/powerup_",".asm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Goal tape hax.
; Modifies the routine that gives an item if you carry a sprite after touching
; the goal tape.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/goal_tape_item_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disable certain controls as per the mask.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/control_hack.asm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear almost 22000 bytes of RAM. Note that certain portions should NOT
; be used.
;  - Original patch
; Dunno why the patch says this, clearing all of the RAM doesn't seem to do
; anything bad... besides glitching the berries due to their tiles are in GFX32.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		if read1($009750|!base3) == $20
	incsrc powerups_files/clear_7E2000.asm
		endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle player tile GFX pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/mario_exgfx_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle player palette
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/palette_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle player GFX DMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/dma_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle spin jump ability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/spin_jump_edit.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle powerup item gfx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/item_gfx_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shell immunity stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/shell_immunity_code.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle walking frames
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/walking_frames_code.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle custom collision engine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/custom_collision_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle cape stuff.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/cape_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear some RAM when Mario's hurt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/instant_kill_flag.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle Mario's riding yoshi status
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/ride_yoshi.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle Mario's ducking status
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/ducking_flag.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle Mario's sliding status
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/slide_flag.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle item box stuff.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/item_box_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle custom interaction with sprites.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/custom_interaction_engine.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Edits water splash effect.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incsrc powerups_files/water_splash_edit.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Random Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PowerupData:
	incsrc powerups_files/powerup_misc_data/gfx_index.asm
	incsrc powerups_files/powerup_misc_data/palette.asm
	incsrc powerups_files/powerup_misc_data/tilemaps.asm
	incsrc powerups_files/powerup_misc_data/goal_sprites.asm
	incsrc powerups_files/powerup_misc_data/spin_jump.asm
	incsrc powerups_files/powerup_misc_data/walk_frames.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add-ons incsrc area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	incsrc powerups_files/addon_code_installer.asm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freedata
powerup_items:
	incbin powerups_files/graphics/powerup_items.bin

	incsrc powerups_files/powerup_gfx.asm

if read2($00D067|!base3) != $DEAD
	org $00D067|!base3
	install_byte:
		dw $DEAD
endif

print "Custom powerups patch."
print "Version 3.1.0"
print ""
print "Inserted ", freespaceuse, " bytes"
endif