class Teste inherits IO {

  testePontoMetodo() : String {
    out_string("Chamando método usando ponto.");
    out_string("Outra chamada de método.");
  };
 };
class Main inherits IO {

  main() : Object {
    {
      let testeObj: Teste <- new Teste in {
        out_string("\nTeste 5: testando chamada de método com ponto\n");
        testeObj.testePontoMetodo();
        out_string("\n");
 };
    }
  };
};
