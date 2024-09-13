-- Arquivo para testes para o trabalho prático PA2 Grupo Amanda Isabela e Pedro
-- Esse arquivo teste tem como objetivo principal realizar a análise léxica da linguagem COOL 
-- Serão analisados: palavras-chaves, strings, identificadores e operadores

-- Teste 1 
class Teste inherits IO {
  -- Objetivo: testar a palavra-chave "class" para definição de uma nova classe, e testar a palavra-chave "inherits" para herança de outra classe, no caso (IO)
  
  -- Teste 1.1
  -- Objetivo: testar principalmente palavras-chave e operadores
  testeMetodo(a: Int) : Int {  -- Teste para identificadores como (testeMetodo, a, Int)
                             -- Teste para o tipo "Int"
    let y: Int <- a + 10;    -- Teste para a palavra-chave "let"
                             -- Teste para o operador de atribuição "<-"
                             -- Teste para o operador de adição "+"
                             -- Teste para a constante inteira "10"
                            
    if y <= 100 then         -- Teste para a palavra-chave "if" e "then"
                             -- Teste para o operador de comparação "<="
                             -- Teste para a constante inteira "100"

      y <- y * 10;           -- Teste para a palavra-chave "let"
                             -- Teste para o operador de atribuição "<-"
                             -- Teste para o operador de multiplicação "*"
                             -- Teste para a constante inteira "10"

    else                     -- Teste para a palavra-chave "else"
      y <- y / 2;            -- Teste para o operador de divisão "/"
                             -- Teste para a constante inteira "2"
    fi;                      -- Teste para o uso da palavra-chave "fi" para fechar a estrutura "if"
    
    y <- y - 1;              -- Teste para o operador de subtração "-"
    y;                       -- Teste para o retorno de identificadores (variável "y")
  };

  
-- Teste 2
  -- Objetivo: realizar testes de negação e NOT
  negacaoMetodo() : Bool {
    let b: Bool <- not true;            -- Testa operador NOT (negação de booleano)
    b <- ~b;                            -- Testa o operador de negação lógica "~"
    b;
  };

-- Teste 3
    -- Objetivo: realizar testes para alguns tipos de strings
  stringMetodo() : String {    -- Teste de identificadores (stringMetodo)
                               -- Teste de tipo "String"

    let s: String <- "PA2 Compiladores\n";  -- Teste da palavra-chave "let"
                                            -- Teste de atribuição de strings (com a presenca de escape de nova linha "\n")
                                            -- Teste da string literal "PA2 Compiladores"
    
    out_string(s);                      -- Teste para chamada de função (out_string)
                                        -- Teste de passagem da variável "s"
    
    out_string("This is a long string that should not exceed the limit of 1024 characters, otherwise an error will be thrown...");  
                                        -- Teste de string longa (verifica se o lexer trata strings longas)
    
    
    s;                                  -- Teste de retorno de string
  };

-- Teste 4
  -- Objetivo: realizar testes de comparação (< e =)
  ComparacaoMetodo() : Bool {
    let a: Int <- 20;
    let b: Int <- 25;
    a < b;                               -- Testa o operador de comparação "<"
    a = b;                               -- Testa o operador de igualdade "="
    a < b and a = b;
  };

-- Teste 5
  -- Objetivo: realizar teste de chamada de método, mas agora usando ponto (.)
  
  testePontoMetodo() : String {
    out_string("Utilizando o ponto para chamar este método.\n").out_string("Nova chamada de método.");
  };

-- Teste 6
  -- Objetivo: realizar teste para a criação de novos objetos usando "new"

  novoMetodo() : Teste {
    let obj: Teste <- new Teste;          -- Testa a palavra-chave "new" para que seja possível a criação de objetos
    obj;
  };

-- Teste 7
  -- Objetivo: realizar teste de uso do "@" (dispatch) para chamar os métodos

  dispatchMetodo() : Int {
    let obj: IO <- new IO;
    obj@IO.out_string("Chamando método com @ para dispatch.\n");
    0;
  };
};


-- Teste 8 
-- Objetivo: testar mais operadores e palavras-chave

class TesteCompleto linherits IO {
  
  myFullTest(x: Int) : Int {  -- Teste de identificadores e tipos
    let y: Int <- x + 3;      -- Teste de atribuição e operação aritmética (adição)
    
    if y <= 7 then            -- Teste de palavra-chave "if", "then" e operador de comparação "<="
      y <- y * 4;             -- Teste de operador de multiplicação "*"
    else                      -- Teste de palavra-chave "else"
      y <- y / 4;             -- Teste de operador de divisão "/"
    fi;                       -- Teste de fechamento de "if" com "fi"
    
    while y < 300 loop        -- Teste de palavras-chave "while", "loop"
      y <- y + 5;             -- Teste de incremento
    pool;                     -- Teste de fechamento de "while" com "pool"
    
    case y of                 -- Teste de palavra-chave "case"
      0: y <- 10;             -- Teste de caso "case" para valores inteiros
      1: y <- 20;             -- Mais um caso com valor inteiro
    esac;                     -- Fechar a palavra-chave "case" com "esac"
    
    y <- isvoid y + ~y;       -- Teste de palavra-chave "isvoid" e operador de negação "~"
                              -- Teste de operações aritméticas e lógicas
    
    out_string("teste finalizado\n");  -- Teste de string com escape de nova linha "\n"
    
    y;  -- Teste de retorno da variável "y"
  };
};
