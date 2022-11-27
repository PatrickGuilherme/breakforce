# 1 = data file
# 2 = label
# 3 = name of file
# 4 = row name

echo "shell script for plotting data  using gnuplot"
gnuplot <<EOF
set terminal png font 'Times new roman'
set grid
unset key
set output "$3"
set xtics 2
set style line 1 lt 2 lc rgb "cyan"   lw 2 
set style line 2 lt 2 lc rgb "red"    lw 2
set style line 3 lt 2 lc rgb "gold"   lw 2
set ytics nomirror
set xlabel "$4"
set ylabel "Tempo"
set key top left
set key box
set style data lines
plot "$1" using 2:xtic(1) title "$2"    ls 1 with linespoints

EOF
