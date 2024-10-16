class Teste inherits IO {

  testeMetodo(a: Int) : Int {  
    let y: Int <- a + 10 in
    if y <= 100 then         
      y <- y * 10; 
    else                     
      y <- y / 2;  
    fi;                      
    y <- y - 1;               
    y
  };

  negacaoMetodo() : Bool {
    let b: Bool <- not true in
    b <- ~b; 
    b
  };

  stringMetodo() : String {
    let s: String <- "PA2 Compiladores" in
    out_string(s);
    out_string("Short string test");
    s
  };

  comparacaoMetodo() : Bool {
    let a: Int <- 20 in
    let b: Int <- 25 in
    a < b and a == b;  
  };

  testePontoMetodo() : String {
    out_string("Chamando metodo usando ponto.");
    out_string("Outra chamada de metodo.");
  };

  novoMetodo() : Teste {
    let obj: Teste <- new Teste in
    obj;
  };

  dispatchMetodo() : Int {
    let obj: IO <- new IO in
    obj @IO.out_string("Chamando metodo para dispatch."); 
    0;
  };
};

class TesteCompleto inherits IO {

  myFullTest(x: Int) : Int {
    let y: Int <- x + 3 in
    if y <= 7 then
      y <- y * 4
    else
      y <- y / 4
    fi;
    while y < 300 loop
      y <- y + 5
    pool;
    case y of
      0: y <- 10;
      1: y <- 20;
    esac;
    y <- isvoid y + ~y; 
    out_string("Teste finalizado");
    y
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

        out_string("\nTeste 2: testando negacao e NOT\n");
        out_string("Resultado do negacaoMetodo: ");
        out_bool(testeObj.negacaoMetodo());
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
