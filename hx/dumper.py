import struct
import string
import argparse

import colorama


def init_colorama(colors=True):
    colorama.init(strip=None if colors else True,
                  convert=None if colors else False)


class BaseDflts(argparse.Action):

    def __init__(self, **kwargs):
        kwargs['nargs'] = 0
        super().__init__(**kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, 'bpg', self.bpg)
        setattr(namespace, 'gpl', self.gpl)
        setattr(namespace, 'fmt', self.fmt)


class BinDflts(BaseDflts):
    bpg = 1
    gpl = 4
    fmt = "{0:08b}"
    hld = '        '


class OctDflts(BaseDflts):
    bpg = 2
    gpl = 4
    fmt = "{0:03o}"
    hld = '   '


class HexDflts(BaseDflts):
    bpg = 4
    gpl = 4
    fmt = "{0:02x}"
    hld = '  '


class Dumper():

    def __init__(self, bpg=HexDflts.bpg, gpl=HexDflts.gpl,
                 fmt=HexDflts.fmt, hld=HexDflts.hld, col=True):
        self.bpg = bpg
        self.gpl = gpl
        self.fmt = fmt
        self.hld = hld
        self.col = col

    def dump(self, f, addr=0):

        nextbyte = self.get_byte(f)

        while nextbyte is not None:
            self.start_line(addr)
            for _ in range(self.gpl):
                self.start_group()
                for _ in range(self.bpg):
                    addr += 1
                    self.dump_byte(nextbyte)
                    nextbyte = None if nextbyte is None else self.get_byte(f)
                self.end_group()
            self.end_line()

    def output(self, *args):
        print(*args, end='', sep='')

    def get_byte(self, f):
        byte = f.read(1)
        if not len(byte):
            return None
        return struct.unpack('B', byte)[0]

    def dump_byte(self, byte):
        txt = self.hld if byte is None else self.fmt.format(byte)

        if self.col and not len(self.line) % 2:
            bck = colorama.Style.BRIGHT
        else:
            bck = colorama.Style.NORMAL

        self.output(bck, self.color(byte), txt, colorama.Style.RESET_ALL)

        self.group.append(byte)
        self.line.append(byte)

    def color(self, byte, text=True):
        if not byte:
            return colorama.Fore.BLACK
        if text and 0x20 < byte <= 0x7e:
            return colorama.Fore.MAGENTA
        return colorama.Fore.WHITE

    def printable(self, byte):
        if byte is None:
            return ' '
        c = chr(byte)
        if c == '\n':
            return '↩'
        if c != ' ' and c.isspace():
            return '␣'
        if c in string.printable:
            return c
        return '·'

    def start_group(self):
        self.group = []

    def end_group(self):
        self.output(' ')

    def start_line(self, addr):
        self.line = []
        txt = '%x  ' % addr
        nil = '0' * max(10 - len(txt), 0)
        self.output(colorama.Style.BRIGHT, colorama.Fore.BLACK,
                    nil, colorama.Fore.WHITE, txt)

    def end_line(self):
        self.output(colorama.Fore.WHITE, ' ')
        for i, byte in enumerate(self.line):

            if self.col and not i % 2:
                bck = colorama.Style.BRIGHT
            else:
                bck = colorama.Style.NORMAL

            self.output(bck, self.color(byte, text=False),
                        self.printable(byte), colorama.Style.RESET_ALL)

        self.output('\n')
