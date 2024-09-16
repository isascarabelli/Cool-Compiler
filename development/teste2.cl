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

    let s: String <- "PA2 Compiladores";  -- Teste da palavra-chave "let"
                                          -- Removi a sequência de escape \n para simplificar a string
    
    out_string(s);                      -- Teste para chamada de função (out_string)
                                        -- Teste de passagem da variável "s"
    
    out_string("Short string test");     -- Simplifiquei a string longa para evitar problemas com o limite de 1024 caracteres
    
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
    out_string("Chamando método usando ponto.");  -- Simplificação da string
    out_string("Outra chamada de método.");
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
    obj@IO.out_string("Chamando método com @ para dispatch.");
    0;
  };
};


-- Teste 8 
-- Objetivo: testar mais operadores e palavras-chave

class TesteCompleto inherits IO {
  
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
    
    out_string("Teste finalizado");  -- Removi a sequência de escape \n
    
    y;  -- Teste de retorno da variável "y"
  };
};  


-- Classe Main que serve como ponto de entrada para os testes
class Main inherits IO {

  main() : Object {
    {
      -- Instancia a classe Teste
      let testeObj: Teste <- new Teste in {
        out_string("Iniciando Testes da Classe Teste\n");

        -- Teste 1.1: teste de operadores e palavras-chave
        out_string("Teste 1.1: testando operadores e palavras-chave\n");
        out_string("Resultado do testeMetodo: ");
        out_int(testeObj.testeMetodo(5));  -- Chama o método e exibe o resultado
        out_string("\n");

        -- Teste 2: teste de negação e NOT
        out_string("\nTeste 2: testando negação e NOT\n");
        out_string("Resultado do negacaoMetodo: ");
        out_bool(testeObj.negacaoMetodo());  -- Chama o método e exibe o resultado
        out_string("\n");

        -- Teste 3: teste com strings
        out_string("\nTeste 3: testando strings\n");
        out_string("Resultado do stringMetodo: ");
        out_string(testeObj.stringMetodo());  -- Chama o método e exibe a string retornada
        out_string("\n");

        -- Teste 4: teste de comparação
        out_string("\nTeste 4: testando operadores de comparação\n");
        out_string("Resultado do ComparacaoMetodo: ");
        out_bool(testeObj.ComparacaoMetodo());  -- Chama o método de comparação e exibe o resultado
        out_string("\n");

        -- Teste 5: teste de chamada de método com ponto
        out_string("\nTeste 5: testando chamada de método com ponto\n");
        testeObj.testePontoMetodo();  -- Não retorna valor, apenas imprime as saídas
        out_string("\n");

        -- Teste 6: teste de criação de novos objetos com 'new'
        out_string("\nTeste 6: testando criação de novos objetos\n");
        out_string("Criando novo objeto com novoMetodo\n");
        let novoObj: Teste <- testeObj.novoMetodo();  -- Chama o método e cria um novo objeto
        out_string("Novo objeto criado com sucesso.\n");

        -- Teste 7: teste de dispatch com "@"
        out_string("\nTeste 7: testando dispatch com @\n");
        out_int(testeObj.dispatchMetodo());
        out_string("\n");
      };

      -- Instancia a classe TesteCompleto
      let testeCompletoObj: TesteCompleto <- new TesteCompleto in {
        out_string("\nIniciando Testes da Classe TesteCompleto\n");

        -- Teste 8: teste completo com vários operadores e palavras-chave
        out_string("Teste 8: testando vários operadores e palavras-chave\n");
        out_string("Resultado do myFullTest: ");
        out_int(testeCompletoObj.myFullTest(5));  -- Chama o método e exibe o resultado
        out_string("\n");
      };
    }
  };
};
