#include <input.h>
#include <time.h>
#include <graphics.h>
#include <conio.h>

#define printInk(k)          printf("\x10%c", '0'+(k))
#define printPaper(k)        printf("\x11%c", '0'+(k))

#define SCREEN_HEIGHT 192

// The angle of rotation of the eye around the Z-axis.
// Goes from 0 up to 71 for a full circle
// (see lookup table inside sincos.h).
static int angle = 0;

define(`INNER_ENGINE', `dnl
#asm
    ; push hl
    ; push bc
    ld hl, eval(16384 + $3)  ; 16384 + $3
    ld b, 128
    ld d, 32
line_loop_$1:
    ; djnz is faster, use "b" register in both loops
    ld c, b ; save outer-loop value of "b"
    ld b, d ; 32 blocks, 8-pixels wide each
    or a    ; clear carry, used by rr / rl
inner_loop_$1:
    $2 (hl)
    $1 hl
    djnz inner_loop_$1
    ld b, c ; restore "b" value for outer loop
    djnz line_loop_$1
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

    //////////////
    // Banner info
    //////////////
    memset((char *)16384, 0, 256U*SCREEN_HEIGHT/8);
    gotoxy(0,0);
    zx_border(INK_BLACK);
    memset((void *)22528.0, 7, 768);
    printPaper(0);
    printInk(3);
    for(int i=0; i<16; i++)
        printf("[-] Let's move some pixels, shall we? It will be so much fun...\n");
    printf("[-] Q to quit...\n");

    // Q will quit.
    uint qq = in_LookupKey('q');

    // Here we go...
    while(1) {
        if (in_KeyPressed(qq))
            break;
        // Rotate by 5 degrees on each iteration (360/72)
        st = clock();
        if (frames < 128)
            scrollRight();
        else
            scrollLeft();
        en = clock();
        total_clocks += (en-st);
        // Update FPS info.
        frames++;
        if (0x100 == (frames & 0x100)) {
            gotoxy(0, 16);
            printInk(3);
            printf("[-] %3.1f FPS \n", ((float)frames)/(((float)total_clocks)/CLOCKS_PER_SEC));
            break;
	}
    }
    return 0;
}
