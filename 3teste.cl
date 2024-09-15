class Teste inherits IO {

 stringMetodo() : String {
    let s: String <- "PA2 Compiladores";
    out_string(s);
    out_string("Short string test");
    s;
  };
 };

class Main inherits IO {

  main() : Object {
    {
      let testeObj: Teste <- new Teste in {
        out_string("\nTeste 3: testando strings\n");
        out_string("Resultado do stringMetodo: ");
        out_string(testeObj.stringMetodo());
        out_string("\n");
 };
    }
  };
};
