#!/bin/bash

FLAG=$1
if [ -z $FLAG ] ; then
    FLAG=undefine_cs
fi

./shell/cs_kill.sh $FLAG
./shell/cs_run.sh $FLAG
