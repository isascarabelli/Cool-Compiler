# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Código](#código)
3. [Testes](#testes)

## Descrição do Projeto
Este projeto é um `analisador semântico` desenvolvido como parte do TP4 de Compiladores. Essa é a terceira fase da compilação, onde se verificam os erros de semântica no código fonte e se faz a coleta das informações necessárias para a próxima fase da compilação, a geração de código. O objetivo da análise semântica é trabalhar no nível de inter-relacionamento entre partes distintas do programa. 

Essa etapa recebe uma árvore sintática abstrata construída pelo `parser` para verificação, e gera uma árvore sintática abstrata (ASTs), da mesma forma que a etapa anterior de análise sintática, porém, dessa vez amarrando os tipos de cada expressão, para que seja utilizada pelo gerador de código. A implementação feita pelo grupo percorre a árvore, gerencia as informações que recolhe da árvore e usa essas informações para apontar os erros ou validar a semântica da linguagem Cool.

Os códigos alterados pelo grupo se encontram em “cool-tree.java” e “ClassTable.java”. Iremos explicar a seguir as alterações feitas em cada arquivo.

## Código
### cool-tree.java

### ClassTable.java
Esta classe é um espaço reservado para alguns métodos, incluindo relatórios de erros e inicialização de classes básica. Usada para armazenar e gerenciar informações semânticas de classes em COOL, a ClassTable controla a hierarquia de herança e tipos básicos, valida identificadores e métodos, e permite verificar relações de subtipos entre classes.

Seu funcionamento básico consiste quando a `ClassTable` é criada, inicializando classes básicas. Para cada classe fornecida, `ClassTable` verifica a herança e registra métodos e atributos, onde durante a compilação, `ClassTable` permite verificações de subtipos, herança, e compatibilidade de tipos, gerando erros quando há inconsistências semânticas.

No começo do arquivo, é declarado os principais atributos da classe. Vamos explorar um pouco sobre eles:

`currentClass` armazena a classe atual, usada em contextos como verificações de tipo SELF_TYPE.
```
    private AbstractSymbol currentClass;
```

`semantErrors` conta erros semânticos, e `errorStream` imprime mensagens de erro.
```
    private int semantErrors;
    private PrintStream errorStream;
```

`AbstractSymbol` representa os tipos básicos (`Object`, `IO`, `Int`, `Bool`, `String`). Eles são utilizados para criar a hierarquia básica da linguagem, onde cada classe é responsável por manipular o tipo a quem foi descrito.
`object_class` é a raiz de todas as outras classes no sistema. Todos os objetos em Cool derivam, direta ou indiretamente, dessa classe, e `io_class` que representa a classe IO, que herda de Object e adiciona funcionalidades específicas para entrada e saída.
```
    private AbstractSymbol object_class;
    private AbstractSymbol io_class;
    private AbstractSymbol int_class;
    private AbstractSymbol bool_class;
    private AbstractSymbol string_class;
```

`classes` é uma lista de classes, enquanto `classMap` mapeia símbolos para classes, facilitando consultas rápidas por nome.
```
    private Vector<class_c> classes;
    private HashMap<AbstractSymbol, class_c> classMap;
```

`illegalIdentifiers` armazena identificadores que são reservados ou ilegais (como `SELF_TYPE`). Esses identificadores são inicializados a partir de `illegalIdentifierSymbols`.
```
    private  Vector<AbstractSymbol> illegalIdentifiers;
    private static final AbstractSymbol[] illegalIdentifierSymbols = 
    new AbstractSymbol[] {
	TreeConstants.self,
	TreeConstants.SELF_TYPE
    };
```

Em seguida, temos o método `installBasicClasses` que define as classes básicas de COOL. Ele cria classes que representam conceitos fundamentais e essas classes são implementadas como árvores de sintaxe (parse trees) simplificadas. Vamos aos detalhes:

- Classe Object:

`Object` é a classe raiz de todas as outras classes e não tem nenhuma classe pai (indicada por `TreeConstants.No_class`). `cool_abort()` interrompe o programa, 
`type_name()` retorna o nome da classe como uma String e `copy()` retorna uma cópia do objeto usando SELF_TYPE, que representa o tipo do objeto que chama o método.

```
class_c Object_class = 
    new class_c(0, 
	       TreeConstants.Object_, 
	       TreeConstants.No_class,
	       new Features(0)
		   .appendElement(new method(0, 
		      TreeConstants.cool_abort, 
		      new Formals(0), 
		      TreeConstants.Object_, 
		      new no_expr(0)))
		   .appendElement(new method(0,
		      TreeConstants.type_name,
		      new Formals(0),
		      TreeConstants.Str,
		      new no_expr(0)))
		   .appendElement(new method(0,
		      TreeConstants.copy,
		      new Formals(0),
		      TreeConstants.SELF_TYPE,
		      new no_expr(0))),
	       filename);
```

- Classe IO:

`IO` herda de `Objec`t e fornece métodos para entrada e saída. `out_string(Str)` escreve uma String no console, `out_int(Int)` escreve um Int no console, `in_string()` lê uma String do console e `in_int()` lê um Int do console.

```
class_c IO_class = 
    new class_c(0,
	       TreeConstants.IO,
	       TreeConstants.Object_,
	       new Features(0)
		   .appendElement(new method(0,
		      TreeConstants.out_string,
		      new Formals(0)
			  .appendElement(new formalc(0,
			     TreeConstants.arg,
			     TreeConstants.Str)),
		      TreeConstants.SELF_TYPE,
		      new no_expr(0)))
		   .appendElement(new method(0,
		      TreeConstants.out_int,
		      new Formals(0)
			  .appendElement(new formalc(0,
			     TreeConstants.arg,
			     TreeConstants.Int)),
		      TreeConstants.SELF_TYPE,
		      new no_expr(0)))
		   .appendElement(new method(0,
		      TreeConstants.in_string,
		      new Formals(0),
		      TreeConstants.Str,
		      new no_expr(0)))
		   .appendElement(new method(0,
		      TreeConstants.in_int,
		      new Formals(0),
		      TreeConstants.Int,
		      new no_expr(0))),
	       filename);
```

- Classe Int:

`Int` representa um número inteiro e herda de `Object`. Possui apenas um atributo `val` para armazenar o valor inteiro.

```
class_c Int_class = 
    new class_c(0,
       TreeConstants.Int,
       TreeConstants.Object_,
       new Features(0)
	   .appendElement(new attr(0,
		    TreeConstants.val,
		    TreeConstants.prim_slot,
		    new no_expr(0))),
       filename);
```
- Classe Bool:

`Bool` herda de Object e assim como `Int`, possui um único atributo `val`.

```
class_c Bool_class = 
    new class_c(0,
       TreeConstants.Bool,
       TreeConstants.Object_,
       new Features(0)
	   .appendElement(new attr(0,
		    TreeConstants.val,
		    TreeConstants.prim_slot,
		    new no_expr(0))),
       filename);
```
- Classe Str:

`Str` representa uma `String` e herda de `Object`. `val` denota o comprimento da String, `str_field` O conteúdo da String em si, `length()` retorna o comprimento da String, `concat(Str)` concatena a String com outra e `substr(Int, Int)` extrai uma substring entre dois índices.

```
class_c Str_class =
    new class_c(0,
       TreeConstants.Str,
       TreeConstants.Object_,
       new Features(0)
	   .appendElement(new attr(0,
		    TreeConstants.val,
		    TreeConstants.Int,
		    new no_expr(0)))
	   .appendElement(new attr(0,
		    TreeConstants.str_field,
		    TreeConstants.prim_slot,
		    new no_expr(0)))
	   .appendElement(new method(0,
		      TreeConstants.length,
		      new Formals(0),
		      TreeConstants.Int,
		      new no_expr(0)))
	   .appendElement(new method(0,
		      TreeConstants.concat,
		      new Formals(0)
			  .appendElement(new formalc(0,
			     TreeConstants.arg, 
			     TreeConstants.Str)),
		      TreeConstants.Str,
		      new no_expr(0)))
	   .appendElement(new method(0,
		      TreeConstants.substr,
		      new Formals(0)
			  .appendElement(new formalc(0,
			     TreeConstants.arg,
			     TreeConstants.Int))
			  .appendElement(new formalc(0,
			     TreeConstants.arg2,
			     TreeConstants.Int)),
		      TreeConstants.Str,
		      new no_expr(0))),
	       filename);
```

Após serem criadas, essas classes são adicionadas a uma lista (`classes`) e a um mapa (`classMap`) para que possam ser facilmente acessadas e identificadas durante a execução do programa.

```
	classes.add(Object_class);
	classes.add(IO_class);
	classes.add(Int_class);
	classes.add(Bool_class);
	classes.add(Str_class);
	
	classMap.put(TreeConstants.Object_, Object_class);
	classMap.put(TreeConstants.IO,      IO_class);
	classMap.put(TreeConstants.Int,     Int_class);
	classMap.put(TreeConstants.Bool,    Bool_class);
	classMap.put(TreeConstants.Str,     Str_class);
```

O método `semant` é chamado em cada classe básica, indicando que uma análise semântica básica é realizada para garantir que essas classes fundamentais estão corretamente definidas.

```
	Object_class.semant(this);
	IO_class.semant(this);
	Int_class.semant(this);
	Bool_class.semant(this);
	Str_class.semant(this);
```

Identificadores reservados são adicionados a uma lista (`illegalIdentifiers`) para impedir que o programador os redefina, pois eles fazem parte do núcleo do sistema.

```
	illegalIdentifiers.add(TreeConstants.Object_);
	illegalIdentifiers.add(TreeConstants.IO);
	illegalIdentifiers.add(TreeConstants.Int);
	illegalIdentifiers.add(TreeConstants.Bool);
	illegalIdentifiers.add(TreeConstants.Str);
```

- Construtor ClassTable

O construtor recebe uma lista de classes (`Classes cls`), configura a hierarquia básica e realiza verificações iniciais.

`installBasicClasses` chama métodos para instalar as classes básicas, adicionando-as à lista `classes` e mapeando-as em `classMap`, e para cada classe verifica se há ciclos na hierarquia de herança, lançando um erro semântico em caso de ciclos. Abaixo está o código:

```
    public ClassTable(Classes cls) {
	semantErrors = 0;
	errorStream = System.err;
       
	classes = new Vector();
	classMap = new HashMap<AbstractSymbol, class_c>();

	// Create all basic classes
	installBasicClasses();

	// Iterate through Classes list and log all
	// classes in class table
	for(Enumeration<class_c> e=cls.getElements(); 
	    e.hasMoreElements();) {

	    class_c c = e.nextElement();
	    classes.add(c);
	    Object o = classMap.put(c.getName(), c);

	    if(o != null) {
		semantError(c.getFilename(), c)
		    .println("Class " + c.getName().getString() + 
			     " was previously defined.");
	    }
	}


	for(Enumeration<class_c> e=cls.getElements();
	    e.hasMoreElements();) {
	    class_c c = e.nextElement();
	    checkInheritance(c.getName());
	}


	if(errors()) {
	    System.err.println("Compilation halted due to static semantic errors.");
	    System.exit(1);
	}
    }
```
`checkInheritance` verifica se uma classe herda de um tipo proibido ou se há ciclos de herança. `semantError` registra e imprime erros semânticos, incrementando semantErrors. `errors` verifica se ocorreram erros durante a análise.
```
public void checkInheritance(AbstractSymbol a, Vector<AbstractSymbol> v, AbstractSymbol superClass) {
	class_c c = getClass_c(a);
	if(a.equals(TreeConstants.No_class)) {
	    // At the top of heirarchy
	    return;
	} else if(a.equals(TreeConstants.Int) ||
		  a.equals(TreeConstants.Bool) ||
		  a.equals(TreeConstants.Str) ||
		  a.equals(TreeConstants.self) ||
		  a.equals(TreeConstants.SELF_TYPE)) {
	    // Object inherits from illegal type
	    class_c parent = getClass_c(superClass);
	    semantError(parent.getFilename(), parent)
		.println("Illegal inheritance from fundamental type: "
			 + superClass.getString()
			 + " inherits "
			 + a.getString());
	    
	} else if(v.contains(a)) {
	    // An illegal heirarchy has been found
	    semantError(c.getFilename(), c)
		.println("Illegal cyclic inheritance at " + c);
	} else if(c == null) {
	    
	    class_c s = getClass_c(superClass);
	    semantError(s.getFilename(), s)
		.println("");

	} else {
	    // Continue checking heirarchy
	    v.add(a);
	    checkInheritance(c.getParent(), v, superClass);
	}
    }

public PrintStream semantError(class_c c) {
	return semantError(c.getFilename(), c);
    }

public PrintStream semantError(AbstractSymbol filename, TreeNode t) {
	errorStream.print(filename + ":" + t.getLineNumber() + ": ");
	return semantError();
    }

public PrintStream semantError() {
	semantErrors++;
	return errorStream;
    }

public boolean errors() {
	return semantErrors != 0;
    }
```

Para os métodos de Manipulação de Hierarquia, temos `getClass_c` e `getParent`, onde `getClass_c` retorna uma classe pelo nome, e `getParent` obtém o símbolo do pai de uma classe. `isSubtypeOf` verifica se uma classe é subtipo de outra, levando em conta tipos especiais como No_type e SELF_TYPE. `lub` encontra o menor supertipo comum entre duas classes na hierarquia de herança, importante para verificar compatibilidade entre tipos.

```
public class_c getClass_c(AbstractSymbol name) {
	return classMap.get(name);
    }

public AbstractSymbol getParent(AbstractSymbol a) {
	return getClass_c(a).getParent();
    }

public class_c getParentClass(AbstractSymbol a) {
	return getParentClass(getClass_c(a));
    }

public class_c getParentClass(class_c c) {
	return getClass_c(c.getParent());
    }

public boolean isSubtypeOf(AbstractSymbol c1, AbstractSymbol c2) {
	if(DEBUG) {
	    System.out.println(c1.getString() + ", " + 
			       c2.getString());
	}

public AbstractSymbol lub(AbstractSymbol a1, AbstractSymbol a2) {

	if(isSelfType(a1)) {
	    return lub(getCurrentClass(), a2);
	} else if(isSelfType(a2)) {
	    return lub(a1, getCurrentClass());
	} if(isSupertypeOf(a1, a2)) {
	    return a1;
	} else {
	    return lub(getClass_c(a1).getParent(),
		       a2);
	}
    }

public AbstractSymbol lub(class_c c1, class_c c2) {
	return lub(c1.getName(), c2.getName());
    }
```
Aqui `getFeature` busca um método ou atributo em uma classe e suas superclasses, `validComparisonTypes` verifica se dois objetos possuem tipos compatíveis para operações de comparação, como Int com Int, Bool com Bool, etc. `isSelfType` determina se um símbolo representa SELF_TYPE. `setCurrentClass` e `getCurrentClass` são métodos para definir e recuperar a classe atual (importante para contexto de verificação de SELF_TYPE).

```
public Feature getFeature(AbstractSymbol className, AbstractSymbol featureName) {
	if(className.equals(TreeConstants.No_class)) {
	    return null;
	} else if(isSelfType(className)) {
	    return getFeature(getCurrentClass(), 
			      featureName);
	} else {
	    class_c c = getClass_c(className);
	    Feature feature = c.getFeature(featureName);

	    if(feature == null) {
		return getFeature(c.getParent(), featureName);
	    } else {
		return feature;
	    }
	}
    }

public boolean validComparisonTypes(Expression e1, Expression e2) {
	if(e1.get_type().equals(TreeConstants.Int) ||
	   e2.get_type().equals(TreeConstants.Int)) {

	    return e1.get_type().equals(TreeConstants.Int) && 
		e2.get_type().equals(TreeConstants.Int);

	} else if(e1.get_type().equals(TreeConstants.Bool) ||
	   e2.get_type().equals(TreeConstants.Bool)) {

	    return e1.get_type().equals(TreeConstants.Bool) && 
		e2.get_type().equals(TreeConstants.Bool);

	} else if(e1.get_type().equals(TreeConstants.Str) ||
	   e2.get_type().equals(TreeConstants.Str)) {

	    return e1.get_type().equals(TreeConstants.Str) && 
		e2.get_type().equals(TreeConstants.Str);

	} else {
	    return true;
	}
    }

public boolean isSelfType(AbstractSymbol symbol) {
	return TreeConstants.self.equals(symbol) ||
	    TreeConstants.SELF_TYPE.equals(symbol);
    }

public void setCurrentClass(AbstractSymbol symbol) {
	this.currentClass = symbol;
    }

public AbstractSymbol getCurrentClass() {
	return this.currentClass;
    }
```
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
Arquivo criado para testar erros semânticos da linguagem cool. Foram desenvolvidos trechos de código simples, porém contendo erros, com o objetivo de observar como o analisador semântico se comporta diante os erros.

Foram criadas 10 classes apresentando um erro semântico em cada uma, para a criação do arquivo teste bad.cl.

#### Classe TypeMismatch
  
Nessa classe, o objetivo é trabalhar com o erro de atribuição de tipos. No exemplo abaixo, a variável 'x' foi declarada como Int, mas esta sendo atribuída a uma String. 

```
class TypeMismatch {
    x : Int <- "Isso é uma String";
};
```
Resposta do Parser:
![image](https://github.com/user-attachments/assets/d5037e07-5fd6-41f6-b6c0-cbf939770bad)

#### Classe CyclicInheritance

O objetivo dessa classe é mostrar o erro de herança cíclica. Nesse caso, a classe CyclicInheritance tenta herdar a si mesma, criando ciclos infinitos. Esse tipo de erro causam erros na compilação e impede uma definição correta da hierarquia. 

```
class CyclicInheritance inherits CyclicInheritance {};
```
Resposta do Parser:
![image](https://github.com/user-attachments/assets/dc13c00b-df95-4f7c-b292-0983f50622e9)


#### Métodos incompatíveis após herança de classe
##### Classe Market e MarketSector

Nesse caso, a classe MarketSector herda da classe Market e redefine o método foodCode. Em Market, o método foodCode recebe um parâmetro do tipo Int e retorna um Int. Porém, quando o método é redefinido na classe MarketSector, ele recebe uma String e retorna uma String. 
O erro se faz presente após a redefinição, pois viola a coerência dos métodos de uma hierarquia de classe, sendo necessário e correto, que a nova implementação mantenha os mesmos parâmetros e tipo de retorno do método original. 

```
class Market {
    foodCode(x : Int) : Int { x + 1 };
};

class MarketSector inherits Market {
    foodCode(x : String) : String { "secao de verduras"};
};
```
Resposta do Parser:
![image](https://github.com/user-attachments/assets/f1d8ecfe-44e7-4f03-a866-c126622f92e9)

#### Classe PrimitiveInheritance

Nesse caso, o erro está associado a tentativa de herdar diretamente um tipo primitivo. Os tipos primitivos não são projetados para serem herdados.  

```
class PrimitiveInheritance inherits String {};
```
Resposta do Parser:
![image](https://github.com/user-attachments/assets/78d5247d-3c23-4af0-a1f3-f51156197e70)




