class TesteNegacao inherits IO {
  
  testNegacaoLogica() : Bool {
    let valor: Bool <- not true in valor;
  };

  testNegacaoAritmetica() : Int {
    let valor: Int <- 5 in ~valor;  -- negação aritmética de 5, resultado deve ser -6
  };

};

class Main inherits IO {
  
  main() : Object {
    {
      let teste: TesteNegacao <- new TesteNegacao in {
        out_string("Testando negação lógica (not true): ");
        out_bool(teste.testNegacaoLogica());
        out_string("\n");

        out_string("Testando negação aritmética (~5): ");
        out_int(teste.testNegacaoAritmetica());
        out_string("\n");
      };
    }
  };

};
