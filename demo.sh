#!/bin/sh

XC_REPO=https://github.com/davecheney/golang-crosscompile 
XC_DIR=/tmp/$(basename $XC_REPO)

PROJ=github.com/ianremmler/setgo/cmd/setgo
CMD=$(basename $PROJ)

#### cross compiler helper script

rm -Rf $XC_DIR
git clone $XC_REPO $XC_DIR
cp $XC_DIR/crosscompile.bash $GOPATH
source $GOPATH/crosscompile.bash

#### build the cross compile toolchain

pushd
go-crosscompile-build linux/arm
popd

#### cross compile our program

go-linux-arm get -u $PROJ

#### put it on the device

# device must be rooted and have adb root access enabled

adb root
adb shell mkdir /data/local/bin
adb shell chmod 755 /data/local/bin
adb push $GOPATH/bin/linux-arm/$CMD /data/local/bin
adb shell setprop service.adb.root 0
adb shell restart adbd \&

#### run it!

adb shell /data/local/bin/$CMD
