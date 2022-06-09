// save general registers to stack
.global save_all
.macro save_all
    sub     sp, sp, 32 * 9
    stp     x0, x1, [sp ,16 * 0]
    stp     x2, x3, [sp ,16 * 1]
    stp     x4, x5, [sp ,16 * 2]
    stp     x6, x7, [sp ,16 * 3]
    stp     x8, x9, [sp ,16 * 4]
    stp     x10, x11, [sp ,16 * 5]
    stp     x12, x13, [sp ,16 * 6]
    stp     x14, x15, [sp ,16 * 7]
    stp     x16, x17, [sp ,16 * 8]
    stp     x18, x19, [sp ,16 * 9]
    stp     x20, x21, [sp ,16 * 10]
    stp     x22, x23, [sp ,16 * 11]
    stp     x24, x25, [sp ,16 * 12]
    stp     x26, x27, [sp ,16 * 13]
    stp     x28, x29, [sp ,16 * 14]
    str     x30, [sp, 16 * 15]

// for nested interrupt
    mrs     x0, spsr_el1
    str     x0, [sp, 16 * 15 + 8]
    mrs     x0, elr_el1
    str     x0, [sp, 16 * 16]
    mrs     x0, sp_el0
    str     x0, [sp, 16 * 16 + 8]
// restore x0
    ldp     x0, x1, [sp ,16 * 0]
.endm

// load general registers from stack
.global load_all
.macro load_all
    ldp     x0, x1, [sp ,16 * 0]
    ldp     x2, x3, [sp ,16 * 1]
    ldp     x4, x5, [sp ,16 * 2]
    ldp     x6, x7, [sp ,16 * 3]
    ldp     x8, x9, [sp ,16 * 4]
    ldp     x10, x11, [sp ,16 * 5]
    ldp     x12, x13, [sp ,16 * 6]
    ldp     x14, x15, [sp ,16 * 7]
    ldp     x16, x17, [sp ,16 * 8]
    ldp     x18, x19, [sp ,16 * 9]
    ldp     x20, x21, [sp ,16 * 10]
    ldp     x22, x23, [sp ,16 * 11]
    ldp     x24, x25, [sp ,16 * 12]
    ldp     x26, x27, [sp ,16 * 13]
    ldp     x28, x29, [sp ,16 * 14]
    ldr     x30, [sp, 16 * 15]

// for nested interrupt
    ldr     x0, [sp, 16 * 15 + 8]
    msr     spsr_el1, x0
    ldr     x0, [sp, 16 * 16]
    msr     elr_el1, x0
    ldr     x0, [sp, 16 * 16 + 8]
    msr     sp_el0, x0
// restore x0
    ldp     x0, x1, [sp ,16 * 0]
    add     sp, sp, 32 * 9
.endm

.macro    ventry    label
    .align    7
    b    \label
.endm

.align 11                           // vector table should be aligned to 0x800
.global exception_vector_table
exception_vector_table:
    // Exception from the current EL while using SP_EL0
    ventry  sync_el1t_invalid       // Synchronous EL1t
    ventry	irq_el1t_invalid        // IRQ EL1t
    ventry  fiq_el1t_invalid        // FIQ EL1t
    ventry  err_el1t_invalid        // Error EL1t

    // Exception from the current EL while using SP_ELx
    ventry  sync_el1h_invalid       // Synchronous EL1h
    ventry	irq_el1h                // IRQ EL1h
    ventry  fiq_el1h_invalid        // FIQ EL1h
    ventry  err_el1h_invalid        // Error EL1h

    // Exception from a lower EL and at least one lower EL is AArch64
    ventry  sync_el0_64             // Synchronous 64-bit EL0
    ventry  irq_el0_64              // IRQ 64-bit EL0
    ventry  fiq_el0_64_invalid      // FIQ 64-bit EL0
    ventry  err_el0_64_invalid      // Error 64-bit EL0

    // Exception from a lower EL and at least all lower EL are AArch32
    ventry  sync_el0_32_invalid     // Synchronous 32-bit EL0
    ventry  irq_el0_32_invalid      // IRQ 32-bit EL0
    ventry  fiq_el0_32_invalid      // FIQ 32-bit EL0
    ventry  err_el0_32_invalid      // Error 32-bit EL0

sync_el1t_invalid:
    // save_all
    mov     x0, 1
    bl      invalid_exception_router
    // load_all
    eret
irq_el1t_invalid:
    save_all
    mov     x0, 2
    bl      invalid_exception_router
    load_all
    eret
fiq_el1t_invalid:
    save_all
    mov     x0, 3
    bl      invalid_exception_router
    load_all
    eret
err_el1t_invalid:
    save_all
    mov     x0, 4
    bl      invalid_exception_router
    load_all
    eret

sync_el1h_invalid:
    // save_all
    mov     x0, 5
    bl      invalid_exception_router
    // load_all
    eret
irq_el1h:
    save_all
    mov     x0, sp      // trap frame
    bl      irq_router
    load_all
    eret
fiq_el1h_invalid:
    save_all
    mov     x0, 7
    bl      invalid_exception_router
    load_all
    eret
err_el1h_invalid:
    save_all
    mov     x0, 8
    bl      invalid_exception_router
    load_all
    eret

sync_el0_64:
    save_all
    mov     x0, sp      // trap frame
    mrs     x1, esr_el1
    bl      sync64_router
    load_all
    eret
irq_el0_64:
    save_all
    mov     x0, sp      // trap frame
    bl      irq_router
    load_all
    eret
fiq_el0_64_invalid:
    save_all
    mov     x0, 11
    bl      invalid_exception_router
    load_all
    eret
err_el0_64_invalid:
    save_all
    mov     x0, 12
    bl      invalid_exception_router
    load_all
    eret

sync_el0_32_invalid:
    save_all
    mov     x0, 13
    bl      invalid_exception_router
    load_all
    eret
irq_el0_32_invalid:
    save_all
    mov     x0, 14
    bl      invalid_exception_router
    load_all
    eret
fiq_el0_32_invalid:
    save_all
    mov     x0, 15
    bl      invalid_exception_router
    load_all
    eret
err_el0_32_invalid:
    save_all
    mov     x0, 16
    bl      invalid_exception_router
    load_all
    eret
