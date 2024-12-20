#!/usr/bin/env bash

(
    set -e

    # Current dir should be the root of the repo
    cd "$(dirname $0)/.."

    git config --global core.longpaths true
    git clone --depth 1 --branch 9.0.5 https://github.com/adafruit/circuitpython.git

    cd circuitpython

    # use the make commands instead of the git commands
    make fetch-all-submodules

    # Use a venv for these
    # Using this name so circuitpython repo already gitignores it
    python3 -m venv .venv/
    ls -l .venv
    ls -l .venv/bin || true
    . .venv/bin/activate

    # `make stubs` in circuitpython
    pip3 install wheel  # required on debian buster for some reason
    pip3 install -r requirements-doc.txt
    make stubs
    if [ -d ../stubs ]; then
        mv circuitpython-stubs/* ../stubs/
    else
        # if stubs already exists, this would get interpreted as "move circuitpython-stubs *into* stubs"
        # hence the "if".  Friendlier than the alternative, `rm -rf stubs`
        mv circuitpython-stubs/ ../stubs
    fi
    cd ..

    # scripts/build_stubs.py in this repo for board stubs
    python3 ./scripts/build_stubs.py
    rm -rf stubs/board

    # was crashing on `deactivate`, but guess what?! We're in parenthesis, so
    # it's a subshell. venv will go away when that subshell exits, which is,
    # wait for it.... now!
)
