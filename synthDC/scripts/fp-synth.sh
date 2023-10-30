#!/bin/bash

# RADIX 2
setRADIXeq2 () {
n64=$(grep -n "RADIX" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "RADIX" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/RADIX.*/RADIX = 32\'h2;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/RADIX.*/RADIX = 32\'h2;/" $WALLY/config/rv32gc/config.vh
}

# RADIX 4
setRADIXeq4 () {
n64=$(grep -n "RADIX" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "RADIX" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/RADIX.*/RADIX = 32\'h4;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/RADIX.*/RADIX = 32\'h4;/" $WALLY/config/rv32gc/config.vh
}

# K = 1
setKeq1 () {
n64=$(grep -n "DIVCOPIES" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "DIVCOPIES" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/DIVCOPIES.*/DIVCOPIES = 32\'h1;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/DIVCOPIES.*/DIVCOPIES = 32\'h1;/" $WALLY/config/rv32gc/config.vh
}

# K = 2
setKeq2 () {
n64=$(grep -n "DIVCOPIES" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "DIVCOPIES" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/DIVCOPIES.*/DIVCOPIES = 32\'h2;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/DIVCOPIES.*/DIVCOPIES = 32\'h2;/" $WALLY/config/rv32gc/config.vh
}

# K = 4
setKeq4 () {
n64=$(grep -n "DIVCOPIES" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "DIVCOPIES" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/DIVCOPIES.*/DIVCOPIES = 32\'h4;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/DIVCOPIES.*/DIVCOPIES = 32\'h4;/" $WALLY/config/rv32gc/config.vh
}

# IDIVBITS = 1
setIDIVBITSeq1 () {
n64=$(grep -n "IDIV_BITSPERCYCLE =" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "IDIV_BITSPERCYCLE =" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/IDIV_BITSPERCYCLE.*/IDIV_BITSPERCYCLE = 32\'d1;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/IDIV_BITSPERCYCLE.*/IDIV_BITSPERCYCLE = 32\'d1;/" $WALLY/config/rv32gc/config.vh
}

# IDIVBITS = 2
setIDIVBITSeq2 () {
n64=$(grep -n "IDIV_BITSPERCYCLE =" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "IDIV_BITSPERCYCLE =" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/IDIV_BITSPERCYCLE.*/IDIV_BITSPERCYCLE = 32\'d2;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/IDIV_BITSPERCYCLE.*/IDIV_BITSPERCYCLE = 32\'d2;/" $WALLY/config/rv32gc/config.vh
}

# IDIVBITS = 4
setIDIVBITSeq4 () {
n64=$(grep -n "IDIV_BITSPERCYCLE =" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "IDIV_BITSPERCYCLE =" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/IDIV_BITSPERCYCLE.*/IDIV_BITSPERCYCLE = 32\'d4;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/IDIV_BITSPERCYCLE.*/IDIV_BITSPERCYCLE = 32\'d4;/" $WALLY/config/rv32gc/config.vh
}

# IDIV ON FPU
setIDIVeq1 () {
n64=$(grep -n "IDIV_ON_FPU" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "IDIV_ON_FPU" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/IDIV_ON_FPU.*/IDIV_ON_FPU = 1;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/IDIV_ON_FPU.*/IDIV_ON_FPU = 1;/" $WALLY/config/rv32gc/config.vh
}

# IDIV NOT ON FPU
setIDIVeq0 () {
n64=$(grep -n "IDIV_ON_FPU" $WALLY/config/rv64gc/config.vh | cut -d: -f1)
n32=$(grep -n "IDIV_ON_FPU" $WALLY/config/rv32gc/config.vh | cut -d: -f1)
sed -i "${n64}s/IDIV_ON_FPU.*/IDIV_ON_FPU = 0;/" $WALLY/config/rv64gc/config.vh
sed -i "${n32}s/IDIV_ON_FPU.*/IDIV_ON_FPU = 0;/" $WALLY/config/rv32gc/config.vh
}

# Synthesize Integer Divider
synthIntDiv () {
make -C $WALLY/synthDC synth DESIGN=div TECH=tsmc28 CONFIG=rv32gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle) &
make -C $WALLY/synthDC synth DESIGN=div TECH=tsmc28 CONFIG=rv64gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle) &
make -C $WALLY/synthDC synth DESIGN=div TECH=tsmc28 CONFIG=rv32gc FREQ=100 WRAPPER=1 TITLE=$(getTitle) &
make -C $WALLY/synthDC synth DESIGN=div TECH=tsmc28 CONFIG=rv64gc FREQ=100 WRAPPER=1 TITLE=$(getTitle) &
wait
}

# Synthesize FP Divider Unit

synthFPDiv () {
make -C $WALLY/synthDC synth DESIGN=drsu TECH=tsmc28 CONFIG=rv32gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle) &
make -C $WALLY/synthDC synth DESIGN=drsu TECH=tsmc28 CONFIG=rv64gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle) &
make -C $WALLY/synthDC synth DESIGN=drsu TECH=tsmc28 CONFIG=rv32gc FREQ=100 WRAPPER=1 TITLE=$(getTitle) &
make -C $WALLY/synthDC synth DESIGN=drsu TECH=tsmc28 CONFIG=rv64gc FREQ=100 WRAPPER=1 TITLE=$(getTitle) &
wait
}

synthAll () {
    synthIntDiv &
    wait
    synthFPDiv &
    wait

}


# Synthesize DivSqrt Preprocessor

synthFPDivsqrtpreproc () {
make -C $WALLY/synthDC synth DESIGN=fdivsqrtpreproc TECH=tsmc28 CONFIG=rv32gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle)
make -C $WALLY/synthDC synth DESIGN=fdivsqrtpreproc TECH=tsmc28 CONFIG=rv64gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle)
make -C $WALLY/synthDC synth DESIGN=fdivsqrtpreproc TECH=tsmc28 CONFIG=rv32gc FREQ=100 WRAPPER=1 TITLE=$(getTitle)
make -C $WALLY/synthDC synth DESIGN=fdivsqrtpreproc TECH=tsmc28 CONFIG=rv64gc FREQ=100 WRAPPER=1 TITLE=$(getTitle)
}

synthFPDiviter () {
make -C $WALLY/synthDC synth DESIGN=fdivsqrtiter TECH=tsmc28 CONFIG=rv32gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle)
make -C $WALLY/synthDC synth DESIGN=fdivsqrtiter TECH=tsmc28 CONFIG=rv64gc FREQ=3000 WRAPPER=1 TITLE=$(getTitle)
make -C $WALLY/synthDC synth DESIGN=fdivsqrtiter TECH=tsmc28 CONFIG=rv32gc FREQ=100 WRAPPER=1 TITLE=$(getTitle)
make -C $WALLY/synthDC synth DESIGN=fdivsqrtiter TECH=tsmc28 CONFIG=rv64gc FREQ=100 WRAPPER=1 TITLE=$(getTitle)
}

# forms title for synthesis

getTitle () {
RADIX=$(sed -n "157p" $WALLY/config/rv64gc/config.vh | tail -c 3 | head -c 1)
K=$(sed -n "158p" $WALLY/config/rv64gc/config.vh | tail -c 3 | head -c 1)
IDIV=$(sed -n "81p" $WALLY/config/rv64gc/config.vh | tail -c 3 | head -c 1)
IDIVBITS=$(sed -n "80p" $WALLY/config/rv64gc/config.vh | tail -c 3 | head -c 1)
title="RADIX_${RADIX}_K_${K}_INTDIV_${IDIV}_IDIVBITS_${IDIVBITS}"
echo $title
}

# writes area delay of runs to csv
writeCSV () {
    echo "design,area,timing" > $WALLY/synthDC/fp-synth.csv
    # iterate over all files in runs/
    for FILE in $WALLY/synthDC/runs/*;
    do
        design="${FILE##*/}"

        # grab area
        areaString=($(grep "Total cell area" $FILE/reports/area.rep))
        area=${areaString[3]}

        # grab timing
        timingString=($(grep "data arrival time" $FILE/reports/timing.rep))
        timing=${timingString[3]}

        # write to csv
        echo $design,$area,$timing >> $WALLY/synthDC/fp-synth.csv
        
    done;
}

go() {

<< comment
setIDIVeq1
setKeq1
setRADIXeq4
synthFPDiv
wait
setKeq2
setRADIXeq2
synthFPDiv
wait
comment
setIDIVBITSeq1
synthIntDiv
setIDIVBITSeq2
synthIntDiv
setIDIVBITSeq4
synthIntDiv
<< comment
setIDIVeq0
setKeq1
setRADIXeq4
synthFPDiv
wait
setKeq2
setRADIXeq2
synthFPDiv
comment




}

go2() {

setIDIVeq1
setRADIXeq4
setKeq2
synthFPDiv
wait
setRADIXeq2
setKeq4
synthFPDiv
wait

}
