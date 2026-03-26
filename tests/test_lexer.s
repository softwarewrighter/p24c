        .text

        .globl  _start
_start:
        la      r0,_main
        jal     r1,(r0)
_halt:
        bra     _halt

        .globl  __putc_uart
__putc_uart:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
L1:
        la      r0,16711937
        lbu     r0,0(r0)
        la      r1,128
        and     r0,r1
        ceq     r0,z
        brt     L2
        bra     L1
L2:
        la      r0,16711936
        mov     r1,r0
        lw      r0,9(fp)
        sb      r0,0(r1)
L0:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _putchar
_putchar:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        bra     L3
L3:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _getchar
_getchar:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
L5:
        la      r0,16711937
        lbu     r0,0(r0)
        lc      r1,1
        and     r0,r1
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L6
        bra     L5
L6:
        la      r0,16711936
        lbu     r0,0(r0)
        bra     L4
L4:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _getc
_getc:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        la      r0,_getchar
        jal     r1,(r0)
        bra     L7
L7:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _puts
_puts:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
L9:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L10
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        bra     L9
L10:
        lc      r0,10
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lc      r0,0
        bra     L8
L8:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  __print_int
__print_int:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-11
        lw      r0,9(fp)
        lc      r1,0
        cls     r0,r1
        brf     L13
        lc      r0,45
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lc      r0,0
        lw      r1,9(fp)
        sub     r0,r1
        sw      r0,9(fp)
L13:
        lw      r0,9(fp)
        lc      r1,0
        ceq     r0,r1
        brf     L15
        lc      r0,48
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lc      r0,0
        la      r2,L11
        jmp     (r2)
L15:
        lc      r0,0
        sw      r0,-11(fp)
L16:
        lw      r0,9(fp)
        lc      r1,0
        cls     r1,r0
        brt     L20
        la      r2,L17
        jmp     (r2)
L20:
        lc      r0,48
        push    r0
        lw      r0,9(fp)
        lc      r1,10
        push    r1
        push    r0
        la      r0,__tc24r_mod
        jal     r1,(r0)
        add     sp,6
        mov     r1,r0
        pop     r0
        add     r0,r1
        push    r0
        lc      r0,-8
        add     r0,fp
        lw      r1,-11(fp)
        add     r0,r1
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        lw      r0,9(fp)
        lc      r1,10
        push    r1
        push    r0
        la      r0,__tc24r_div
        jal     r1,(r0)
        add     sp,6
        sw      r0,9(fp)
        lw      r0,-11(fp)
        push    r0
        add     r0,1
        sw      r0,-11(fp)
        pop     r0
        la      r2,L16
        jmp     (r2)
L17:
L18:
        lw      r0,-11(fp)
        lc      r1,0
        cls     r1,r0
        brf     L19
        lw      r0,-11(fp)
        push    r0
        add     r0,-1
        sw      r0,-11(fp)
        pop     r0
        lc      r0,-8
        add     r0,fp
        lw      r1,-11(fp)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        bra     L18
L19:
L11:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  __print_hex
__print_hex:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-12
        lw      r0,9(fp)
        lc      r1,0
        ceq     r0,r1
        brf     L23
        lc      r0,48
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lc      r0,0
        la      r2,L21
        jmp     (r2)
L23:
        lc      r0,0
        sw      r0,-9(fp)
L24:
        lw      r0,9(fp)
        lc      r1,0
        cls     r1,r0
        brt     L30
        la      r2,L25
        jmp     (r2)
L30:
        lw      r0,9(fp)
        lc      r1,15
        and     r0,r1
        sw      r0,-12(fp)
        lw      r0,-12(fp)
        lc      r1,10
        cls     r0,r1
        brf     L26
        lc      r0,48
        lw      r1,-12(fp)
        add     r0,r1
        push    r0
        lc      r0,-6
        add     r0,fp
        lw      r1,-9(fp)
        add     r0,r1
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        bra     L27
L26:
        lc      r0,87
        lw      r1,-12(fp)
        add     r0,r1
        push    r0
        lc      r0,-6
        add     r0,fp
        lw      r1,-9(fp)
        add     r0,r1
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
L27:
        lw      r0,9(fp)
        lc      r1,4
        sra     r0,r1
        sw      r0,9(fp)
        lw      r0,-9(fp)
        push    r0
        add     r0,1
        sw      r0,-9(fp)
        pop     r0
        la      r2,L24
        jmp     (r2)
L25:
L28:
        lw      r0,-9(fp)
        lc      r1,0
        cls     r1,r0
        brf     L29
        lw      r0,-9(fp)
        push    r0
        add     r0,-1
        sw      r0,-9(fp)
        pop     r0
        lc      r0,-6
        add     r0,fp
        lw      r1,-9(fp)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        bra     L28
L29:
L21:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  __print_str
__print_str:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
L32:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L33
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        bra     L32
L33:
L31:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  __fmt_one
__fmt_one:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lc      r1,100
        ceq     r0,r1
        brf     L35
        lw      r0,12(fp)
        push    r0
        la      r0,__print_int
        jal     r1,(r0)
        add     sp,3
        la      r2,L36
        jmp     (r2)
L35:
        lw      r0,9(fp)
        lc      r1,120
        ceq     r0,r1
        brf     L37
        lw      r0,12(fp)
        push    r0
        la      r0,__print_hex
        jal     r1,(r0)
        add     sp,3
        la      r2,L38
        jmp     (r2)
L37:
        lw      r0,9(fp)
        lc      r1,99
        ceq     r0,r1
        brf     L39
        lw      r0,12(fp)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        bra     L40
L39:
        lw      r0,9(fp)
        lc      r1,115
        ceq     r0,r1
        brf     L41
        lw      r0,12(fp)
        push    r0
        la      r0,__print_str
        jal     r1,(r0)
        add     sp,3
        bra     L42
L41:
        lw      r0,9(fp)
        lc      r1,37
        ceq     r0,r1
        brf     L43
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        bra     L44
L43:
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L44:
L42:
L40:
L38:
L36:
L34:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  ___tc24r_printf0
___tc24r_printf0:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
L46:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brf     L52
        la      r2,L47
        jmp     (r2)
L52:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brf     L48
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brf     L50
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        bra     L51
L50:
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L51:
        bra     L49
L48:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L49:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        la      r2,L46
        jmp     (r2)
L47:
        lc      r0,0
        bra     L45
L45:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  ___tc24r_printf1
___tc24r_printf1:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        lc      r0,0
        sw      r0,-3(fp)
L54:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brf     L63
        la      r2,L55
        jmp     (r2)
L63:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brt     L62
        la      r2,L56
        jmp     (r2)
L62:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brf     L58
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        bra     L59
L58:
        lw      r0,-3(fp)
        lc      r1,0
        ceq     r0,r1
        brf     L60
        lw      r0,12(fp)
        push    r0
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__fmt_one
        jal     r1,(r0)
        add     sp,6
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        bra     L61
L60:
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L61:
L59:
        bra     L57
L56:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L57:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        la      r2,L54
        jmp     (r2)
L55:
        lc      r0,0
        bra     L53
L53:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  ___tc24r_printf2
___tc24r_printf2:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        lc      r0,0
        sw      r0,-3(fp)
L65:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brf     L76
        la      r2,L66
        jmp     (r2)
L76:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brt     L75
        la      r2,L67
        jmp     (r2)
L75:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brf     L69
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        la      r2,L70
        jmp     (r2)
L69:
        lw      r0,-3(fp)
        lc      r1,0
        ceq     r0,r1
        brf     L71
        lw      r0,12(fp)
        push    r0
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__fmt_one
        jal     r1,(r0)
        add     sp,6
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        bra     L72
L71:
        lw      r0,-3(fp)
        lc      r1,1
        ceq     r0,r1
        brf     L73
        lw      r0,15(fp)
        push    r0
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__fmt_one
        jal     r1,(r0)
        add     sp,6
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        bra     L74
L73:
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L74:
L72:
L70:
        bra     L68
L67:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L68:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        la      r2,L65
        jmp     (r2)
L66:
        lc      r0,0
        bra     L64
L64:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  ___tc24r_printf3
___tc24r_printf3:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        lc      r0,0
        sw      r0,-3(fp)
L78:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brf     L91
        la      r2,L79
        jmp     (r2)
L91:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brt     L90
        la      r2,L80
        jmp     (r2)
L90:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,9(fp)
        lbu     r0,0(r0)
        lc      r1,37
        ceq     r0,r1
        brf     L82
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        la      r2,L83
        jmp     (r2)
L82:
        lw      r0,-3(fp)
        lc      r1,0
        ceq     r0,r1
        brf     L84
        lw      r0,12(fp)
        push    r0
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__fmt_one
        jal     r1,(r0)
        add     sp,6
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        la      r2,L85
        jmp     (r2)
L84:
        lw      r0,-3(fp)
        lc      r1,1
        ceq     r0,r1
        brf     L86
        lw      r0,15(fp)
        push    r0
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__fmt_one
        jal     r1,(r0)
        add     sp,6
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        bra     L87
L86:
        lw      r0,-3(fp)
        lc      r1,2
        ceq     r0,r1
        brf     L88
        lw      r0,18(fp)
        push    r0
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__fmt_one
        jal     r1,(r0)
        add     sp,6
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        bra     L89
L88:
        lc      r0,37
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L89:
L87:
L85:
L83:
        bra     L81
L80:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        la      r0,__putc_uart
        jal     r1,(r0)
        add     sp,3
L81:
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        la      r2,L78
        jmp     (r2)
L79:
        lc      r0,0
        bra     L77
L77:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _strlen
_strlen:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        lc      r0,0
        sw      r0,-3(fp)
L93:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L94
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        bra     L93
L94:
        lw      r0,-3(fp)
        bra     L92
L92:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _strcmp
_strcmp:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
L96:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L100
        lw      r0,12(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L100
        lc      r0,1
        bra     L101
L100:
        lc      r0,0
L101:
        ceq     r0,z
        brt     L98
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        lw      r0,12(fp)
        lbu     r0,0(r0)
        mov     r1,r0
        pop     r0
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L98
        lc      r0,1
        bra     L99
L98:
        lc      r0,0
L99:
        ceq     r0,z
        brt     L97
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,12(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,12(fp)
        la      r2,L96
        jmp     (r2)
L97:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        lw      r0,12(fp)
        lbu     r0,0(r0)
        mov     r1,r0
        pop     r0
        sub     r0,r1
        bra     L95
L95:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _strncmp
_strncmp:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        lc      r0,0
        sw      r0,-3(fp)
L103:
        lw      r0,-3(fp)
        lw      r1,15(fp)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L109
        lw      r0,9(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L109
        lc      r0,1
        bra     L110
L109:
        lc      r0,0
L110:
        ceq     r0,z
        brt     L107
        lw      r0,12(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L107
        lc      r0,1
        bra     L108
L107:
        lc      r0,0
L108:
        ceq     r0,z
        brt     L105
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        lw      r0,12(fp)
        lbu     r0,0(r0)
        mov     r1,r0
        pop     r0
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L105
        lc      r0,1
        bra     L106
L105:
        lc      r0,0
L106:
        ceq     r0,z
        brt     L104
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,12(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,12(fp)
        lw      r0,-3(fp)
        push    r0
        add     r0,1
        sw      r0,-3(fp)
        pop     r0
        la      r2,L103
        jmp     (r2)
L104:
        lw      r0,-3(fp)
        lw      r1,15(fp)
        ceq     r0,r1
        brf     L112
        lc      r0,0
        bra     L102
L112:
        lw      r0,9(fp)
        lbu     r0,0(r0)
        push    r0
        lw      r0,12(fp)
        lbu     r0,0(r0)
        mov     r1,r0
        pop     r0
        sub     r0,r1
        bra     L102
L102:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _strcpy
_strcpy:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        lw      r0,9(fp)
        sw      r0,-3(fp)
L114:
        lw      r0,12(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L115
        lw      r0,12(fp)
        lbu     r0,0(r0)
        push    r0
        lw      r0,9(fp)
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,12(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,12(fp)
        bra     L114
L115:
        lw      r0,9(fp)
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lw      r0,-3(fp)
        bra     L113
L113:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _strncpy
_strncpy:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-6
        lw      r0,9(fp)
        sw      r0,-3(fp)
        lc      r0,0
        sw      r0,-6(fp)
L117:
        lw      r0,-6(fp)
        lw      r1,15(fp)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L119
        lw      r0,12(fp)
        lbu     r0,0(r0)
        ceq     r0,z
        brt     L119
        lc      r0,1
        bra     L120
L119:
        lc      r0,0
L120:
        ceq     r0,z
        brt     L118
        lw      r0,12(fp)
        lbu     r0,0(r0)
        push    r0
        lw      r0,9(fp)
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,12(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,12(fp)
        lw      r0,-6(fp)
        push    r0
        add     r0,1
        sw      r0,-6(fp)
        pop     r0
        la      r2,L117
        jmp     (r2)
L118:
L121:
        lw      r0,-6(fp)
        lw      r1,15(fp)
        cls     r0,r1
        brf     L122
        lw      r0,9(fp)
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lw      r0,9(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,9(fp)
        lw      r0,-6(fp)
        push    r0
        add     r0,1
        sw      r0,-6(fp)
        pop     r0
        bra     L121
L122:
        lw      r0,-3(fp)
        bra     L116
L116:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _memcpy
_memcpy:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-9
        lw      r0,9(fp)
        sw      r0,-3(fp)
        lw      r0,12(fp)
        sw      r0,-6(fp)
        lc      r0,0
        sw      r0,-9(fp)
L124:
        lw      r0,-9(fp)
        lw      r1,15(fp)
        cls     r0,r1
        brf     L125
        lw      r0,-6(fp)
        lw      r1,-9(fp)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        lw      r0,-3(fp)
        lw      r1,-9(fp)
        add     r0,r1
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        lw      r0,-9(fp)
        push    r0
        add     r0,1
        sw      r0,-9(fp)
        pop     r0
        bra     L124
L125:
        lw      r0,9(fp)
        bra     L123
L123:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _memset
_memset:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-6
        lw      r0,9(fp)
        sw      r0,-3(fp)
        lc      r0,0
        sw      r0,-6(fp)
L127:
        lw      r0,-6(fp)
        lw      r1,15(fp)
        cls     r0,r1
        brf     L128
        lw      r0,-3(fp)
        lw      r1,-6(fp)
        add     r0,r1
        mov     r1,r0
        lw      r0,12(fp)
        sb      r0,0(r1)
        lw      r0,-6(fp)
        push    r0
        add     r0,1
        sw      r0,-6(fp)
        pop     r0
        bra     L127
L128:
        lw      r0,9(fp)
        bra     L126
L126:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _memcmp
_memcmp:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-9
        lw      r0,9(fp)
        sw      r0,-3(fp)
        lw      r0,12(fp)
        sw      r0,-6(fp)
        lc      r0,0
        sw      r0,-9(fp)
L130:
        lw      r0,-9(fp)
        lw      r1,15(fp)
        cls     r0,r1
        brt     L134
        la      r2,L131
        jmp     (r2)
L134:
        lw      r0,-3(fp)
        lw      r1,-9(fp)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        lw      r0,-6(fp)
        lw      r1,-9(fp)
        add     r0,r1
        lbu     r0,0(r0)
        mov     r1,r0
        pop     r0
        ceq     r0,r1
        brt     L133
        lw      r0,-3(fp)
        lw      r1,-9(fp)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        lw      r0,-6(fp)
        lw      r1,-9(fp)
        add     r0,r1
        lbu     r0,0(r0)
        mov     r1,r0
        pop     r0
        sub     r0,r1
        bra     L129
L133:
        lw      r0,-9(fp)
        push    r0
        add     r0,1
        sw      r0,-9(fp)
        pop     r0
        la      r2,L130
        jmp     (r2)
L131:
        lc      r0,0
        bra     L129
L129:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_is_alpha
_lex_is_alpha:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lc      r1,97
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L140
        lw      r0,9(fp)
        lc      r1,122
        cls     r1,r0
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L140
        lc      r0,1
        bra     L141
L140:
        lc      r0,0
L141:
        ceq     r0,z
        brf     L138
        lw      r0,9(fp)
        lc      r1,65
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L142
        lw      r0,9(fp)
        lc      r1,90
        cls     r1,r0
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L142
        lc      r0,1
        bra     L143
L142:
        lc      r0,0
L143:
        ceq     r0,z
        brf     L138
        lc      r0,0
        bra     L139
L138:
        lc      r0,1
L139:
        ceq     r0,z
        brf     L136
        lw      r0,9(fp)
        lc      r1,95
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brf     L136
        lc      r0,0
        bra     L137
L136:
        lc      r0,1
L137:
        bra     L135
L135:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_is_digit
_lex_is_digit:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lc      r1,48
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L145
        lw      r0,9(fp)
        lc      r1,57
        cls     r1,r0
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L145
        lc      r0,1
        bra     L146
L145:
        lc      r0,0
L146:
        bra     L144
L144:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_to_lower
_lex_to_lower:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lc      r1,65
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L150
        lw      r0,9(fp)
        lc      r1,90
        cls     r1,r0
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L150
        lc      r0,1
        bra     L151
L150:
        lc      r0,0
L151:
        ceq     r0,z
        brt     L149
        lw      r0,9(fp)
        lc      r1,32
        add     r0,r1
        bra     L147
L149:
        lw      r0,9(fp)
        bra     L147
L147:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_peek
_lex_peek:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        brt     L154
        lc      r0,0
        bra     L152
L154:
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        bra     L152
L152:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_advance
_lex_advance:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        brt     L157
        lc      r0,0
        bra     L155
L157:
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        sw      r0,-3(fp)
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        la      r1,_lex_pos
        sw      r0,0(r1)
        lw      r0,-3(fp)
        lc      r1,10
        ceq     r0,r1
        brf     L159
        la      r1,_lex_line
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        la      r1,_lex_line
        sw      r0,0(r1)
L159:
        lw      r0,-3(fp)
        bra     L155
L155:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_skip_ws
_lex_skip_ws:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-3
L161:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        brt     L194
        la      r2,L162
        jmp     (r2)
L194:
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        sw      r0,-3(fp)
        lw      r0,-3(fp)
        lc      r1,32
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brf     L169
        lw      r0,-3(fp)
        lc      r1,9
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brf     L169
        lc      r0,0
        bra     L170
L169:
        lc      r0,1
L170:
        ceq     r0,z
        brf     L167
        lw      r0,-3(fp)
        lc      r1,13
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brf     L167
        lc      r0,0
        bra     L168
L167:
        lc      r0,1
L168:
        ceq     r0,z
        brf     L165
        lw      r0,-3(fp)
        lc      r1,10
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brf     L165
        lc      r0,0
        bra     L166
L165:
        lc      r0,1
L166:
        ceq     r0,z
        brt     L163
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r2,L164
        jmp     (r2)
L163:
        lw      r0,-3(fp)
        lc      r1,123
        ceq     r0,r1
        brt     L193
        la      r2,L171
        jmp     (r2)
L193:
        la      r0,_lex_advance
        jal     r1,(r0)
L173:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L175
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,125
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        mov     r0,c
        ceq     r0,z
        brt     L175
        lc      r0,1
        bra     L176
L175:
        lc      r0,0
L176:
        ceq     r0,z
        brt     L174
        la      r0,_lex_advance
        jal     r1,(r0)
        bra     L173
L174:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        brf     L178
        la      r0,_lex_advance
        jal     r1,(r0)
L178:
        la      r2,L172
        jmp     (r2)
L171:
        lw      r0,-3(fp)
        lc      r1,40
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L183
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L183
        lc      r0,1
        bra     L184
L183:
        lc      r0,0
L184:
        ceq     r0,z
        brt     L181
        la      r1,_lex_src
        lw      r0,0(r1)
        push    r0
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        pop     r0
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,42
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L181
        lc      r0,1
        bra     L182
L181:
        lc      r0,0
L182:
        ceq     r0,z
        brf     L192
        la      r2,L179
        jmp     (r2)
L192:
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r0,_lex_advance
        jal     r1,(r0)
L185:
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        brt     L191
        la      r2,L186
        jmp     (r2)
L191:
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,42
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L189
        la      r1,_lex_src
        lw      r0,0(r1)
        push    r0
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        pop     r0
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,41
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L189
        lc      r0,1
        bra     L190
L189:
        lc      r0,0
L190:
        ceq     r0,z
        brt     L188
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r0,_lex_advance
        jal     r1,(r0)
        bra     L186
L188:
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r2,L185
        jmp     (r2)
L186:
        bra     L180
L179:
        bra     L162
L180:
L172:
L164:
        la      r2,L161
        jmp     (r2)
L162:
L160:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lex_keyword
_lex_keyword:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        la      r0,_S0
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L197
        lc      r0,0
        la      r2,L195
        jmp     (r2)
L197:
        la      r0,_S1
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L199
        lc      r0,1
        la      r2,L195
        jmp     (r2)
L199:
        la      r0,_S2
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L201
        lc      r0,2
        la      r2,L195
        jmp     (r2)
L201:
        la      r0,_S3
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L203
        lc      r0,3
        la      r2,L195
        jmp     (r2)
L203:
        la      r0,_S4
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L205
        lc      r0,4
        la      r2,L195
        jmp     (r2)
L205:
        la      r0,_S5
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L207
        lc      r0,5
        la      r2,L195
        jmp     (r2)
L207:
        la      r0,_S6
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L209
        lc      r0,6
        la      r2,L195
        jmp     (r2)
L209:
        la      r0,_S7
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L211
        lc      r0,7
        la      r2,L195
        jmp     (r2)
L211:
        la      r0,_S8
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L213
        lc      r0,8
        la      r2,L195
        jmp     (r2)
L213:
        la      r0,_S9
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L215
        lc      r0,9
        la      r2,L195
        jmp     (r2)
L215:
        la      r0,_S10
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L217
        lc      r0,10
        la      r2,L195
        jmp     (r2)
L217:
        la      r0,_S11
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L219
        lc      r0,11
        la      r2,L195
        jmp     (r2)
L219:
        la      r0,_S12
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L221
        lc      r0,12
        la      r2,L195
        jmp     (r2)
L221:
        la      r0,_S13
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L223
        lc      r0,13
        la      r2,L195
        jmp     (r2)
L223:
        la      r0,_S14
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L225
        lc      r0,14
        la      r2,L195
        jmp     (r2)
L225:
        la      r0,_S15
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L227
        lc      r0,15
        la      r2,L195
        jmp     (r2)
L227:
        la      r0,_S16
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L229
        lc      r0,16
        la      r2,L195
        jmp     (r2)
L229:
        la      r0,_S17
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L231
        lc      r0,17
        bra     L195
L231:
        la      r0,_S18
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L233
        lc      r0,18
        bra     L195
L233:
        la      r0,_S19
        push    r0
        lw      r0,9(fp)
        push    r0
        la      r0,_strcmp
        jal     r1,(r0)
        add     sp,6
        lc      r1,0
        ceq     r0,r1
        brf     L235
        lc      r0,19
        bra     L195
L235:
        lc      r0,36
        bra     L195
L195:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _lexer_init
_lexer_init:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        la      r1,_lex_src
        sw      r0,0(r1)
        lc      r0,0
        la      r1,_lex_pos
        sw      r0,0(r1)
        lw      r0,12(fp)
        la      r1,_lex_len
        sw      r0,0(r1)
        lc      r0,1
        la      r1,_lex_line
        sw      r0,0(r1)
        lc      r0,38
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,1
        la      r1,_tok_line
        sw      r0,0(r1)
        lc      r0,0
        la      r1,_tok_int_val
        sw      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
L236:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _next_token
_next_token:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-6
        la      r0,_lex_skip_ws
        jal     r1,(r0)
        la      r1,_lex_line
        lw      r0,0(r1)
        la      r1,_tok_line
        sw      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        brt     L239
        lc      r0,38
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,38
        la      r2,L237
        jmp     (r2)
L239:
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        sw      r0,-3(fp)
        lw      r0,-3(fp)
        push    r0
        la      r0,_lex_is_alpha
        jal     r1,(r0)
        add     sp,3
        ceq     r0,z
        brf     L305
        la      r2,L241
        jmp     (r2)
L305:
        lc      r0,0
        sw      r0,-6(fp)
L242:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brf     L304
        la      r2,L244
        jmp     (r2)
L304:
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,_lex_is_alpha
        jal     r1,(r0)
        add     sp,3
        ceq     r0,z
        brf     L246
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,_lex_is_digit
        jal     r1,(r0)
        add     sp,3
        ceq     r0,z
        brf     L246
        lc      r0,0
        bra     L247
L246:
        lc      r0,1
L247:
        ceq     r0,z
        brt     L244
        lc      r0,1
        bra     L245
L244:
        lc      r0,0
L245:
        ceq     r0,z
        brf     L303
        la      r2,L243
        jmp     (r2)
L303:
        lw      r0,-6(fp)
        push    r0
        lc      r0,64
        lc      r1,1
        sub     r0,r1
        mov     r1,r0
        pop     r0
        cls     r0,r1
        brf     L249
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,_lex_to_lower
        jal     r1,(r0)
        add     sp,3
        push    r0
        la      r0,_tok_lexeme
        lw      r1,-6(fp)
        add     r0,r1
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        lw      r0,-6(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,-6(fp)
L249:
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        la      r1,_lex_pos
        sw      r0,0(r1)
        la      r2,L242
        jmp     (r2)
L243:
        la      r0,_tok_lexeme
        lw      r1,-6(fp)
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        push    r0
        la      r0,_lex_keyword
        jal     r1,(r0)
        add     sp,3
        la      r1,_tok_type
        sw      r0,0(r1)
        la      r1,_tok_type
        lw      r0,0(r1)
        la      r2,L237
        jmp     (r2)
L241:
        lw      r0,-3(fp)
        push    r0
        la      r0,_lex_is_digit
        jal     r1,(r0)
        add     sp,3
        ceq     r0,z
        brf     L302
        la      r2,L251
        jmp     (r2)
L302:
        lc      r0,0
        sw      r0,-6(fp)
        lc      r0,0
        la      r1,_tok_int_val
        sw      r0,0(r1)
L252:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L254
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,_lex_is_digit
        jal     r1,(r0)
        add     sp,3
        ceq     r0,z
        brt     L254
        lc      r0,1
        bra     L255
L254:
        lc      r0,0
L255:
        ceq     r0,z
        brf     L301
        la      r2,L253
        jmp     (r2)
L301:
        lw      r0,-6(fp)
        push    r0
        lc      r0,64
        lc      r1,1
        sub     r0,r1
        mov     r1,r0
        pop     r0
        cls     r0,r1
        brf     L257
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        push    r0
        la      r0,_tok_lexeme
        lw      r1,-6(fp)
        add     r0,r1
        mov     r1,r0
        pop     r0
        sb      r0,0(r1)
        lw      r0,-6(fp)
        lc      r1,1
        add     r0,r1
        sw      r0,-6(fp)
L257:
        la      r1,_tok_int_val
        lw      r0,0(r1)
        lc      r1,10
        mul     r0,r1
        push    r0
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,48
        sub     r0,r1
        mov     r1,r0
        pop     r0
        add     r0,r1
        la      r1,_tok_int_val
        sw      r0,0(r1)
        la      r1,_lex_pos
        lw      r0,0(r1)
        lc      r1,1
        add     r0,r1
        la      r1,_lex_pos
        sw      r0,0(r1)
        la      r2,L252
        jmp     (r2)
L253:
        la      r0,_tok_lexeme
        lw      r1,-6(fp)
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,37
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,37
        la      r2,L237
        jmp     (r2)
L251:
        la      r0,_lex_advance
        jal     r1,(r0)
        lw      r0,-3(fp)
        lc      r1,58
        ceq     r0,r1
        brt     L300
        la      r2,L259
        jmp     (r2)
L300:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L262
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,61
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L262
        lc      r0,1
        bra     L263
L262:
        lc      r0,0
L263:
        ceq     r0,z
        brt     L261
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,58
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,61
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,2
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,20
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,20
        la      r2,L237
        jmp     (r2)
L261:
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,58
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,35
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,35
        la      r2,L237
        jmp     (r2)
L259:
        lw      r0,-3(fp)
        lc      r1,60
        ceq     r0,r1
        brt     L299
        la      r2,L265
        jmp     (r2)
L299:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L268
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,62
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L268
        lc      r0,1
        bra     L269
L268:
        lc      r0,0
L269:
        ceq     r0,z
        brt     L267
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,60
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,62
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,2
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,30
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,30
        la      r2,L237
        jmp     (r2)
L267:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L272
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,61
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L272
        lc      r0,1
        bra     L273
L272:
        lc      r0,0
L273:
        ceq     r0,z
        brt     L271
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,60
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,61
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,2
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,32
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,32
        la      r2,L237
        jmp     (r2)
L271:
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,60
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,31
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,31
        la      r2,L237
        jmp     (r2)
L265:
        lw      r0,-3(fp)
        lc      r1,62
        ceq     r0,r1
        brt     L298
        la      r2,L275
        jmp     (r2)
L298:
        la      r1,_lex_pos
        lw      r0,0(r1)
        la      r1,_lex_len
        lw      r1,0(r1)
        cls     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L278
        la      r1,_lex_src
        lw      r0,0(r1)
        la      r1,_lex_pos
        lw      r1,0(r1)
        add     r0,r1
        lbu     r0,0(r0)
        lc      r1,61
        ceq     r0,r1
        mov     r0,c
        ceq     r0,z
        brt     L278
        lc      r0,1
        bra     L279
L278:
        lc      r0,0
L279:
        ceq     r0,z
        brt     L277
        la      r0,_lex_advance
        jal     r1,(r0)
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,62
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,61
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,2
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,34
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,34
        la      r2,L237
        jmp     (r2)
L277:
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,62
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,33
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,33
        la      r2,L237
        jmp     (r2)
L275:
        lw      r0,-3(fp)
        lc      r1,59
        ceq     r0,r1
        brf     L281
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,59
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,21
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,21
        la      r2,L237
        jmp     (r2)
L281:
        lw      r0,-3(fp)
        lc      r1,46
        ceq     r0,r1
        brf     L283
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,46
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,22
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,22
        la      r2,L237
        jmp     (r2)
L283:
        lw      r0,-3(fp)
        lc      r1,44
        ceq     r0,r1
        brf     L285
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,44
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,23
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,23
        la      r2,L237
        jmp     (r2)
L285:
        lw      r0,-3(fp)
        lc      r1,40
        ceq     r0,r1
        brf     L287
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,40
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,24
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,24
        la      r2,L237
        jmp     (r2)
L287:
        lw      r0,-3(fp)
        lc      r1,41
        ceq     r0,r1
        brf     L289
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,41
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,25
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,25
        la      r2,L237
        jmp     (r2)
L289:
        lw      r0,-3(fp)
        lc      r1,43
        ceq     r0,r1
        brf     L291
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,43
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,26
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,26
        la      r2,L237
        jmp     (r2)
L291:
        lw      r0,-3(fp)
        lc      r1,45
        ceq     r0,r1
        brf     L293
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,45
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,27
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,27
        la      r2,L237
        jmp     (r2)
L293:
        lw      r0,-3(fp)
        lc      r1,42
        ceq     r0,r1
        brf     L295
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,42
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,28
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,28
        la      r2,L237
        jmp     (r2)
L295:
        lw      r0,-3(fp)
        lc      r1,61
        ceq     r0,r1
        brf     L297
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lc      r0,61
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,29
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,29
        bra     L237
L297:
        la      r0,_tok_lexeme
        lc      r1,0
        add     r0,r1
        mov     r1,r0
        lw      r0,-3(fp)
        sb      r0,0(r1)
        la      r0,_tok_lexeme
        lc      r1,1
        add     r0,r1
        mov     r1,r0
        lc      r0,0
        sb      r0,0(r1)
        lc      r0,39
        la      r1,_tok_type
        sw      r0,0(r1)
        lc      r0,39
        bra     L237
L237:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _token_name
_token_name:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lc      r1,0
        ceq     r0,r1
        brf     L308
        la      r0,_S20
        la      r2,L306
        jmp     (r2)
L308:
        lw      r0,9(fp)
        lc      r1,1
        ceq     r0,r1
        brf     L310
        la      r0,_S21
        la      r2,L306
        jmp     (r2)
L310:
        lw      r0,9(fp)
        lc      r1,2
        ceq     r0,r1
        brf     L312
        la      r0,_S22
        la      r2,L306
        jmp     (r2)
L312:
        lw      r0,9(fp)
        lc      r1,3
        ceq     r0,r1
        brf     L314
        la      r0,_S23
        la      r2,L306
        jmp     (r2)
L314:
        lw      r0,9(fp)
        lc      r1,4
        ceq     r0,r1
        brf     L316
        la      r0,_S24
        la      r2,L306
        jmp     (r2)
L316:
        lw      r0,9(fp)
        lc      r1,5
        ceq     r0,r1
        brf     L318
        la      r0,_S25
        la      r2,L306
        jmp     (r2)
L318:
        lw      r0,9(fp)
        lc      r1,6
        ceq     r0,r1
        brf     L320
        la      r0,_S26
        la      r2,L306
        jmp     (r2)
L320:
        lw      r0,9(fp)
        lc      r1,7
        ceq     r0,r1
        brf     L322
        la      r0,_S27
        la      r2,L306
        jmp     (r2)
L322:
        lw      r0,9(fp)
        lc      r1,8
        ceq     r0,r1
        brf     L324
        la      r0,_S28
        la      r2,L306
        jmp     (r2)
L324:
        lw      r0,9(fp)
        lc      r1,9
        ceq     r0,r1
        brf     L326
        la      r0,_S29
        la      r2,L306
        jmp     (r2)
L326:
        lw      r0,9(fp)
        lc      r1,10
        ceq     r0,r1
        brf     L328
        la      r0,_S30
        la      r2,L306
        jmp     (r2)
L328:
        lw      r0,9(fp)
        lc      r1,11
        ceq     r0,r1
        brf     L330
        la      r0,_S31
        la      r2,L306
        jmp     (r2)
L330:
        lw      r0,9(fp)
        lc      r1,12
        ceq     r0,r1
        brf     L332
        la      r0,_S32
        la      r2,L306
        jmp     (r2)
L332:
        lw      r0,9(fp)
        lc      r1,13
        ceq     r0,r1
        brf     L334
        la      r0,_S33
        la      r2,L306
        jmp     (r2)
L334:
        lw      r0,9(fp)
        lc      r1,14
        ceq     r0,r1
        brf     L336
        la      r0,_S34
        la      r2,L306
        jmp     (r2)
L336:
        lw      r0,9(fp)
        lc      r1,15
        ceq     r0,r1
        brf     L338
        la      r0,_S35
        la      r2,L306
        jmp     (r2)
L338:
        lw      r0,9(fp)
        lc      r1,16
        ceq     r0,r1
        brf     L340
        la      r0,_S36
        la      r2,L306
        jmp     (r2)
L340:
        lw      r0,9(fp)
        lc      r1,17
        ceq     r0,r1
        brf     L342
        la      r0,_S37
        la      r2,L306
        jmp     (r2)
L342:
        lw      r0,9(fp)
        lc      r1,18
        ceq     r0,r1
        brf     L344
        la      r0,_S38
        la      r2,L306
        jmp     (r2)
L344:
        lw      r0,9(fp)
        lc      r1,19
        ceq     r0,r1
        brf     L346
        la      r0,_S39
        la      r2,L306
        jmp     (r2)
L346:
        lw      r0,9(fp)
        lc      r1,20
        ceq     r0,r1
        brf     L348
        la      r0,_S40
        la      r2,L306
        jmp     (r2)
L348:
        lw      r0,9(fp)
        lc      r1,21
        ceq     r0,r1
        brf     L350
        la      r0,_S41
        la      r2,L306
        jmp     (r2)
L350:
        lw      r0,9(fp)
        lc      r1,22
        ceq     r0,r1
        brf     L352
        la      r0,_S42
        la      r2,L306
        jmp     (r2)
L352:
        lw      r0,9(fp)
        lc      r1,23
        ceq     r0,r1
        brf     L354
        la      r0,_S43
        la      r2,L306
        jmp     (r2)
L354:
        lw      r0,9(fp)
        lc      r1,24
        ceq     r0,r1
        brf     L356
        la      r0,_S44
        la      r2,L306
        jmp     (r2)
L356:
        lw      r0,9(fp)
        lc      r1,25
        ceq     r0,r1
        brf     L358
        la      r0,_S45
        la      r2,L306
        jmp     (r2)
L358:
        lw      r0,9(fp)
        lc      r1,26
        ceq     r0,r1
        brf     L360
        la      r0,_S46
        la      r2,L306
        jmp     (r2)
L360:
        lw      r0,9(fp)
        lc      r1,27
        ceq     r0,r1
        brf     L362
        la      r0,_S47
        la      r2,L306
        jmp     (r2)
L362:
        lw      r0,9(fp)
        lc      r1,28
        ceq     r0,r1
        brf     L364
        la      r0,_S48
        la      r2,L306
        jmp     (r2)
L364:
        lw      r0,9(fp)
        lc      r1,29
        ceq     r0,r1
        brf     L366
        la      r0,_S49
        la      r2,L306
        jmp     (r2)
L366:
        lw      r0,9(fp)
        lc      r1,30
        ceq     r0,r1
        brf     L368
        la      r0,_S50
        la      r2,L306
        jmp     (r2)
L368:
        lw      r0,9(fp)
        lc      r1,31
        ceq     r0,r1
        brf     L370
        la      r0,_S51
        la      r2,L306
        jmp     (r2)
L370:
        lw      r0,9(fp)
        lc      r1,32
        ceq     r0,r1
        brf     L372
        la      r0,_S52
        la      r2,L306
        jmp     (r2)
L372:
        lw      r0,9(fp)
        lc      r1,33
        ceq     r0,r1
        brf     L374
        la      r0,_S53
        la      r2,L306
        jmp     (r2)
L374:
        lw      r0,9(fp)
        lc      r1,34
        ceq     r0,r1
        brf     L376
        la      r0,_S54
        bra     L306
L376:
        lw      r0,9(fp)
        lc      r1,35
        ceq     r0,r1
        brf     L378
        la      r0,_S55
        bra     L306
L378:
        lw      r0,9(fp)
        lc      r1,36
        ceq     r0,r1
        brf     L380
        la      r0,_S56
        bra     L306
L380:
        lw      r0,9(fp)
        lc      r1,37
        ceq     r0,r1
        brf     L382
        la      r0,_S57
        bra     L306
L382:
        lw      r0,9(fp)
        lc      r1,38
        ceq     r0,r1
        brf     L384
        la      r0,_S58
        bra     L306
L384:
        la      r0,_S59
        bra     L306
L306:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .globl  _main
_main:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        add     sp,-9
        la      r0,_S60
        sw      r0,-3(fp)
        lw      r0,-3(fp)
        push    r0
        la      r0,_strlen
        jal     r1,(r0)
        add     sp,3
        sw      r0,-6(fp)
        la      r0,_S61
        push    r0
        la      r0,___tc24r_printf0
        jal     r1,(r0)
        add     sp,3
        lw      r0,-6(fp)
        push    r0
        lw      r0,-3(fp)
        push    r0
        la      r0,_lexer_init
        jal     r1,(r0)
        add     sp,6
        la      r0,_next_token
        jal     r1,(r0)
        sw      r0,-9(fp)
L386:
        lw      r0,-9(fp)
        lc      r1,38
        ceq     r0,r1
        brt     L387
        la      r0,_tok_lexeme
        push    r0
        lw      r0,-9(fp)
        push    r0
        la      r0,_token_name
        jal     r1,(r0)
        add     sp,3
        push    r0
        la      r1,_tok_line
        lw      r0,0(r1)
        push    r0
        la      r0,_S62
        push    r0
        la      r0,___tc24r_printf3
        jal     r1,(r0)
        add     sp,12
        la      r0,_next_token
        jal     r1,(r0)
        sw      r0,-9(fp)
        bra     L386
L387:
        lw      r0,-9(fp)
        push    r0
        la      r0,_token_name
        jal     r1,(r0)
        add     sp,3
        push    r0
        la      r1,_tok_line
        lw      r0,0(r1)
        push    r0
        la      r0,_S63
        push    r0
        la      r0,___tc24r_printf2
        jal     r1,(r0)
        add     sp,9
        la      r0,_S64
        push    r0
        la      r0,___tc24r_printf0
        jal     r1,(r0)
        add     sp,3
        lc      r0,0
        bra     L385
L385:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

__tc24r_div:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lw      r1,12(fp)
        lc      r2,0
__tc24r_div_lp:
        cls     r0,r1
        brt     __tc24r_div_dn
        sub     r0,r1
        add     r2,1
        bra     __tc24r_div_lp
__tc24r_div_dn:
        mov     r0,r2
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)
__tc24r_mod:
        push    fp
        push    r2
        push    r1
        mov     fp,sp
        lw      r0,9(fp)
        lw      r1,12(fp)
__tc24r_mod_lp:
        cls     r0,r1
        brt     __tc24r_mod_dn
        sub     r0,r1
        bra     __tc24r_mod_lp
__tc24r_mod_dn:
        mov     sp,fp
        pop     r1
        pop     r2
        pop     fp
        jmp     (r1)

        .data
_tok_type:
        .word   0
_tok_line:
        .word   0
_tok_int_val:
        .word   0
_tok_lexeme:
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
        .byte   0
_lex_src:
        .word   0
_lex_pos:
        .word   0
_lex_len:
        .word   0
_lex_line:
        .word   0
_S0:
        .byte   112,114,111,103,114,97,109,0
_S1:
        .byte   99,111,110,115,116,0
_S2:
        .byte   118,97,114,0
_S3:
        .byte   98,101,103,105,110,0
_S4:
        .byte   101,110,100,0
_S5:
        .byte   105,102,0
_S6:
        .byte   116,104,101,110,0
_S7:
        .byte   101,108,115,101,0
_S8:
        .byte   119,104,105,108,101,0
_S9:
        .byte   100,111,0
_S10:
        .byte   119,114,105,116,101,108,110,0
_S11:
        .byte   105,110,116,101,103,101,114,0
_S12:
        .byte   98,111,111,108,101,97,110,0
_S13:
        .byte   116,114,117,101,0
_S14:
        .byte   102,97,108,115,101,0
_S15:
        .byte   100,105,118,0
_S16:
        .byte   109,111,100,0
_S17:
        .byte   97,110,100,0
_S18:
        .byte   111,114,0
_S19:
        .byte   110,111,116,0
_S20:
        .byte   80,82,79,71,82,65,77,0
_S21:
        .byte   67,79,78,83,84,0
_S22:
        .byte   86,65,82,0
_S23:
        .byte   66,69,71,73,78,0
_S24:
        .byte   69,78,68,0
_S25:
        .byte   73,70,0
_S26:
        .byte   84,72,69,78,0
_S27:
        .byte   69,76,83,69,0
_S28:
        .byte   87,72,73,76,69,0
_S29:
        .byte   68,79,0
_S30:
        .byte   87,82,73,84,69,76,78,0
_S31:
        .byte   73,78,84,69,71,69,82,0
_S32:
        .byte   66,79,79,76,69,65,78,0
_S33:
        .byte   84,82,85,69,0
_S34:
        .byte   70,65,76,83,69,0
_S35:
        .byte   68,73,86,0
_S36:
        .byte   77,79,68,0
_S37:
        .byte   65,78,68,0
_S38:
        .byte   79,82,0
_S39:
        .byte   78,79,84,0
_S40:
        .byte   65,83,83,73,71,78,0
_S41:
        .byte   83,69,77,73,0
_S42:
        .byte   68,79,84,0
_S43:
        .byte   67,79,77,77,65,0
_S44:
        .byte   76,80,65,82,69,78,0
_S45:
        .byte   82,80,65,82,69,78,0
_S46:
        .byte   80,76,85,83,0
_S47:
        .byte   77,73,78,85,83,0
_S48:
        .byte   83,84,65,82,0
_S49:
        .byte   69,81,0
_S50:
        .byte   78,69,81,0
_S51:
        .byte   76,84,0
_S52:
        .byte   76,69,0
_S53:
        .byte   71,84,0
_S54:
        .byte   71,69,0
_S55:
        .byte   67,79,76,79,78,0
_S56:
        .byte   73,68,69,78,84,0
_S57:
        .byte   73,78,84,0
_S58:
        .byte   69,79,70,0
_S59:
        .byte   69,82,82,79,82,0
_S60:
        .byte   112,114,111,103,114,97,109,32,67,111,117,110,116,100,111,119,110,59,10,99,111,110,115,116,10,32,32,115,116,97,114,116,32,61,32,49,48,59,10,118,97,114,10,32,32,110,58,32,105,110,116,101,103,101,114,59,10,32,32,100,111,110,101,58,32,98,111,111,108,101,97,110,59,10,98,101,103,105,110,10,32,32,110,32,58,61,32,115,116,97,114,116,59,10,32,32,100,111,110,101,32,58,61,32,102,97,108,115,101,59,10,32,32,123,32,116,104,105,115,32,105,115,32,97,32,99,111,109,109,101,110,116,32,125,10,32,32,119,104,105,108,101,32,110,111,116,32,100,111,110,101,32,100,111,10,32,32,98,101,103,105,110,10,32,32,32,32,119,114,105,116,101,108,110,40,110,41,59,10,32,32,32,32,110,32,58,61,32,110,32,45,32,49,59,10,32,32,32,32,105,102,32,110,32,61,32,48,32,116,104,101,110,10,32,32,32,32,32,32,100,111,110,101,32,58,61,32,116,114,117,101,10,32,32,101,110,100,59,10,32,32,40,42,32,97,110,111,116,104,101,114,32,99,111,109,109,101,110,116,32,115,116,121,108,101,32,42,41,10,32,32,105,102,32,110,32,60,62,32,53,32,116,104,101,110,10,32,32,32,32,119,114,105,116,101,108,110,40,110,41,10,101,110,100,46,10,0
_S61:
        .byte   61,61,61,32,112,50,52,112,32,108,101,120,101,114,32,116,101,115,116,32,61,61,61,10,0
_S62:
        .byte   37,100,32,37,115,32,37,115,10,0
_S63:
        .byte   37,100,32,37,115,10,0
_S64:
        .byte   61,61,61,32,100,111,110,101,32,61,61,61,10,0
