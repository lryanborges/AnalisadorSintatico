Segue o passo a passo pra executar o Analisador Léxico em C++:

 - Deve ser executado dentro de um sistema Unix
 - No terminal:
  1. sudo apt update
  2. sudo apt upgrade
  3. sudo apt install g++ gdb
  4. sudo apt install make cmake
  5. sudo apt install flex libfl-dev
  6. sudo apt install bison libbison-dev
 
 - Abrir o projeto no VSCode
 - Executar os comandos:
  1. flex  analisadorLex.l
  2. bison -d analisadorSint.y
  3. g++ lex.yy.c  analisadorSint.tab.c  -std=c++17 -o analisador
  4. ./analisador finalTest.txt

Detalhes:
 - No passo 2 da execução, o -d é para conseguir gerar o arquivo.h do analisadorSint, que o analisadorLex utiliza pra conhecimento dos tokens/enum.
