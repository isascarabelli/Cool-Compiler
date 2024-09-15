# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Como Funciona](#como-funciona)
3. [Início do Programa](#início-do-programa)
4. [Código](#código)
5. [Testes](#testes)

## Descrição do Projeto

Este projeto é um `Analisador Léxico` desenvolvido como parte do TP2 de Compiladores. O analisador léxico é responsável por ler o código fonte de entrada e transformá-lo em uma sequência de tokens. Este analisador léxico foi desenvolvido para reconhecer tokens a partir de uma entrada de código fonte. Ele identifica padrões de lexemas e associa cada um a um token correspondente. O analisador foi configurado para trabalhar com a linguagem de programação COOL.

## Como Funciona

O analisador léxico lê o código fonte caractere por caractere e, utilizando expressões regulares, agrupa caracteres e os classifica em:

- **Identificadores** (e.g., nomes de variáveis, funções e tipos)
- **Operadores** (e.g., `+`, `*`, `=>`, `@`)
- **Delimitadores** (e.g., `;`, `{`, `}`)
- **Literais** (e.g., números, strings)

`Inteiros` são strings não-vazias de dígitos no intervalo de 0 até 9. `Ientificadores` são strings que consistem em letras, dígitos e o caracter undescore (_).

Para identificadores de tipos usamos a primeira letra como maiúscula. Para identificadores de objetos utilizamos a primeira letra minúscula. Utilizamos também dois identificadores especiais, que são o `self` e o `SELF_TYPE` que são tratadas de modo diferente pelo COOL.

Essas classificações são os `Tokens`, que são armazenados nas tabelas de `STRING`, `ID` e `INT` que trataremos porteriormente. 

O projeto inclui a implementação dos estados de um autômato finito que processa a entrada até encontrar um token ou reportar um erro léxico.

## Início do Programa

Para iniciar o analisador léxico precisamos de algumas definições. Dentre elas, podemos destacar:

Inicialização da variável responsável por identificar quando uma ocorrência do caracter `\`. Essa variável será muito importante para as verificações e tratativas desse caracter. 
```
boolean backslashEscaped=false;
```
Essa estrutura será responsável por armazenar e construir a cadeia de caracteres.
```
 StringBuffer string_buf = new StringBuffer();
```
Nesse trecho estamos configurando a estrutura para armazenamento e leitura do código-fonte a ser analisado. Transforma o código-fonte em um objeto do tipo `AbstractSymbol`, 
```
private AbstractSymbol filename;

    void set_filename(String fname) {
	    filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	    return filename;
    }
```
Também realiza inicializações de variáveis booleanas de verificações como se há algum caracter nulo na String ou se a String é muito extensa.

A última tratativa antes de iniciar a análise dos estados é a verificação de fim de arquivo e as respectivas tratativas de acordo com o estado atual no qual o fim do arquivo foi encontrado.

```
 switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
	/* If necessary, add code for other states here, e.g:
	   case COMMENT:
	   ...
	   break;
	*/
    case STRING:
      if(eof_encountered) break;
      
      eof_encountered=true;
      
      if(backslashEscaped) return new Symbol(TokenConstants.ERROR, "String contains escaped null character.");
      else return new Symbol(TokenConstants.ERROR, "Error: EOF Encountered in String.");

    case BLOCK_COMMENT:
      eof_encountered=true;
      return new Symbol(TokenConstants.ERROR, "Error: EOF Encountered in Block Comment.");

    }
```
Importante notar que no trecho `return new Symbol(TokenConstants.ERROR, "Error: EOF Encountered in String.");` instanciamos um objeto do tipo `Symbol`. Esse objeto é o responsável por salvar nas tabelas o Token identificado. `TokenConstants` nada mais é que um `define` para um ID inteiro, que é o que realmente será salvo na tabela e cada Token possui seu ID próprio.

## Código
O analisador lexico desenvolvido é baseado em uma máquina de 3 estados, sendo eles `<YYINITIAL>`, `<STRING>` e `<BLOCK_COMMENT>`. A estrutura dos estados é descrita da seguinte forma.
```
<ESTADO> stringLida { realizar determinada ação e/ou retornar um novo objeto do tipo `Symbol` }
```
Foi preciso implementar no analisador algumas funções que lidassem com situações específicas, como por exemplo a expressão abaixo que executa a quebra de linha. Ele trata exibindo um erro no caso de não haver um caracter `\` ou uma string vazia e, caso contrário, efetiva aquele caracter como uma quebra de linha.
```
<STRING> \n { // Code for newline characters
  // If a newline appears in a string, it must be escaped, else error
  if(!backslashEscaped || string_buf.length()==0) {
    curr_lineno++;
    yybegin(YYINITIAL);
    return new Symbol(TokenConstants.ERROR, "Unterminated string constant");
  } else {
    // Replace '\' character in string buffer with newline
    string_buf.setCharAt(string_buf.length()-1, '\n');
    curr_lineno++;
  }
 }
```
Outro exemplo de adaptação que devemos adotar para o analisador lexico é quanto à abertura e fechamento de determinadas Tokens. Abaixo está o bloco de reconhecimento de abertura e fechamento de comentários. De semelhante modo ao bloco acima, aqui precisamos da obrigatoriedade de fechamento do bloco em caso de abertura, e não há outras possibilidades para essa string, que é diferente das que iniciam com o caracter `\`.
```
<BLOCK_COMMENT> "(*"  { nestedCommentCount++; }
<BLOCK_COMMENT> "*)" {
  if(nestedCommentCount!=0) {
    nestedCommentCount--;
  } else {
    yybegin(YYINITIAL);
  }
 }
```
Partindo agora para as expressões regulares que fazem a análise de todas os Tokens, descritas da seguinte forma:
```
<YYINITIAL> [cC][lL][aA][sS][sS]             { return new Symbol(TokenConstants.CLASS); }
```
Nesse caso, estamos lendo a palavra reservada `CLASS`. Partindo do estado `YYINITIAL`, cada caractere é lido intependentemente se é maiúsculo ou minúsculo, o que faz com que a linguagem não seja case sensitive. Ao se formar a palavra `CLASS`, é identificado qual Token está sendo declarada e posteriormente retornando um novo objeto `Symbol`.

No bloco abaixo é caso é semelhante, sendo o caractere `,` lido e semelhantemente retornando um novo objeto `Symbol`.
```
<YYINITIAL> ","   { return new Symbol(TokenConstants.COMMA);  }
```
Finalmente implementamos os estados que dividem os Tokens em 3 tipos: `STRING`, `ID` e `INT`. Para os tipos `STRING` e `ID` uma tabela é implementada alterando apenas o tipo do Token, e para o tipo `INT` outra tabela é implementada.
```
<YYINITIAL> [a-z][_a-zA-Z0-9]* { return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); }
<YYINITIAL> [A-Z][_a-zA-Z0-9]* { return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext())); }
<YYINITIAL> [0-9]+             { return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext())); }
```

## Testes
Foram realizados `XXXXXXXXXXXXXXX` testes para esse projeto sendo eles, além do arquivo `test.cl` já implementado, a máquina de pilha especificada no trabalho 2 e descrito em nosso trabalho como `XXXXXXXXXXXXXXX`.
A função do código já implementado é definida como um teste que modela autômato celular unidimensional em um círculo de raio finito. Arrays são simulados como Strings, X's representam células vivas, pontos representam células mortas, e nenhuma verificação de erro é feita. Já a máquina de pilha funciona num loop. Enquanto lê números, o caracter `s` e a string `+`, o código os adiciona na pilha. Ao ler a letra `D`, ele imprime a pilha. Ao ler a letra `E`, ele pega o topo da pilha e salva em `CH`. A partir daí ele checa qual o valor que estava no início da pilha e executa os procedimentos de acordo com o que foi especificado.

Abaixo está um trecho da saída final produzida pelo analizador léxico no arquivo original `test.cl`.
```
#7 IN
#7 WHILE
#7 OBJECTID countdown
#7 ERROR ">"
#7 INT_CONST 0
#7 LOOP
#7 '{'
#7 OBJECTID cells
#7 '.'
#7 OBJECTID evolve
#7 '('
#7 ')'
#7 ';'
#7 OBJECTID cells
#7 '.'
#7 OBJECTID print
#7 '('
#7 ')'
#7 ';'
#7 OBJECTID countdown
#7 ASSIGN
#7 OBJECTID countdown
#7 '-'
#7 INT_CONST 1
#7 ';'
#7 POOL
#7 ')'
#7 ';'
#12 ERROR "Error: EOF Encountered in Block Comment."
```
