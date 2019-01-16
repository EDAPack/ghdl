#!/bin/bash
#********************************************************************
#* runit.sh
#*
#* Smoke test for the EDAPack version of GHDL
#********************************************************************

export tool=ghdl
export version=unknown

function fail()
{
  echo "FAIL: $tool $version ($tmpdir)" 
  exit 1
}

function try()
{
  $* > log 2>&1
  if test $? -ne 0; then 
    echo "Error log:"
    cat log
    fail
  fi
}

function note()
{
  echo "[$tool] Note: $*"
}

smoketest_dir=$(dirname $0)
smoketest_dir=$(cd $smoketest_dir ; pwd)

tool_dir=$(dirname $smoketest_dir)
version=$(basename $tool_dir)

tmpdir=`mktemp -d`
note "running test in $tmpdir"

try cd $tmpdir
try cp $smoketest_dir/hello.vhd .
#test_fail $?

note "Running $tool"
note "Analyzing source"
try $tool_dir/bin/ghdl -a hello.vhd
note "Elaborating source"
try $tool_dir/bin/ghdl -e hello_world
note "Running simulation"
$tool_dir/bin/ghdl -r hello_world > run.log 2>&1

if test $? -ne 0; then
  fail
fi

count=$(grep 'Hello world' run.log | wc -l)

note "Checking logfile"
if test $count -ne 1; then
  fail
fi

echo "PASS: $tool $version"
rm -rf $tmpdir

