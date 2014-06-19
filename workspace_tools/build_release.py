"""
mbed SDK
Copyright (c) 2011-2013 ARM Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
import sys
from time import time
from os.path import join, abspath, dirname
from optparse import OptionParser

# Be sure that the tools directory is in the search path
ROOT = abspath(join(dirname(__file__), ".."))
sys.path.insert(0, ROOT)

from workspace_tools.build_api import build_mbed_libs
from workspace_tools.targets import TARGET_MAP

OFFICIAL_MBED_LIBRARY_BUILD = (
    ('LPC11U24',     ('ARM', 'uARM', 'GCC_ARM')),
    ('LPC1768',      ('ARM', 'GCC_ARM', 'GCC_CR', 'GCC_CS', 'IAR')),
    ('UBLOX_C027',   ('ARM', 'GCC_ARM', 'GCC_CR', 'GCC_CS', 'IAR')),
    ('ARCH_PRO',   ('ARM', 'GCC_ARM', 'GCC_CR', 'GCC_CS', 'IAR')),
    ('LPC2368',      ('ARM',)),
    ('LPC812',       ('uARM',)),
    ('LPC1347',      ('ARM',)),
    ('LPC4088',      ('ARM', 'GCC_ARM', 'GCC_CR')),
    ('LPC1114',      ('uARM','GCC_ARM')),
    ('LPC11U35_401', ('ARM', 'uARM','GCC_ARM','GCC_CR')),
    ('LPC11U35_501', ('ARM', 'uARM','GCC_ARM','GCC_CR')),
    ('LPC1549',      ('uARM',)),

    ('KL05Z',        ('ARM', 'uARM', 'GCC_ARM')),
    ('KL25Z',        ('ARM', 'GCC_ARM')),
    ('KL46Z',        ('ARM', 'GCC_ARM')),
    ('K64F',         ('ARM', 'GCC_ARM')),

    ('NUCLEO_F030R8', ('ARM', 'uARM')),
    ('NUCLEO_F072RB', ('ARM', 'uARM')),
    ('NUCLEO_F103RB', ('ARM', 'uARM')),
    ('NUCLEO_F302R8', ('ARM', 'uARM')),
    ('NUCLEO_F401RE', ('ARM', 'uARM')),
    ('NUCLEO_L053R8', ('ARM', 'uARM')),
    ('NUCLEO_L152RE', ('ARM', 'uARM')),

    ('NRF51822', ('ARM', )),

    ('LPC11U68', ('uARM',)),
)


if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option('-o', '--official', dest="official_only", default=False, action="store_true",
                      help="Build using only the official toolchain for each target")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Verbose diagnostic output")
    options, args = parser.parse_args()
    start = time()
    failures = []
    successes = []
    for target_name, toolchain_list in OFFICIAL_MBED_LIBRARY_BUILD:
        if options.official_only:
            toolchains = (getattr(TARGET_MAP[target_name], 'ONLINE_TOOLCHAIN', 'ARM'),)
        else:
            toolchains = toolchain_list
        for toolchain in toolchains:
            id = "%s::%s" % (target_name, toolchain)
            try:
                build_mbed_libs(TARGET_MAP[target_name], toolchain, verbose=options.verbose)
                successes.append(id)
            except Exception, e:
                failures.append(id)
                print e

    # Write summary of the builds
    print "\n\nCompleted in: (%.2f)s" % (time() - start)

    if successes:
        print "\n\nBuild successes:"
        print "\n".join(["  * %s" % s for s in successes])

    if failures:
        print "\n\nBuild failures:"
        print "\n".join(["  * %s" % f for f in failures])
