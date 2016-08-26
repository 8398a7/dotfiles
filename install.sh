for file in `find ./shell -maxdepth 1 -type f`; do
  bash $file
done
eval $SHELL
