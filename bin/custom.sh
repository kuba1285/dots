#!/bin/bash

cd
git clone http://github.com/possatti/pokemonsay &>> $INSTLOG
cd pokemonsay
./install.sh &>> $INSTLOG

cd
wget https://github.com/autopawn/3d-ascii-viewer/archive/refs/tags/v1.4.0.tar.gz
tar xvzf v1.4.0.tar.gz
cd 3d-ascii-viewer*
make
find ./models -name "*.mtl" -type f | xargs rm
mv 3d-ascii-viewer models /Users/$USER/bin/.
