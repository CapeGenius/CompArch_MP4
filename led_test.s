# Simple LED test - just turn on all LEDs at full brightness

.text
.globl _start

_start:
    # Load LED address (0xFFFFFFFC) into t0
    lui t0, 0xFFFFF       # Load upper 20 bits
    addi t0, t0, -4       # Add lower 12 bits (-4 = 0xFFC)
    
loop:
    # Write 0xFFFFFFFF (all LEDs at maximum brightness)
    addi t1, zero, -1     # t1 = 0xFFFFFFFF
    sw t1, 0(t0)          # Store to LED register
    
    # Infinite loop - keep writing
    jal zero, loop
