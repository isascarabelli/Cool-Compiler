# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Como Funciona](#como-funciona)
3. [Início do Programa](#início-do-programa)
4. [Código](#código)

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
Foi preciso implementar no analisador algumas funções que lidassem com situações específicas, como por exemplo a expressão `<STRING> \"` que trata sobre o encerramento de uma aspa dupla ou a presença de uma barra invertida dentro de uma string e a `<STRING> \n` que executa a quebra de linha.
