# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Como Funciona](#como-funciona)
3. [Início do Programa](#início-do-programa)
4. [Código](#código)

## Descrição do Projeto

Este projeto é um `Analisador Léxico` desenvolvido como parte do TP1 de Compiladores. O analisador léxico é responsável por ler o código fonte de entrada e transformá-lo em uma sequência de tokens. Este analisador léxico foi desenvolvido para reconhecer tokens a partir de uma entrada de código fonte. Ele identifica padrões de lexemas e associa cada um a um token correspondente. O analisador foi configurado para trabalhar com a linguagem de programação COOL.

## Como Funciona

O analisador léxico lê o código fonte caractere por caractere e, utilizando expressões regulares, agrupa caracteres e os classifica em:

- **Palavras Reservadas** (e.g., `TRUE`, `IF` ou `FI`, `CASE` ou `ESAC`)
- **Identificadores** (e.g., nomes de variáveis e funções)
- **Operadores** (e.g., `+`, `*`, `=>`, `@`)
- **Delimitadores** (e.g., `;`, `{`, `}`)
- **Literais** (e.g., números, strings)

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

## Código


