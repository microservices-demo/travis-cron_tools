#!/usr/bin/env nix-shell
#!nix-shell -i bash -p inotify-tools graphviz pandoc

build_dot() {
  file=$1
  echo -n "Building ${file} on "
  date
  dot $file -Tpdf > ${file%.dot}.pdf
  dot $file -Tpng > ${file%.dot}.png
  echo done
}

build_md() {
  file=$1
  echo -n "Building ${file} on"
  date
  pandoc $file -o ${file%.md}.html
  echo done
}


build() {
  file=$1
  ext=${file##*.}

  case $ext in 
    "md") build_md $file ;;
    "dot") build_dot $file ;;
    *) echo "CANNOT BUILD '$ext' extension" ;;
  esac
}

files=$(echo README.md doc/fig/*.dot)

for file in $files; do
  build $file
done

while true; do
  inotifywait -s $files | while read -r file action; do
    build $file
  done
done
