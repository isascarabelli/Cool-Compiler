# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Código](#código)
3. [Testes](#testes)

## Descrição do Projeto
Este projeto é um analisador semântico desenvolvido como parte do TP4 de Compiladores. Essa é a terceira fase da compilação, onde se verificam os erros de semântica no código fonte e se faz a coleta das informações necessárias para a próxima fase da compilação, a geração de código. O objetivo da análise semântica é trabalhar no nível de inter-relacionamento entre partes distintas do programa. 

A implementação feita pelo grupo percorre a árvore, gerencia as informações que recolhe da árvore e usa essas informações para apontar os erros ou validar a semântica da linguagem Cool. Essa etapa recebe uma árvore sintática abstrata construída pelo parser para verificação, e irá gerar uma árvore sintática abstrata (ASTs), da mesma forma que a etapa anterior de análise sintática, porém, dessa vez amarrando os tipos de cada expressão, para que seja utilizada pelo gerador de código.

Os códigos alterados pelo grupo se encontram em “cool-tree.java” e “ClassTable.java”. Iremos explicar a seguir as alterações feitas em cada arquivo.

## Código
### cool-tree.java

## Testes


### good.cl
Arquivo criado para testar toda e qualquer construção dos tipos da linguagem cool. Nele foram desenvolvidos partes de código que passarão pelo analisador semântico, para verficarmos a Árvore Sintática Abstrata (AST) gerada e se nosso analisador identifica os tipos das construções feitas.

Aqui focamos em testar o máximo de tipos possíveis em COOL, para que fosse possível analisar sua saída e sua identificação correta. Os tipos testados foram: Int, Bool, String e SELF_TYPE.

- SELF_TYPE

Iniciaremos com a análise do tipo SELF_TYPE, pois em nosso arquivo iniciamos com classes que são responsáveis por esse teste. São essas classes: 

```
class A {
	x:SELF_TYPE;
	init():Object { x <- new SELF_TYPE };
	foo():Int { 1 };
	getx():A { x };
};

class B inherits A {
	foo():Int { 2 };
};
```
Aqui, x é uma propriedade de tipo SELF_TYPE. O método init inicializa a propriedade x criando uma nova instância do tipo da classe atual (new SELF_TYPE). Esse uso de SELF_TYPE permite que x seja do tipo exato da subclasse se a classe for estendida, em vez de ser limitado ao tipo A. O método getx retorna o valor de x. Como x é declarado como SELF_TYPE, ele é tratado como se fosse do tipo A, tornando a função compatível com o tipo de retorno A. 

A classe B herda de A e redefine o método foo, retornando o valor inteiro 2 em vez de 1 (o valor retornado na classe A). 

Para essas funções, obtemos a seguinte AST: 
```
#4
_program
  #4
  _class
    A
    Object
    "good.cl"
    (
    #5
    _attr
      x
      SELF_TYPE
      #0
      _no_expr
      : _no_type
    #6
    _method
      init
      Object
      #6
      _assign
        x
        #6
        _new
          SELF_TYPE     (* SELF_TYPE de x exibido aqui *)
        : SELF_TYPE  
      : SELF_TYPE
    #7
    _method
      foo
      Int
      #7
      _int
        1
      : Int
    #8
    _method
      getx
      A
      #8
      _object
        x
      : SELF_TYPE
    )
  #11
  _class
    B
    A
    "good.cl"
    (
    #12
    _method
      foo
      Int
      #12
      _int
        2
      : Int
    )
```
Realizamos a chamada desses métodos na Main, com o código a seguir:

```
let a:A <- new B in { 
	a.init();
	out_int(a.getx().foo());
};
out_string("\n");
```
Para esse trecho, obtivemos a seguinte AST.
```
 #110
        _let
          a
          A
          #110
          _new
            B
          : B
          #110
          _block
            #111
            _dispatch
              #111
              _object
                a
              : A
              init
              (
              )
            : Object
            #112
            _dispatch
              #112
              _object
                self
              : SELF_TYPE
              out_int
              (
              #112
              _dispatch
                #112
                _dispatch
                  #112
                  _object
                    a
                  : A
                  getx
                  (
                  )
                : A
                foo
                (
                )
              : Int
              )
            : SELF_TYPE
          : SELF_TYPE       (* SELF_TYPE exibido aqui *)
        : SELF_TYPE
        #114
        _dispatch
          #114
          _object
            self
          : SELF_TYPE
          out_string
          (
          #114
          _string
            "\n"
          : String
          )
        : SELF_TYPE
      : SELF_TYPE
    )
```
Como esperado, ele definiu corretamente não somente os tipos SELF_TYPE, mas também com outros tipos. Antes, o analisador sintático exibia `_no_type`, mas na saída do analisador semântico o tipo é indicado.

- String

Para o tipo String, realizamos um teste baseado no método de concatenação. Inicializamos uma String `s : String <- "this is a";`, para posteriormente utilizá-la no trecho abaixo:

```
out_int(s.length());
out_string("\n".concat(s.concat(" string\n")));
out_string(s.substr(5, 2).concat("\n"));
```
Que devolveu como saída a AST descrita:

```
_dispatch
          #50
          _object
            self
          : SELF_TYPE
          out_int
          (
          #50
          _dispatch
            #50
            _object
              s
            : String
            length
            (
            )
          : Int
          )
        : SELF_TYPE
        #51
        _dispatch
          #51
          _object
            self
          : SELF_TYPE
          out_string
          (
          #51
          _dispatch
            #51
            _string
              "\n"
            : String
            concat
            (
            #51
            _dispatch
              #51
              _object
                s
              : String
              concat
              (
              #51
              _string
                " string\n"
              : String
              )
            : String
            )
          : String
          )
        : SELF_TYPE
        #52
        _dispatch
          #52
          _object
            self
          : SELF_TYPE
          out_string
          (
          #52
          _dispatch
            #52
            _dispatch
              #52
              _object
                s
              : String
              substr
              (
              #52
              _int
                5
              : Int
              #52
              _int
                2
              : Int
              )
            : String
            concat
            (
            #52
            _string
              "\n"
            : String
            )
          : String
          )
        : SELF_TYPE
```

Podemos ver aqui uma sucessão de ocorrências de
```
 s
: String
```
que demonstra que a variável `s` corretamente foi avaliada como tipo `String`.

- Int
Ao realizarmos os testes para o tipo Int usamos dois tipos de testes. Uma função recursiva de calculo de potências e uma expressão matemática com precedência por parêntesis.

A função `exp` foi a que usamos para os testes:
```
exp(b : Int, x : Int) : Int {
	if (x = 0)
	then
	1
	else
	if (x = (2 * (x / 2)))
	then
		let y : Int <- exp(b, (x / 2)) in
		y * y
	else
		b * exp(b, x - 1)
	fi
	fi
};
```
E para testá-la, chamamos diversas potências:
```
out_int(exp(2, 7));
out_string("\n");
out_int(exp(3, 6));
out_string("\n");
out_int(exp(8, 3));
out_string("\n");
```
Que devolveram a AST abaixo. Nela podemos observar que, seguido de numerais como 2, 7, entre outros, vemos o trecho `: Int`, que denota o tipo daquele dado literal, no nosso caso, inteiros.
```
#44
_dispatch
          #44
          _object
            self
          : SELF_TYPE
          out_int
          (
          #44
          _dispatch
            #44
            _object
              self
            : SELF_TYPE
            exp
            (
            #44
            _int
              2
            : Int
            #44
            _int
              7
            : Int
            )
          : Int
          )
        : SELF_TYPE
        #45
        _dispatch
          #45
          _object
            self
          : SELF_TYPE
          out_string
          (
          #45
          _string
            "\n"
          : String
          )
        : SELF_TYPE
        #46
        _dispatch
          #46
          _object
            self
          : SELF_TYPE
          out_int
          (
          #46
          _dispatch
            #46
            _object
              self
            : SELF_TYPE
            exp
            (
            #46
            _int
              3
            : Int
            #46
            _int
              6
            : Int
            )
          : Int
          )
        : SELF_TYPE
        #47
        _dispatch
          #47
          _object
            self
          : SELF_TYPE
          out_string
          (
          #47
          _string
            "\n"
          : String
          )
        : SELF_TYPE
        #48
        _dispatch
          #48
          _object
            self
          : SELF_TYPE
          out_int
          (
          #48
          _dispatch
            #48
            _object
              self
            : SELF_TYPE
            exp
            (
            #48
            _int
              8
            : Int
            #48
            _int
              3
            : Int
            )
          : Int
          )
        : SELF_TYPE
        #49
        _dispatch
          #49
          _object
            self
          : SELF_TYPE
          out_string
          (
          #49
          _string
            "\n"
          : String
          )
        : SELF_TYPE
```
Para a análise da expressão dada pelo código:
```
let x:Int <- 5 in {
	out_int((x <- 1) + ((x <- x+1) 
			+ (3 + (4 + (5 + (6 + (7+ (x+6))))))));
};
```
Obtivemos a AST abaixo:
```
        #52
        _let
          x
          Int
          #52
          _int
            5
          : Int
          #52
          _block
            #53
            _dispatch
              #53
              _object
                self
              : SELF_TYPE
              out_int
              (
              #53
              _plus
                #53
                _assign
                  x
                  #53
                  _int
                    1
                  : Int
                : Int
                #54
                _plus
                  #53
                  _assign
                    x
                    #53
                    _plus
                      #53
                      _object
                        x
                      : Int
                      #53
                      _int
                        1
                      : Int
                    : Int
                  : Int
                  #54
                  _plus
                    #54
                    _int
                      3
                    : Int
                    #54
                    _plus
                      #54
                      _int
                        4
                      : Int
                      #54
                      _plus
                        #54
                        _int
                          5
                        : Int
                        #54
                        _plus
                          #54
                          _int
                            6
                          : Int
                          #54
                          _plus
                            #54
                            _int
                              7
                            : Int
                            #54
                            _plus
                              #54
                              _object
                                x
                              : Int
                              #54
                              _int
                                6
                              : Int
                            : Int
                          : Int
                        : Int
                      : Int
                    : Int
                  : Int
                : Int
              : Int
              )
            : SELF_TYPE
          : SELF_TYPE
        : SELF_TYPE
```
Aqui temos uma saída interessante, com diversos `: Int`. Isso ocorreu por conta das precedências dadas pelos parêntesis, onde a cada fechamento o tipo era indicado e, como a expressão opera com inteiros, o tipo Int é indicado. No final também temos indicações de tipos `SELF_TYPE` que decorrem do `let`.

- Bool

Aqui utilizamos uma estratégia diferente. Utilizamos o método `type_name()` que retorna uma String com o tipo da variável usada no dispatch. A cada chamada de `t.type_name()`, onde x é a variável que o tipo será analisado, ele realiza um processo de verificação do tipo de x. Veja abaixo o exemplo dessa chamada:
```
 #70
_dispatch
	#70
	_object
	t		
	: Bool
	type_name
	(
	)
: String
)
```
O tipo de `t` é indicado como `Bool` e na sequência a indicação de `type_name()` como `String`. Tudo isso ocorre sucessivas vezes no teste que realizamos, para que fosse possível analisar a corretude do analisador semântico. O código usado e a AST estão respectivamente listados abaixo:
```
let
	t:Bool <- true,
	f:Bool <- false,
	t1:Object <- t,
	t2:Object <- true,
	f1:Object <- f,
	f2:Object <- false,
	b1:Bool,
	b2:Object,
	io:IO <- new IO
in {
	io.out_string("t: ");
	io.out_string(t.type_name());
	io.out_string("\n");

	b1 <- t;
	io.out_string("b1: ");
	io.out_string(b1.type_name());
	io.out_string("\n");

	b2 <- t1;
	io.out_string("b2: ");
	io.out_string(b2.type_name());
	io.out_string("\n");

	b1 <- f.copy();
	io.out_string("b1: ");
	io.out_string(b1.type_name());
	io.out_string("\n");

	b2 <- f2.copy();
	io.out_string("b2: ");
	io.out_string(b2.type_name());
	io.out_string("\n");
};
```
```
 #59
        _let
          t
          Bool
          #59
          _bool
            1
          : Bool
          #60
          _let
            f
            Bool
            #60
            _bool
              0
            : Bool
            #61
            _let
              t1
              Object
              #61
              _object
                t
              : Bool
              #62
              _let
                t2
                Object
                #62
                _bool
                  1
                : Bool
                #63
                _let
                  f1
                  Object
                  #63
                  _object
                    f
                  : Bool
                  #64
                  _let
                    f2
                    Object
                    #64
                    _bool
                      0
                    : Bool
                    #65
                    _let
                      b1
                      Bool
                      #0
                      _no_expr
                      : _no_type
                      #66
                      _let
                        b2
                        Object
                        #0
                        _no_expr
                        : _no_type
                        #67
                        _let
                          io
                          IO
                          #67
                          _new
                            IO
                          : IO
                          #68
                          _block
                            #69
                            _dispatch
                              #69
                              _object
                                io
                              : IO
                              out_string
                              (
                              #69
                              _string
                                "t: "
                              : String
                              )
                            : IO
                            #70
                            _dispatch
                              #70
                              _object
                                io
                              : IO
                              out_string
                              (
                              #70
                              _dispatch
                                #70
                                _object
                                  t
                                : Bool
                                type_name
                                (
                                )
                              : String
                              )
                            : IO
                            #71
                            _dispatch
                              #71
                              _object
                                io
                              : IO
                              out_string
                              (
                              #71
                              _string
                                "\n"
                              : String
                              )
                            : IO
                            #73
                            _assign
                              b1
                              #73
                              _object
                                t
                              : Bool
                            : Bool
                            #74
                            _dispatch
                              #74
                              _object
                                io
                              : IO
                              out_string
                              (
                              #74
                              _string
                                "b1: "
                              : String
                              )
                            : IO
                            #75
                            _dispatch
                              #75
                              _object
                                io
                              : IO
                              out_string
                              (
                              #75
                              _dispatch
                                #75
                                _object
                                  b1
                                : Bool
                                type_name
                                (
                                )
                              : String
                              )
                            : IO
                            #76
                            _dispatch
                              #76
                              _object
                                io
                              : IO
                              out_string
                              (
                              #76
                              _string
                                "\n"
                              : String
                              )
                            : IO
                            #78
                            _assign
                              b2
                              #78
                              _object
                                t1
                              : Object
                            : Object
                            #79
                            _dispatch
                              #79
                              _object
                                io
                              : IO
                              out_string
                              (
                              #79
                              _string
                                "b2: "
                              : String
                              )
                            : IO
                            #80
                            _dispatch
                              #80
                              _object
                                io
                              : IO
                              out_string
                              (
                              #80
                              _dispatch
                                #80
                                _object
                                  b2
                                : Object
                                type_name
                                (
                                )
                              : String
                              )
                            : IO
                            #81
                            _dispatch
                              #81
                              _object
                                io
                              : IO
                              out_string
                              (
                              #81
                              _string
                                "\n"
                              : String
                              )
                            : IO
                            #83
                            _assign
                              b1
                              #83
                              _dispatch
                                #83
                                _object
                                  f
                                : Bool
                                copy
                                (
                                )
                              : Bool
                            : Bool
                            #84
                            _dispatch
                              #84
                              _object
                                io
                              : IO
                              out_string
                              (
                              #84
                              _string
                                "b1: "
                              : String
                              )
                            : IO
                            #85
                            _dispatch
                              #85
                              _object
                                io
                              : IO
                              out_string
                              (
                              #85
                              _dispatch
                                #85
                                _object
                                  b1
                                : Bool
                                type_name
                                (
                                )
                              : String
                              )
                            : IO
                            #86
                            _dispatch
                              #86
                              _object
                                io
                              : IO
                              out_string
                              (
                              #86
                              _string
                                "\n"
                              : String
                              )
                            : IO
                            #88
                            _assign
                              b2
                              #88
                              _dispatch
                                #88
                                _object
                                  f2
                                : Object
                                copy
                                (
                                )
                              : Object
                            : Object
                            #89
                            _dispatch
                              #89
                              _object
                                io
                              : IO
                              out_string
                              (
                              #89
                              _string
                                "b2: "
                              : String
                              )
                            : IO
                            #90
                            _dispatch
                              #90
                              _object
                                io
                              : IO
                              out_string
                              (
                              #90
                              _dispatch
                                #90
                                _object
                                  b2
                                : Object
                                type_name
                                (
                                )
                              : String
                              )
                            : IO
                            #91
                            _dispatch
                              #91
                              _object
                                io
                              : IO
                              out_string
                              (
                              #91
                              _string
                                "\n"
                              : String
                              )
                            : IO
                          : IO
                        : IO
                      : IO
                    : IO
                  : IO
                : IO
              : IO
            : IO
          : IO
        : IO
```
### bad.cl
