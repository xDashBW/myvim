import sys

if sys.version_info[0] >= 3:
    import collections
    if 'Callable' not in collections.__dict__:
        try:
            import collections.abc
            if 'Callable' in collections.abc.__dict__:
                collections.Callable = collections.abc.Callable
        except ImportError:
            pass
    del collections

import rlcompleter

try:
    import readline
    readline.parse_and_bind('tab: complete')
    del readline
except ImportError:
    pass

del rlcompleter, sys

try:
    import rich
    import rich.pretty
    rich.pretty.install()
    del rich
except ImportError:
    pass


