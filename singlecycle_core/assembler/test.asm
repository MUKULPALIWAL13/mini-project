
_start:
    addi sp, sp, -8       # reserve 8 bytes on stack
    sw   x0, 4(sp)        # store 0 at (sp+4)
    sw   x0, 0(sp)        # store 0 at (sp)

    addi s1, x0, 0        # s1 = sum = 0
    addi t0, x0, 0        # t0 = counter = 0
    addi t1, x0, 10        # t1 = limit = 10

LOOP:
    slt  t2, t0, t1       # t2 = (t0 < 10)
    beq  t2, x0, END      # if not less → jump to END
    add  s1, s1, t0       # s1 += t0
    addi t0, t0, 1        # t0++
    beq  x0, x0, LOOP     # unconditional jump

END:
    sw   s1, 0(sp)        # store result (sum=45) at 0(sp)
    lw   s0, 0(sp)        # load back sum into s0
    addi sp, sp, 8        # release stack
    beq  x0, x0, END      # hang here
