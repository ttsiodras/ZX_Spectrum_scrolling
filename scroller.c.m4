#include <input.h>
#include <time.h>
#include <conio.h>

define(`INNER_ENGINE', `dnl
#asm
    ld hl, eval(16384 + $3)  ; 16384 + $3
    ld b, 128 ; 128 lines from the top
    ld d, 32  ; 32 blocks, 8-pixels wide each
vertical_loop_$1:
    ; djnz is faster, use "b" register in both loops
    ld c, b ; save outer-loop value of "b"
    ld b, d ; restore value of "32"
    or a    ; clear carry, used by rr / rl
horizontal_loop_$1:
    $2 (hl)
    $1 hl
    djnz horizontal_loop_$1
    ld b, c ; restore "b" value for outer loop
    djnz vertical_loop_$1
#endasm')dnl

void scrollLeft()
{
INNER_ENGINE(dec,rl,4095)
}

void scrollRight()
{
INNER_ENGINE(inc,rr,0)
}

main()
{
    long frames = 0;
    long m = 0, st, en, total_clocks = 0;
    unsigned i = 0;

    // Clear screen, and prepare for text output
    memset((char *)16384, 0, 256U*192/8);
    memset((char *)22528, 7, 768);
    gotoxy(0,0);
    zx_border(INK_BLACK);

    // Emit some text that we will then scroll right/left...
    for(i=0; i<16; i++) {
        printf("[-] Let's move some pixels, shall we? It will be so much fun...\n");
        memset(22528 + 32*i, 1 + i%7, 32);
    }
    printf("[-] Q to quit...\n");
    memset(22528 + 32*i, 0x44, 32); i++;

    // Q will quit.
    uint qq = in_LookupKey('q');

    // Here we go...
    while(1) {
        if (in_KeyPressed(qq))
            break;
        st = clock();
        if (frames < 104)
            scrollRight();
        else
            scrollLeft();
        en = clock();
        total_clocks += (en-st);
        frames++;
        if (0x100 == (frames & 0x100))
            break;
    }
    gotoxy(0, 17);
    printf("[-] %3.1f FPS \n", ((float)frames)/(((float)total_clocks)/CLOCKS_PER_SEC));
    memset(22528 + 32*i, 0x45, 32);
    return 0;
}
