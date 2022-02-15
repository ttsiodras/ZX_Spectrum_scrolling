It was fun, writing this. Memories from childhood!

- Scrolling the top 2/3rds of the Speccy's screen
  one pixel at a time - first right, then left...
- ...and finally print the achieved frames per
  second (~23 running under FUSE; no idea what a
  real Speccy would score, but probably something
  close).

z88dk doesn't support macros in the inline assembly;
but it does support `m4`! So I [defined](scroller.c.m4#L5)
an `m4` macro to emit the bodies of the scrolling 
functions; their only difference being the direction
of the change to the HL register (`inc`/`dec`), and
the RL/RR instruction used to move the bits.

Sigh... :-)

I can still remember my 13 year old self struggling
to understand how one could possibly scroll the 
Speccy's screen...

It now only took me a couple of hours to write this!

3 decades of coding definitely helped :-)
