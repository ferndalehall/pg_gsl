name="$1"

awk ' {
for(i=1;i<=NF;i++)printf("%d %s\n", i - 1, $i);
} ' /tmp/$1.dat > /tmp/$$.dat

(
cat <<!
set title ""
set xlabel ""
set ylabel ""
set zlabel ""
unset logscale x
unset logscale y
unset logscale z
set term svg size 300,240
set xtics  20
plot [:] [-5.0:5.0] [:] '/tmp/$$.dat' using 1:2  with lines     title "$1 " 
!
) | gnuplot > ${name}.svg

rm /tmp/$$.dat
name="signal+filtered75"

awk ' {
for(i=1;i<=NF;i++)printf("%d %s\n", i - 1, $i);
} ' /tmp/signal.dat > /tmp/$$.1.dat

awk ' {
for(i=1;i<=NF;i++)printf("%d %s\n", i - 1, $i);
} ' /tmp/filtered75.dat > /tmp/$$.2.dat

(
cat <<!
set title ""
set xlabel ""
set ylabel ""
set zlabel ""
unset logscale x
unset logscale y
unset logscale z
set term svg size 300,240
set xtics  20
plot [:] [-5.0:5.0] [:] '/tmp/$$.1.dat' using 1:2  with lines     title "signal " , '/tmp/$$.2.dat' using 1:2  with lines  lc rgb '#fde725'   title "filtered "
!
) | gnuplot > ${name}.svg

#rm /tmp/$$.[12].dat
