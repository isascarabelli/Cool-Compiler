class Teste inherits IO {

    comparacaoMetodo() : Bool {
    let a: Int <- 20;
    let b: Int <- 25;
    a < b;
    a = b;
    a < b and a = b;
  };
 };

class Main inherits IO {

  main() : Object {
    {
      let testeObj: Teste <- new Teste in {
        out_string("\nTeste 4: testando operadores de comparação\n");
        out_string("Resultado do ComparacaoMetodo: ");
        out_bool(testeObj.ComparacaoMetodo());
        out_string("\n");
 };
    }
  };
};
