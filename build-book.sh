#!/bin/bash

set -e

mkdir -p public
# cargo install mdbook --no-default-features
pushd src
mdbook build
popd
cp -r ./target/doc/ ./public
cp -r ./book/book/* ./public
find $PWD/public | grep "\.html\$"

set +e
