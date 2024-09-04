import os
import sys


def log(*args, **kwargs):
    """
    Log a message to stderr.
    """
    print(*args, file=sys.stderr, **kwargs)


class TerminalLogger:
    def __init__(self, no_color=False):
        if not sys.stderr.isatty() or no_color or os.environ.get('TERM', '') == 'dumb':
            for attr in dir(self):
                if not attr.startswith('_'):
                    setattr(self, attr, "")

    NOFORMAT = "\033[0m"
    B, B_END = "\033[1m", "\033[22m"
    I, I_END = "\033[3m", "\033[23m"
    U, U_END = "\033[4m", "\033[24m"
    BLACK,   BLACK_BG,   BR_BLACK,   BR_BLACK_BG   = "\033[30m", "\033[40m", "\033[90m", "\033[100m"
    RED,     RED_BG,     BR_RED,     BR_RED_BG     = "\033[31m", "\033[41m", "\033[91m", "\033[101m"
    GREEN,   GREEN_BG,   BR_GREEN,   BR_GREEN_BG   = "\033[32m", "\033[42m", "\033[92m", "\033[102m"
    YELLOW,  YELLOW_BG,  BR_YELLOW,  BR_YELLOW_BG  = "\033[33m", "\033[43m", "\033[93m", "\033[103m"
    BLUE,    BLUE_BG,    BR_BLUE,    BR_BLUE_BG    = "\033[34m", "\033[44m", "\033[94m", "\033[104m"
    MAGENTA, MAGENTA_BG, BR_MAGENTA, BR_MAGENTA_BG = "\033[35m", "\033[45m", "\033[95m", "\033[105m"
    CYAN,    CYAN_BG,    BR_CYAN,    BR_CYAN_BG    = "\033[36m", "\033[46m", "\033[96m", "\033[106m"
    WHITE,   WHITE_BG,   BR_WHITE,   BR_WHITE_BG   = "\033[37m", "\033[47m", "\033[97m", "\033[107m"
    DEFAULT, DEFAULT_BG                            = "\033[39m", "\033[49m"
