scc-znu -seg32 -no-externs prime.c prime.asm
nasm -f bin prime.asm -o prime.znx
pause
del helloc.asm