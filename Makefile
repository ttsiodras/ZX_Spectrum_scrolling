# This build depends on z88dk.
# If it's not packaged in your distribution, do this:
#
# mkdir -p ~/Github/
# cd ~/Github/
# git clone https://github.com/z88dk/z88dk/
# cd z88dk
# git submodule init
# git submodule update
# ./build.sh
#
# You can now use the cross compiler - just put these in your
# enviroment (e.g. in your .profile):
#
# export PATH=$HOME/Github/z88dk/bin:$PATH
# export ZCCCFG=$HOME/Github/z88dk/lib/config

EXE:=scroller.tap
SRC:=scroller.c

Q=@
ifeq ($V,1)
Q=
endif

all:	${EXE}

${EXE}:	${SRC}.m4 $(wildcard *.h)
	${Q}echo "[CC] " $<
	${Q}zcc +zx -lndos -create-app -O3 -o scroller $< -lm
	${Q}rm -f scroller *.bin zcc_opt.def
	${Q}echo "[LD] " $@

run:	${EXE}
	fuse -g 2x $<

clean:
	${Q}echo "[CLEAN]"
	${Q}rm -rf ${EXE} *.bin ${SRC}
