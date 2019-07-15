#!/bin/bash

OUT=./imgs

if [ ! -d $OUT ]; then
    mkdir $OUT
else
    echo "moving already existing images to $OUT/old"
    mkdir $OUT/old
    mv $OUT/*.simg $OUT/old
fi

function cosmos(){
    echo "Building cosmos in $OUT/cosmos.simg"
    sudo singularity build $OUT/cosmos.simg Singularity.cosmos
}

function corda(){
    echo "Building corda in $OUT/corda.simg"
    sudo singularity build $OUT/corda.simg Singularity.corda
}

function truffle(){
    echo "Building truffle in $OUT/truffle.simg"
    sudo singularity build $OUT/truffle.simg Singularity.truffle
}

function iota(){
    echo "Building iota in $OUT/iota.simg"
    sudo singularity build $OUT/iota.simg Singularity.iota
}

MODE=$1
if [ "$MODE" == "cosmos" ]; then
    cosmos
elif [ "$MODE" == "corda" ]; then
    corda
elif [ "$MODE" == "truffle" ]; then
    truffle
elif [ "$MODE" == "iota" ]; then
    iota
else
    cosmos
    corda
    truffle
    iota
fi
