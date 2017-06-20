from __future__ import print_function

import os
import json
import shutil
import binascii

UTILITY_PATH = 'utility/'


def read_JSON(path):
    with open(path, 'r') as handle:
        data = handle.read()
    return json.loads(data)


def to_MIPS_ASM(src, dst):
    with open(dst, 'w') as writer:
        with open(src, 'r') as reader:
            writer.write('\t.org 0x0\n')
            writer.write('\t.global _start\n')
            writer.write('\t.set noat\n')
            writer.write('_start:\n')
            for line in reader:
                writer.write('\t' + line)


def forced_makedirs(path):
    if os.path.isfile(path):
        os.remove(path)
    if os.path.isdir(path):
        shutil.rmtree(path)
    os.makedirs(path)

if __name__ == "__main__":
    tests = read_JSON('tests/test.json')
    forced_makedirs('result')
    for test in tests:
        print('running on test "{}"...'.format(test['name']))
        forced_makedirs('.tmp')
        os.makedirs('result/' + test['report'])
        shutil.copy('tests/' + test['path'], '.tmp/program.mips')
        to_MIPS_ASM('.tmp/program.mips', '.tmp/program.s')
        os.system('{}/mips-2014.05/bin/mips-sde-elf-as -mips32 .tmp/program.s -o .tmp/program.o'.format(UTILITY_PATH))
        os.system(
            '{}/mips-2014.05/bin/mips-sde-elf-ld -T {}/ram.ld .tmp/program.o -o .tmp/program.exa'.format(UTILITY_PATH,
                                                                                                         UTILITY_PATH))
        os.system(
            '{}/mips-2014.05/bin/mips-sde-elf-objcopy -O binary .tmp/program.exa .tmp/program.bin'.format(UTILITY_PATH,
                                                                                                          UTILITY_PATH))
        with open('source/program.rom', 'w') as writer:
            data = binascii.b2a_hex(open(".tmp/program.bin", "rb").read())
            for i in xrange(len(data) >> 3):
                writer.write(str(data[i * 8: (i + 1) * 8]) + '\n')
        nowpath = os.path.abspath(os.path.curdir)
        os.chdir('source/')
        os.system('make > /dev/null')
        os.chdir(nowpath)
        shutil.move('source/compiler.txt', 'result/' + test['report'] + '/')
        shutil.move('source/wave.lxt', 'result/' + test['report'] + '/')
        shutil.rmtree('.tmp')
