# LED register:     0xFFFFFFFC
# millis register:  0xFFFFFFF8
# LED format: [31:24]=white, [23:16]=red, [15:8]=green, [7:0]=blue

# Register usage
# x1 = LED register address
# x2,x3 = color building
# x5 = red PWM
# x6 = green PWM
# x7 = loop limit (256)
# x10 = start millis
# x11 = current millis

# Instructions start
    lui  x1, 0xFFFFF
    addi x1, x1, -4         

    addi x7, x0, 256        

# Delay: wait ~1 ms
delay_1ms:
    lw   x10, -8(x1)        
delay_wait:
    lw   x11, -8(x1)
    beq  x10, x11, delay_wait
    jalr x0, 0(ra)          


traffic_loop:
# RED PHASE: fade red in
    addi x5, x0, 0          
    addi x6, x0, 0          

fade_in_red:
    slli x2, x5, 16
    slli x3, x6, 8
    or   x2, x2, x3
    sw   x2, 0(x1)

    jal  ra, delay_1ms

    addi x5, x5, 8
    blt  x5, x7, fade_in_red

# Hold RED
    addi x5, x0, 255
    slli x2, x5, 16
    sw   x2, 0(x1)
    jal  ra, delay_1ms
    jal  ra, delay_1ms


# YELLOW PHASE: fade green in
    addi x6, x0, 0

fade_to_yellow:
    slli x2, x5, 16
    slli x3, x6, 8
    or   x2, x2, x3
    sw   x2, 0(x1)

    jal  ra, delay_1ms

    addi x6, x6, 8
    blt  x6, x7, fade_to_yellow

# Hold YELLOW
    addi x6, x0, 255
    slli x2, x5, 16
    slli x3, x6, 8
    or   x2, x2, x3
    sw   x2, 0(x1)
    jal  ra, delay_1ms
    jal  ra, delay_1ms


# GREEN PHASE: fade red out
fade_to_green:
    slli x2, x5, 16
    slli x3, x6, 8
    or   x2, x2, x3
    sw   x2, 0(x1)

    jal  ra, delay_1ms

    addi x5, x5, -8
    bge  x5, x0, fade_to_green

# Hold GREEN
    addi x5, x0, 0
    addi x6, x0, 255
    slli x3, x6, 8
    sw   x3, 0(x1)
    jal  ra, delay_1ms
    jal  ra, delay_1ms


# Fade green out to black
fade_out_green:
    slli x3, x6, 8
    sw   x3, 0(x1)

    jal  ra, delay_1ms

    addi x6, x6, -8
    bge  x6, x0, fade_out_green

    jal  x0, traffic_loop
