#!/bin/bash
set -eo pipefail
set -x

ROOT_DIR="$(/usr/local/bin/realpath $(dirname "$0"))"
rm -rf $ROOT_DIR/photos/*
