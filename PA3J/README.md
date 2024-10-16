# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Como Funciona](#como-funciona)
3. [Código](#código)
4. [Testes](#testes)

## Descrição do Projeto

Este projeto é um `Analisador Sintático` desenvolvido como parte do TP3 de Compiladores.
O Analisador Léxico, também chamado de `Parser` é responsável por receber a sequência de tokens gerada pelo analisador léxico e gerar a árvore de parsing.
No projeto do parser, temos por objetivo verificar se o programa de entrada, nesse caso o `lexer`, está sintaticamente correto. Outro objetivo é gerar uma `Árvore Sintática Abstrata (AST)`, que nada mais é do que uma representação condensada de uma árvore de derivação, onde será útil para representar a construção de nossa linguagem COOL. 

## Como Funciona


## Código
O programa se inicia com algumas funções pré defeinidas, que executam algumas tarefas como retornar a linha atual e indicar a linha em que há um erro. Quando essas funções são disparadas é tarefa da biblioteca `CUP` lidar no background. Outra parte do início do código é a declaração dos terminais, onde tudo que é interpretado pelo analisador léxico como terminal está presente aqui, para também ser considerado a medida que o arquivo é lido. Como podemos ver abaixo, todas as palavras reservadas e caracteres de uso da linguagem.

```
terminal CLASS, ELSE, FI, IF, IN, INHERITS, LET, LET_STMT, LOOP, POOL, THEN, WHILE;
terminal CASE, ESAC, OF, DARROW, NEW, ISVOID;
terminal ASSIGN, NOT, LE, ERROR;
terminal PLUS, DIV, MINUS, MULT, EQ, LT, DOT, NEG, COMMA, SEMI, COLON;
terminal LPAREN, RPAREN, AT, LBRACE, RBRACE;
terminal AbstractSymbol STR_CONST, INT_CONST;
terminal Boolean BOOL_CONST;
terminal AbstractSymbol TYPEID, OBJECTID;
```

Um ponto muito importante nas linguagem de programação no geral são as declarações de precedência. Sem as precedências definidas corretamente, poderia ser possível gerar duas árvores diferentes dependendo da definição, sendo ela mais à direita ou mais à esquerda. Como exemplo, a expressão `3 + 4 * 5` pode gerar duas árvores diferentes. Uma que avalia primeiro `3 + 4` e em seguida `7 * 5` e outra que avalia primeiro `4 * 5` e em seguida `3 + 20`. Sabemos que esta última é a correta, porém precisamos descrever isso para o compilador funcionar corretamente. Abaixo, as precedências definidas:

```
precedence left NOT;
precedence nonassoc LE, LT, EQ;
precedence left MINUS, PLUS;
precedence left MULT, DIV;
precedence left ISVOID;
precedence left NEG;
precedence left AT;
precedence left DOT;
```

A operação que sempre será realizada primeiro será a mais abaixo, da esquerda para a direita. Em cool, é definido pelo manual da linguagem que a operação mais prioritária seja o `DOT` e a menos prioritária seja o `NOT`. Detalhe importante de ressaltar é que `MULT, DIV` está abaixo de `MINUS, PLUS`, solucionando o problema citado acima e garantindo que sempre tenhamos uma avaliação e resultado corretos.

Com as declarações de precedência definidas, asseguramos que a derivação ocorra da maneira que queremos e que tudo siga a ordem pré-estabelecida pelas boas práticas e pelo senso comum.

Em seguida, podemos verificar a declaração de não terminais a serem analisados.
O não terminal raiz é o `nonterminal programc program`, onde a partir dele toda a AST será desenvolvida.

Abaixo podemos verificar a forma como todo o processo de análise de fará através do código do parser. Como o `program` é a raiz, a partir dele que se desencadeará a análise. O processo de avaliação de expressões segue analisando a ou as classes do programa, onde o que foi avaliado será atribuido a `RESULT` que faz parte da implementação do `CUP` para uma pilha de parsing. E o que será imputado em `RESULT` será uma nova instância do que está sendo avaliado, com a linha atual e o que foi lido por essa avaliação.

```
program	
	::= class_list:cl
	    {: RESULT = new programc(curr_lineno(), cl); :}
        ;
```
Um detalhe da implementação do `CUP` é que tudo o que se encontra entre `{: :}` será utilizado para conter todas as ações do parser.

Na sequência, as declarações `nonterminal Classes class_list` e `nonterminal class_c class` são responsáveis por analisar as classes, onde será analisado uma ou várias classes.

Vamos analisar a avaliação de uma expressão que declara uma `class`:

```
class
	::= CLASS TYPEID:n LBRACE dummy_feature_list:f RBRACE SEMI
	    {: RESULT = new class_c(curr_lineno(), n, 
		                   AbstractTable.idtable.addString("Object"), 
				   f, curr_filename()); :}
	| CLASS TYPEID:n INHERITS TYPEID:p LBRACE dummy_feature_list:f RBRACE SEMI
	    {: RESULT = new class_c(curr_lineno(), n, p, f, curr_filename()); :}
	
	| CLASS TYPEID error SEMI
	| CLASS TYPEID INHERITS TYPEID error SEMI
	| error
	;
```

Aqui podemos verificar melhor como é feita a avaliação de expressões. No trecho `CLASS TYPEID:n LBRACE dummy_feature_list:f RBRACE SEMI` é verificado se o que está sendo lido tem esse formato, com uma classe com identificador, uma abertura de chaves, um não terminal, um fechamento de chaves e um `;`. Caso não seja possível que se enquadre nesse formato, a verificação `CLASS TYPEID:n INHERITS TYPEID:p LBRACE dummy_feature_list:f RBRACE SEMI` é feita e seguirá até que, ou resulte em sucesso, ou um `error` é identificado.
Isso descreve exatamente como uma classe deve ser declarada, o que em caso de sucesso, realiza uma ação de empilhar em `RESULT` uma nova classe, passando a linha, o identificador da classe, uma chamada de método para adicionar esse identificador na tabela dos IDS, o identificador do não terminal e o nome do arquivo.

Veremos que o padrão descrito acima será recorrente em todas as avaliações de expressões, mudando apenas o que será avaliado e o que será empilhado em `RESULT`.

Em seguida temos as avaliações dos métodos e atribuições contidos no programa, declarados como os não terminais `nonterminal Features dummy_feature_list, nonterminal Features features, nonterminal Feature feature`. O não terminal `dummy_feature_list` é usado em caso de haver métodos vazios. O restante lida com um ou vários métodos presentes no programa. Abaixo podemos ver todas as formas das expressões avaliadas:

```
feature ::= 
	attribute:a
	{: RESULT=a; :}
	| OBJECTID:id1 LPAREN RPAREN COLON TYPEID:id2 LBRACE expression:e RBRACE SEMI
	{: RESULT=new method(curr_lineno(), id1, new Formals(curr_lineno()), id2, e); :}
	| OBJECTID:id1 LPAREN formals:f RPAREN COLON TYPEID:id2 LBRACE expression:e RBRACE SEMI
	{: RESULT=new method(curr_lineno(), id1, f, id2, e); :}

	// Error cases for invalid functions identifier
	| error SEMI
	;
```

Aqui podemos ver que para se analisar uma atribuição de expressão, é feita a chamada de `attribute:a` e em caso de negativa, é feita a avaliação se o que está sendo analisado é um método, com ou sem passagem de parâmetros. Abaixo está a avaliação de declarações:

```
attribute ::= OBJECTID:id1 COLON TYPEID:id2 SEMI
	  {: RESULT=new attr(curr_lineno(), id1, id2, new no_expr(curr_lineno())); :}
	  | OBJECTID:id1 COLON TYPEID:id2 ASSIGN expression:e SEMI
	  {: RESULT=new attr(curr_lineno(), id1, id2, new no_expr(curr_lineno())); :}
	  | error SEMI
	  ;
```

Também foi construído um analisador de parâmetros formais dos métodos, dados por `nonterminal Formals formals, nonterminal formalc formal`, onde `formals` é a declaração de múltiplos parâmetros e `formal` é de apenas um. Segue abaixo a avaliação de um `formal`:

```
formal ::= OBJECTID:o COLON TYPEID:t
       {: RESULT=new formalc(curr_lineno(), o, t); :}
       ;
```

Para as declarações de cada comparador de um `case`, temos o avaliador abaixo.

```
case_branch ::= OBJECTID:id1 COLON TYPEID:id2 DARROW expression:e SEMI
	    {: RESULT=new branch(curr_lineno(), id1, id2, e); :}
	    ;
```

Nesse trecho, é avaliado as expressões de cada uma das comparações feitas em um trecho de `switch-case` do COOL, que no caso é apenas `case`.

Em COOL, o `let` é usado para avaliar expressões atribuindo-as em identificadores para utilizá-los no bloco do `let`. 

```
let_remainder ::= OBJECTID:id1 COLON TYPEID:id2 IN expression:e1
	      {: RESULT=new let(curr_lineno(), id1, id2, new no_expr(curr_lineno()), e1); :}
	      | OBJECTID:id1 COLON TYPEID:id2 ASSIGN expression:e1 IN expression:e2
	      {: RESULT=new let(curr_lineno(), id1, id2, e1, e2); :}
	      | OBJECTID:id1 COLON TYPEID:id2 COMMA let_remainder:e1
	      {: RESULT=new let(curr_lineno(), id1, id2, new no_expr(curr_lineno()), e1); :}
	      | OBJECTID:id1 COLON TYPEID:id2 ASSIGN expression:e1 COMMA let_remainder:e2
	      {: RESULT=new let(curr_lineno(), id1, id2, e1, e2); :}

	      // Error result for Let
	      | error COMMA let_remainder
	      ;
```

Nesse bloco de avaliações, é possível ver que no `let` devemos cobrir vários casos, sendo eles simples sem atribuição de expressão, simples com atribuição de expressão, multiplos sem atribuição de expressão e multiplos com atribuição de expressão.

As últimas definições são as que avaliam as expressões da linguagem. As expressões são tudo que se encontram em blocos de classes ou métodos, além de também ser possível atribuir o resultado de uma expressão à uma variável. Vamos a alguns exemplos:

Abaixo, uma das expressões mais simples, avalia a soma e subtração respectivamente de outras duas expressões.

```
	   | expression:e1 PLUS expression:e2
	   {: RESULT=new plus(curr_lineno(), e1, e2); :}

	   | expression:e1 MINUS expression:e2
	   {: RESULT=new sub(curr_lineno(), e1, e2); :}
```

Importante lembrar que, uma expressão pode também ser um identificador de uma variável, como declarado abaixo:

```
	   | OBJECTID:t
	   {: RESULT=new object(curr_lineno(), t); :}
```

Outra expressão que é avaliada é a de estruturas condicionais e de repetição, que em COOL é o `IF statement` e o `WHILE LOOP`.
```
           | IF expression:e1 THEN expression:e2 ELSE expression:e3 FI
	   {: RESULT=new cond(curr_lineno(), e1, e2, e3); :}

	   | WHILE expression:e1 LOOP expression:e2 POOL
	   {: RESULT=new loop(curr_lineno(), e1, e2); :}
```

Muitas outras expressões são avaliadas, como as de `CASE`, `LET`, chamada de atributo de uma classe, operações e comparações.

## Testes
### good.cl
Arquivo criado para testar toda e qualquer construção legal da linguagem cool. Nele foram desenvolvidos partes de código que passarão pelo analisador léxico, para verficarmos a Árvore Sintática Abstrata (AST) gerada e se nosso analisador identifica diversas estruturas válidas em cool. 

Reutilizamos o código criado para o TP1 de um dos integrantes, que funiona como uma pilha em cool. Usamos ele como base para testar estruturas de classe, funções, loops, atribuições, comparações e blocos.

Exemplos:
- Classes e funções
```
class Stack {

   top : String;   

   next : Stack; 

   isNil() : Bool { false };

   head()  : String { top };

   tail()  : Stack { next };

   push(i: String): Stack {
       (new Stack).init(i, self)
   };

   init(i : String, r : Stack) : Stack {
      {
         top <- i;
         next <- r;
         self;
      }
   };

};
```
- Declarações e atribuições
```
	n : Int;
	m : Int;
	result : Int;
	nil : Stack;
	stack : Stack <- new Stack.init("-1", nil);
```

Além dessas construções, construímos algumas expressões e estruturas de blocos que poderiam gerar ambiguidade, para ver se elas se comportariam conforme descrito no Manual de Referência da linguagem.

# Operações matemáticas
Ver como o anaisador semântico se comporta com precedência de operadores.
```
class Math {
	f() : Int {
		{
			a+b-c;
			a-b+c;

			a+b*c;
			a*b+c;

			a+b/c;
			a/b+c;

			a-b*c;
			a*b-c;

			a-b/c;
			a/b-c;

			a*b/c;
			a/b*c;
		}
	};
};
```
# Herança e Sobrescrita (Dispatch)
Sobrescrita de funções em classes com herança testando qual delas ele considera. No caso do exemplo abaixo, o valor impresso deveria ser 110.
```
class A {
    foo() : Int { 42 };
};

class B inherits A {
    foo() : Int { 100 }; 
    bar() : Int { foo() + 10 };
    test() : IO {
        let b : B <- new B in 
		out_int(b.bar()).out_newline();
    }
};
```
# Amarração de varíavéis em escopos diferentes
A linguagem cool permite que variáveis em escopos diferentes possuam o mesmo identificador. Devido a isso, variáveis com o mesmo nome deverão ser amarradas aos escopos mais internos.  
```
class A {
	testLet() : Int {
        let x : Int <- 5 in  
            let x : Int <- 10 in  
                io.out_int(x);  -- Valor de X = 10
            io.out_int(x);  -- Valor de X = 10
        io.out_int(x);  -- Valor de X = 5
        0
    };
};
```
# If-Then-Else dentro de blocos de outro If-Then-Else
Observar como funciona a amarração de cada bloco (tal 'else' faz parte do bloco If-Then-Else mais interno ou do bloco mais externo?).
```
if ch = "e" then {
	if stack.head() = "-1" then "Do Nothing"
    	else {
		ch <- stack.head();
		stack <- stack.tail();

		if ch = "+" then {
			p <- stack.head();
			stack <- stack.tail();
			m <- c2i(p);

			p <- stack.head();
			stack <- stack.tail();
			n <- c2i(p);
							
			result <- m + n;
			p <- i2c(result);
			stack <- stack.push(p);
		}
		else
		if ch = "s" then {
			p <- stack.head();
			stack <- stack.tail();

			q <- stack.head();
			stack <- stack.tail();
			stack <- stack.push(p);
			stack <- stack.push(q);
		}
		else
			{ stack <- stack.push(ch); }
		fi 
		fi;
		}
		fi;
	} else 
			    
	if ch = "d" then print_stack(stack) else
	{stack <- stack.push(ch); "Erro";}
	fi fi;
```
