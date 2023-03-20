;-------------------------------------------------------------------------------
; [$20-$2F] Core Game State
;-------------------------------------------------------------------------------

.scope Game
  ; Holds major flags for the game. Bit 7 indicates to the NMI handler that
  ; state update are complete and the VRAM can be updated. Bits 0-6 are currently
  ; unused.
  FLAGS = $20

  .proc init
    jsr init_palettes
    jsr init_sprites
    jsr init_nametable
    rts
  .endproc

  .proc init_palettes
    bit PPU_STATUS
    lda #$3F
    sta PPU_ADDR
    lda #$00
    sta PPU_ADDR
    ldx #0
  @loop:
    lda palettes, x
    sta PPU_DATA
    inx
    cpx #32
    bne @loop
    rts
  palettes:
    .byte $0F, $17, $18, $07    ; Grass / Dirt
    .byte $0F, $00, $10, $30    ; Gray Stone
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0B, $14, $35    ; Character
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F
  .endproc

  .proc init_sprites
    NUM_SPRITES = 2
    ldx #0
  @loop:
    lda initial_sprite_data, x
    sta $200, x
    inx
    cpx #(4 * NUM_SPRITES)
    bne @loop
    rts
  initial_sprite_data:
    .byte 143, $80, %00000000, 120
    .byte 143, $82, %00000000, 128
  .endproc

  .proc init_nametable
    ; Draw the ground platform
    VramColRow 0, 20, NAMETABLE_A
    lda #$04
    jsr ppu_full_line
    lda #$05
    jsr ppu_full_line
    lda #$06
    jsr ppu_full_line
    ; Draw the press button indicators
    VramColRow 2, 24, NAMETABLE_A
    ldy #$20
    ldx #$7
    jsr ppu_fill_and_increment
    VramColRow 2, 25, NAMETABLE_A
    lda #$29
    ldx #6
    jsr ppu_fill_line
    lda #$26
    sta PPU_DATA
    VramColRow 2, 26, NAMETABLE_A
    lda #$27
    ldx #6
    jsr ppu_fill_line
    lda #$28
    sta PPU_DATA
    ; Draw the horizontal velocity indicator
    VramColRow 1, 27, NAMETABLE_A
    lda #$30
    sta PPU_DATA
    lda #$31
    sta PPU_DATA
    sta PPU_DATA
    sta PPU_DATA
    lda #$34
    sta PPU_DATA
    sta PPU_DATA
    sta PPU_DATA
    lda #$35
    sta PPU_DATA
    ; Reset the VRAM so rendering occurs correctly
    VramReset
    rts
  .endproc
.endscope

.macro SetRenderFlag
  lda #%10000000
  ora Game::FLAGS
  sta Game::FLAGS
.endmacro

.macro UnsetRenderFlag
  lda #%01111111
  and Game::FLAGS
  sta Game::FLAGS
.endmacro
