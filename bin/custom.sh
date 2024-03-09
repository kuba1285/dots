#!/bin/bash

cd
go install github.com/orangekame3/paclear@latest

cd
wget https://github.com/autopawn/3d-ascii-viewer/archive/refs/tags/v1.4.0.tar.gz
tar xvzf v1.4.0.tar.gz
cd 3d-ascii-viewer*
make
find ./models -name "*.mtl" -type f | xargs rm
mv 3d-ascii-viewer models $HOME/bin/.
cd
rm v1.4.0.tar.gz
rm -rf 3d-ascii-viewer*
