#include <input.h>
#include <time.h>
#include <graphics.h>
#include <conio.h>

#define printInk(k)          printf("\x10%c", '0'+(k))
#define printPaper(k)        printf("\x11%c", '0'+(k))

define(`INNER_ENGINE', `dnl
#asm
    ; push hl
    ; push bc
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
    ; pop de
    ; pop hl
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
    printPaper(0);
    printInk(3);

    // Emit some text that we will then scroll right/left...
    for(int i=0; i<16; i++)
        printf("[-] Let's move some pixels, shall we? It will be so much fun...\n");
    printInk(4);
    printf("[-] Q to quit...\n");

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
    printInk(5);
    printf("[-] %3.1f FPS \n", ((float)frames)/(((float)total_clocks)/CLOCKS_PER_SEC));
    return 0;
}
