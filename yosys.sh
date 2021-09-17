#!usr/bin/bash

yosys -o synth.v -p hierarchy -p proc -p opt -p memory -p opt -p fsm -p opt -p "show -colors 1 -viewer touch -format svg" -f verilog design_synth.sv 2>&1 | awk '/^[0-9]+\. / { lines = 100; } /^[0-9]+\.[0-9]+\. / { lines = lines > 10 ? lines : 10; } { if (--lines > 0) print; if (lines == 0) print "[ ... ]\n"; } /READY\./ { if (lines <= 0) print; }'
