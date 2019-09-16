#pragma once

enum OPCode {
    /*
        Math instructions
    */

    ADD8, ADD16, ADD32, ADD64,
    UADD8, UADD16, UADD32, UADD64,
    FADD,

    SUB8, SUB16, SUB32, SUB64,
    USUB8, USUB16, USUB32, USUB64,
    FUB,

    MUL8, MUL16, MUL32, MUL64,
    UMUL8, UMUL16, UMUL32, UMUL64,
    FUL,

    DIV8, DIV16, DIV32, DIV64,
    UDIV8, UDIV16, UDIV32, UDIV64,
    FIV,

    MOD8, MOD16, MOD32, MOD64,
    UMOD8, UMOD16, UMOD32, UMOD64,
    FOD,

    /*
        Logicals
    */

    AND, OR, XOR, NOT, NAND,

    /*
        Bitwise
    */

    LSHIFT, RSHIFT, ROL, ROR,

    /*
        Register instructions
    */

    LOAD, STORE, MOV,

    /*
        Pointer instructions
    */

    INC, DEC,

    /*
        Stack instructions
    */

    PUSH8, PUSH16, PUSH32, PUSH64,
    POP8, POP16, POP32, POP64,
    ITER,   // Iterate the stack pointer

    /*
        Jumps
    */

    JMP, JEQ, JGT, JLT,

    /*
        Functional instructions
    */

    CALL, RET, HLT,

    /*
        I/O
    */

    READ, WRITE, ERR, READC, WRITEC, IN

    /*
        Constants
    */

    PUSH_NULL, PUSH_TRUE, PUSH_FALSE,
    STORE_NULL, STORE_TRUE, STORE_FALSE,

    /*
        Conversions
    */

    INFLATE,    // Increase the byte size of a number
    FTI,        // Float to int
    ITF,        // Int to float

    /*
        Memory allocation
    */

    ALLOC, FREE,

    /*
        Call Rust code
    */

    RSCALL
};