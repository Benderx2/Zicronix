scc -seg16 -no-externs -I D:\Zicronix\core\zincldr\interface\include example.c example.s
nasm -f bin example.s -o example.bin
pause