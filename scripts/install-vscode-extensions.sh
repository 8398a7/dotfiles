#!/bin/bash -eu

while IFS= read -r extension
do
  echo $extension installing...
  code --install-extension $extension
done < 'vscode/extensions.txt'
