# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Código](#código)
3. [Testes](#testes)

## Descrição do Projeto


## Código


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

### bad.cl
