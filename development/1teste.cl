class Teste inherits IO {

  testeMetodo(a: Int) : Int {  
    let y: Int <- a + 10;
    if y <= 100 then         
      y <- y * 10;
    else                     
      y <- y / 2;
    fi;                      
    y <- y - 1;              
    y;
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
 };
    }
  };
};
