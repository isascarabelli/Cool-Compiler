class Teste inherits IO {
negacaoMetodo() : Bool {
  let b: Bool <- not true in b;  -- A negação lógica de `true` resultará em `false`
};
};

class Main inherits IO {

  main() : Object {
    {
      let testeObj: Teste <- new Teste in {
        out_string("\nTeste 2: testando negação e NOT\n");
        out_string("Resultado do negacaoMetodo: ");
        out_bool(testeObj.negacaoMetodo());
        out_string("\n");
};
};
};
};
