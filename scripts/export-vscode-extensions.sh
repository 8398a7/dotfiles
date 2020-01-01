#!/bin/bash -xeu

cd vscode
mv extensions.txt extensions.old.txt
code --list-extensions > extensions.txt
rm extensions.old.txt
