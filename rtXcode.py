#!/usr/bin/env python
# -*- coding:utf-8 -*-

__author__ = 'Bin'

import subprocess,time,logging;logging.basicConfig(level=logging.INFO)

process = None

def start_killxcodeprocess():
    global process
    process = subprocess.Popen('pkill -9 -x Xcode && sleep 0.3 && open /Applications/Xcode.app',shell=True,stdout=subprocess.PIPE)
    pid = process.pid
    logging.info('start process: pid.......%s' % pid)


if __name__ == '__main__':
    start_killxcodeprocess()

