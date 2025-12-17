.section .text
.globl _start

_start:
    # Initialize values
    addi x1, x0, 0xFF      
    addi x2, x0, 0         
    addi x3, x0, 0         
    lui x4, 0x100          
    addi x4, x4, 0         

red_state:
    # Set RED: 0xFF to red, 0x00 to green and blue
    sb x2, -4(x0)          
    sb x2, -3(x0)          
    sb x1, -2(x0)          
    sb x2, -1(x0)          

    # Delay
    addi x3, x0, 0
red_delay:
    addi x3, x3, 1
    blt x3, x4, red_delay

yellow_state:
    # Set YELLOW: 0xFF to red and green, 0x00 to blue
    sb x2, -4(x0)          
    sb x1, -3(x0)          
    sb x1, -2(x0)          
    sb x2, -1(x0)          

    # Delay
    addi x3, x0, 0
yellow_delay:
    addi x3, x3, 1
    blt x3, x4, yellow_delay

green_state:
    # Set GREEN: 0xFF to green, 0x00 to red and blue
    sb x2, -4(x0)          
    sb x1, -3(x0)          
    sb x2, -2(x0)          
    sb x2, -1(x0)          

    # Delay
    addi x3, x0, 0
green_delay:
    addi x3, x3, 1
    blt x3, x4, green_delay

    # Loop back to red
    jal x0, red_state

