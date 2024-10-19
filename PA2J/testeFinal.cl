class Teste inherits IO {

  testeMetodo(a: Int) : Int {  
    let y: Int <- a + 10;  
    if y <= 100 then         
      y <- y * 10;
    else                     
      y <- y / 2;
    fi;                      
    y <- y - 1;              
    y;  -- Corrigido: retorna y no final
  };


  stringMetodo() : String {
    let s: String <- "PA2 Compiladores"; 
    out_string(s);
    out_string("Short string test");
    s;  -- Corrigido: retorna s no final
  };

  comparacaoMetodo() : Bool {
    let a: Int <- 20;  
    let b: Int <- 25;  
    a < b and a = b;  
  };

  testePontoMetodo() : String {
    out_string("Chamando metodo usando ponto.");
    out_string("Outra chamada de metodo.");
    "Chamadas finalizadas.";  
  };

  novoMetodo() : Teste {
    let obj: Teste <- new Teste; 
    obj;  -- Retorna o novo objeto
  };

  dispatchMetodo() : Int {
    let obj: IO <- new IO;  
    obj@IO.out_string("Chamando metodo para dispatch.");
    0; 
  };
};

class TesteCompleto inherits IO {

  myFullTest(x: Int) : Int {
    let y: Int <- x + 3;  
    if y <= 7 then
      y <- y * 4;
    else
      y <- y / 4;
    fi;
    while y < 300 loop
      y <- y + 5;
    pool;
    case y of
      0: y <- 10;
      1: y <- 20;
    esac;
    y <- (if isvoid y then 0 else ~y fi);  
    out_string("Teste finalizado");
    y;  -- Corrigido: retorna y no final
  };
};

class Main inherits IO {

  main() : Object {
    {
      let testeObj: Teste <- new Teste in {
        out_string("Iniciando Testes da Classe Teste\n");
        out_string("Teste 1.1: testando operadores e palavras-chave\n");
        out_string("Resultado do testeMetodo: ");
        out_int(testeObj.testeMetodo(5));  
        out_string("\n");

        out_string("\nTeste 3: testando strings\n");
        out_string("Resultado do stringMetodo: ");
        out_string(testeObj.stringMetodo());  
        out_string("\n");

        out_string("\nTeste 4: testando operadores de comparacao\n");
        out_string("Resultado do comparacaoMetodo: ");
        out_bool(testeObj.comparacaoMetodo());  
        out_string("\n");

        out_string("\nTeste 5: testando chamada de metodo com ponto\n");
        testeObj.testePontoMetodo();
        out_string("\n");

        out_string("\nTeste 6: testando criacao de novos objetos\n");
        out_string("Criando novo objeto com novoMetodo\n");
        let novoObj: Teste <- testeObj.novoMetodo();
        out_string("Novo objeto criado com sucesso.\n");

        out_string("\nTeste 7: testando dispatch com @\n");
        out_int(testeObj.dispatchMetodo());  
        out_string("\n");
      };

      let testeCompletoObj: TesteCompleto <- new TesteCompleto in {
        out_string("\nIniciando Testes da Classe TesteCompleto\n");
        out_string("Teste 8: testando varios operadores e palavras-chave\n");
        out_string("Resultado do myFullTest: ");
        out_int(testeCompletoObj.myFullTest(5));  
        out_string("\n");
      };
    }
  };
};
