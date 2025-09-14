#include <input.h>
#include <time.h>
#include <conio.h>

define(`INNER_ENGINE', `dnl
#asm
    ld hl, eval(16384 + $3)
    ld b, 16
outer_loop_$1_$4:
    ld c, b
    ld b, 8 ; 128 lines from the top
vertical_loop_$1_$4:
    or a    ; clear carry, used by rr / rl
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    $2 (hl)
    $1 l
    djnz vertical_loop_$1_$4
    $1 h
    ld b, c
    djnz outer_loop_$1_$4
    $4
#endasm')dnl

void scrollLeft()
{
INNER_ENGINE(dec,rl,4095,nop)
}

void scrollRight()
{
INNER_ENGINE(inc,rr,0,nop)
}

void scrollLeftVSync()
{
INNER_ENGINE(dec,rl,4095,halt)
}

void scrollRightVSync()
{
INNER_ENGINE(inc,rr,0,halt)
}

main()
{
    // Clear screen, and prepare for text output
    memset((char *)16384, 0, 256U*192/8);
    memset((char *)22528, 7, 768);
    zx_border(INK_BLACK);

    char *msg[] = {"out", ""};
    for(int vsync=0; vsync<2; vsync++) {
        gotoxy(0,0);
        long frames = 0;
        long m = 0, st, en, total_clocks = 0;
        unsigned i = 0;
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
                if (!vsync) scrollRight(); else scrollRightVSync();
            else
                if (!vsync) scrollLeft(); else scrollLeftVSync();
            en = clock();
            total_clocks += (en-st);
            frames++;
            if (0x100 == (frames & 0x100))
                break;
        }
        gotoxy(0, 17+vsync);
        printf("[-] %3.1f FPS with%s vsync\n", ((float)frames)/(((float)total_clocks)/CLOCKS_PER_SEC), msg[vsync]);
        memset(22528 + 32*(i+vsync), 0x45, 32);
    }

    return 0;
}
