#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import sys
import string

txtblk='\x1b[0;30m' # Black - Regular
txtred='\x1b[0;31m' # Red
txtgrn='\x1b[0;32m' # Green
txtylw='\x1b[0;33m' # Yellow
txtblu='\x1b[0;34m' # Blue
txtpur='\x1b[0;35m' # Purple
txtcyn='\x1b[0;36m' # Cyan
txtwht='\x1b[0;37m' # White
bldblk='\x1b[1;30m' # Black - Bold
bldred='\x1b[1;31m' # Red
bldgrn='\x1b[1;32m' # Green
bldylw='\x1b[1;33m' # Yellow
bldblu='\x1b[1;34m' # Blue
bldpur='\x1b[1;35m' # Purple
bldcyn='\x1b[1;36m' # Cyan
bldwht='\x1b[1;37m' # White
undblk='\x1b[4;30m' # Black - Underline
undred='\x1b[4;31m' # Red
undgrn='\x1b[4;32m' # Green
undylw='\x1b[4;33m' # Yellow
undblu='\x1b[4;34m' # Blue
undpur='\x1b[4;35m' # Purple
undcyn='\x1b[4;36m' # Cyan
undwht='\x1b[4;37m' # White
bakblk='\x1b[40m'   # Black - Background
bakred='\x1b[41m'   # Red
bakgrn='\x1b[42m'   # Green
bakylw='\x1b[43m'   # Yellow
bakblu='\x1b[44m'   # Blue
bakpur='\x1b[45m'   # Purple
bakcyn='\x1b[46m'   # Cyan
bakwht='\x1b[47m'   # White
txtrst='\x1b[0m'    # Text Reset


def output(*args):
    for arg in args:
        sys.stdout.write(arg)

def blocks(f, size, read=4096):
    newdata, data = True, ""
    while newdata:
        while len(data) > size:
            yield data[:size]
            data = data[size:]
        newdata = f.read(read)
        data += newdata
    if data:
        yield data


def hexdump_line(block, line=16, addr=0):
    addr = "%x" % addr
    output(bldblk, max(8 - len(addr), 0) * "0", bldwht, "%s  " % addr)

    for i, byte in enumerate(block):
        if byte == "\x00":
            output("%s%.2x" % (txtblk if i % 2 else bldblk, ord(byte)))
        elif 0x20 < ord(byte) < 0x7e:
            output("%s%.2x" % (txtpur if i % 2 else bldpur, ord(byte)))
        else:
            output("%s%.2x" % (txtwht if i % 2 else bldwht, ord(byte)))
        if i % 4 == 3: output(" ")
    for i in xrange(i+1, line):
        output("  ")
        if i % 4 == 3: output(" ")
    output("%s " % txtrst)

    for i, byte in enumerate(block):
        if byte == "\n":
            output("↩")
        elif byte != " " and byte.isspace():
            output("␣")
        elif byte in string.printable:
            output(txtwht if i % 2 else bldwht, byte)
        else:
            output(txtblk if i % 2 else bldblk, ".")

    for i in xrange(i, line):
        output(" ")

    output("%s\n" % txtrst)


def hexdump(f, line=16, addr=0, verbose=True):
    last, censored = None, False

    for block in blocks(f, line):
        if verbose or block != last:
            if censored:
                output("...\n")
                censored = False
            hexdump_line(block, line, addr)
        else:
            censored = True
        last = block
        addr += line

    if censored:
        output("...\n")

if __name__ == '__main__':

    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="?", type=argparse.FileType("rb"), default=sys.stdin)
    parser.add_argument("-q", "--quiet", action="store_true", help="remove duplicates")
    parser.add_argument("-c", "--colors", action="store_true", help="force colors")
    args = parser.parse_args()

    if not sys.stdout.isatty() and not args.colors:
        (txtblk, txtred, txtgrn, txtylw, txtblu, txtpur, txtcyn, txtwht, bldblk,
         bldred, bldgrn, bldylw, bldblu, bldpur, bldcyn, bldwht, undblk, undred,
         undgrn, undylw, undblu, undpur, undcyn, undwht, bakblk, bakred, bakgrn,
         bakylw, bakblu, bakpur, bakcyn, bakwht, txtrst) = (
            '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '',
            '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '')

    try:
        hexdump(args.file, verbose = not args.quiet)
    except (IOError, KeyboardInterrupt):
        pass
