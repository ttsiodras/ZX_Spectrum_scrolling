#include <input.h>
#include <time.h>
#include <graphics.h>
#include <conio.h>

#define printInk(k)          printf("\x10%c", '0'+(k))
#define printPaper(k)        printf("\x11%c", '0'+(k))
#define ELEMENTS(x)          (sizeof(x)/sizeof(x[0]))

#define SCREEN_HEIGHT 192

// The angle of rotation of the eye around the Z-axis.
// Goes from 0 up to 71 for a full circle
// (see lookup table inside sincos.h).
static int angle = 0;

void cls()
{
    memset((char *)16384, 0, 256U*SCREEN_HEIGHT/8);
    gotoxy(0,0);
}

void scrollLeft()
{
#asm
    push hl
    ld hl, 16384 + 4095
    ld d, 128
line_loop_left:
    ld b, 32
    or a
inner_loop_left:
    ld a, (hl)
    rla
    ld (hl), a
    dec hl
    djnz inner_loop_left
    dec d
    ld a, d
    jnz line_loop_left
    pop hl
#endasm
}

void scrollRight()
{
#asm
    push hl
    ld hl, 16384
    ld d, 128
line_loop:
    ld b, 32
    or a
inner_loop:
    ld a, (hl)
    rra
    ld (hl), a
    inc hl
    djnz inner_loop
    dec d
    ld a, d
    jnz line_loop
    pop hl
#endasm
}

main()
{
    long frames = 0;
    long m = 0, st, en, total_clocks = 0;
    unsigned i = 0;

    //////////////
    // Banner info
    //////////////
    cls();
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
