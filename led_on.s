.section .text
.globl _start

_start:
    # Set RGB LED to RED
    addi x1, x0, 0xFF     
    addi x2, x0, 0        
    
    # Write to LED register
    sb x2, -4(x0)          
    sb x2, -3(x0)          
    sb x1, -2(x0)          
    sb x2, -1(x0)          
    
    # Loop forever
loop:
    j loop
