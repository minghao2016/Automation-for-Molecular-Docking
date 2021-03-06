#! /usr/bin/env bash

discover() {
cd sdf-2d
echo Finding 2d files
allthemfiles=( $(find .) )
echo Found: ${#allthemfiles[@]}
cd ../sdf-3d
echo Finding 3d Files
allthemdonefiles=( $(find .) )
echo Found: ${#allthemdonefiles[@]}
cd ..
echo Removing already computed 3d files from array
#this made me rethink life, our place in the universe and the upcoming singularity
allthemfiles=($(echo ${allthemdonefiles[@]} ${allthemfiles[@]} | tr ' ' '\n' | sort | uniq -u))
allthemdonefiles=()
prefix='./sdf-2d/'
}

main() {
[ -e "$1" ] && allthemfiles=( $(cat $1) )
[ "$allthemfiles" ] || discover
files=${#allthemfiles[@]}
divdummy=$(( files / threads ))
echo Converting sdf input files $files
lastfile=0
for thread_i in ${count[@]} last
  do local thread_files=( ${allthemfiles[@]:$lastfile:$divdummy} )
  lastfile=$((lastfile + divdummy + 1))
  babel_thread &
done
allthemfiles=()
wait
rm /tmp/gen3dpipe*
}

babel_thread() {
i=0
total=${#thread_files[@]}
allthemfiles=()
while [ "${thread_files[$i]}" ]
  do for file in ${thread_files[@]:$i:50}
    do echo $file >> ./babel-logs/babel-output-gen3d-$date-thread-$thread_i.log &
    timeout 20s obabel -i sdf "$prefix""$file" --gen3d -o sdf\
    -p 7.4 -O ./sdf-3d/$(basename "$file")\
    &>> ./babel-logs/babel-output-gen3d-$date-thread-$thread_i.log || echo "$file" >> bad_sdfs
  done
  echo Thread $thread_i: $i /$total > /tmp/gen3dpipe$thread_i &
  i=$(( i + 50 ))
done
echo Thread $thread_i exited > /tmp/gen3dpipe$thread_i
}

sane() {
for i in sdf-3d babel-logs
  do [ -e $i ] || mkdir $i
done
[ -e sdf-2d ] || exit 2
[ "$threads" -eq "$threads" ] &> /dev/null ||
echo Please specify a correct thread count
count=($(eval echo {$threads..1}))
date=$(date +%F)
}

threads=$1
sane
main $2
