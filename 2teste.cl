class Main inherits IO {
  
  main() : Object {
    {
      out_string("Testando negação lógica: ");
      out_bool(not true); 
      out_string("\n");

      out_string("Testando negação aritmética: ");
      out_int(~5); 
      out_string("\n");
    }
  };

};
