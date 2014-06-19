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
from exporters import Exporter
from os.path import basename


class Uvision4(Exporter):
    NAME = 'uVision4'

    TARGETS = [
        'LPC1768',
        'LPC11U24',
        'KL05Z',
        'KL25Z',
        'KL46Z',
        'K64F',
        'K20D5M',
        'LPC1347',
        'LPC1114',
        'LPC11C24',
        'LPC4088',
        'LPC812',
        'NUCLEO_F030R8',
        'NUCLEO_F072RB',
        'NUCLEO_F103RB',
        'NUCLEO_F302R8',
        'NUCLEO_F401RE',
        'NUCLEO_L053R8',
        'NUCLEO_L152RE',
        'UBLOX_C027',
        'LPC1549',
        'LPC11U35_501',
        'NRF51822',
        'ARCH_PRO',
    ]

    USING_MICROLIB = [
        'LPC11U24',
        'LPC1114',
        'LPC11C24',
        'LPC812',
        'NUCLEO_F030R8',
        'NUCLEO_F072RB',
        'NUCLEO_F103RB',
        'NUCLEO_F302R8',
        'NUCLEO_F401RE',
        'NUCLEO_L053R8',
        'NUCLEO_L152RE',
        'LPC1549',
        'LPC11U35_501',
        'KL05Z',
    ]

    FILE_TYPES = {
        'c_sources':'1',
        'cpp_sources':'8',
        's_sources':'2'
    }

    FLAGS = [
        "--gnu",
    ]

    # By convention uVision projects do not show header files in the editor:
    # 'headers':'5',

    def get_toolchain(self):
        return 'uARM' if (self.target in self.USING_MICROLIB) else 'ARM'

    def get_flags(self):
        return self.FLAGS

    def generate(self):
        source_files = {
            'mbed': [],
            'hal': [],
            'src': []
        }
        for r_type, n in Uvision4.FILE_TYPES.iteritems():
            for file in getattr(self.resources, r_type):
                f = {'name': basename(file), 'type': n, 'path': file}
                if file.startswith("mbed\\common"):
                    source_files['mbed'].append(f)
                elif file.startswith("mbed\\targets"):
                    source_files['hal'].append(f)
                else:
                    source_files['src'].append(f)
        source_files = dict( [(k,v) for k,v in source_files.items() if len(v)>0])
        ctx = {
            'name': self.program_name,
            'include_paths': self.resources.inc_dirs,
            'scatter_file': self.resources.linker_script,
            'object_files': self.resources.objects + self.resources.libraries,
            'source_files': source_files.items(),
            'symbols': self.toolchain.get_symbols(),
            'hex_files' : self.resources.hex_files,
            'flags' : self.get_flags(),
        }
        target = self.target.lower()
        # Project file
        self.gen_file('uvision4_%s.uvproj.tmpl' % target, ctx, '%s.uvproj' % self.program_name)
        self.gen_file('uvision4_%s.uvopt.tmpl' % target, ctx, '%s.uvopt' % self.program_name)
