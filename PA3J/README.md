# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Código](#código)
3. [Testes](#testes)

## Descrição do Projeto

Este projeto é um `Analisador Sintático` desenvolvido como parte do TP3 de Compiladores.
O Analisador Léxico, também chamado de `Parser` é responsável por receber a sequência de tokens gerada pelo analisador léxico e gerar a árvore de parsing.
No projeto do parser, temos por objetivo verificar se o programa de entrada, nesse caso o `lexer`, está sintaticamente correto. Outro objetivo é gerar uma `Árvore Sintática Abstrata (AST)`, que nada mais é do que uma representação condensada de uma árvore de derivação, onde será útil para representar a construção de nossa linguagem COOL. 

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
Arquivo criado para testar toda e qualquer construção legal da linguagem cool. Nele foram desenvolvidos partes de código que passarão pelo analisador sintático, para verficarmos a Árvore Sintática Abstrata (AST) gerada e se nosso analisador identifica diversas estruturas válidas em cool. 

Reutilizamos o código criado para o TP1 de um dos integrantes, que funiona como uma pilha em cool. Usamos ele como base para testar estruturas de classe, funções, loops, atribuições, comparações e blocos.

Exemplos:
- Classes e funções
```
class Stack {

   x : SELF_TYPE;

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

#### Operações matemáticas
Ver como o analisador sintático se comporta com precedência de operadores.
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

	   1 + 2 * (3 + 4) / (5 - ~6);
        }
     };
};
```
Parte da saída da Árvore Sintática:

![image](https://github.com/user-attachments/assets/b1600b12-bdb3-461e-86ce-82ebaa55aef9) - "a+b-c" e "a-b+c"

![image](https://github.com/user-attachments/assets/8f0a5575-f816-4c85-a932-ca6d1a622bf0) - 1 + 2 * (3 + 4) / (5 - ~6)

Conforme esperado, ele segue a precedência colocando os mais prioritários em um nível mais abaixo da árvore.

#### Herança e Sobrescrita (Dispatch)
Sobrescrita de funções em classes com herança testando qual delas ele considera.
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
Parte da AST:

![image](https://github.com/user-attachments/assets/dda1ebd1-e9ff-4686-8e1e-02796685e76a)

Vemos o uso do dispatch indicando que a função vem de outro tipo.

#### Amarração de varíavéis em escopos diferentes
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
Saída da AST:

![image](https://github.com/user-attachments/assets/e794b491-496a-4bb0-b0d6-cac206a1924d)

#### If-Then-Else dentro de blocos de outro If-Then-Else
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
Saída da AST:

![image](https://github.com/user-attachments/assets/94705104-ee65-401c-a68d-b2d577d154ad)

### bad.cl
Arquivo criado para testar erros sintáticos da linguagem cool. Foram desenvolvidos trechos de código simples, porém contendo erros, com o objetivo de observar como o analisador sintático se comporta diante os erros. 

Foram criadas classes apresentando um erro sintático em cada uma para a criação desse arquivo teste. 

#### Classe HashSymbol
O símbolo # não é um caractere válido na linguagem Cool. Usar ele de qualquer forma terá como resultado um erro de sintaxe.
```
class HashSymbol {
           x : Int;  #
};
```
Resposta do Parser:

![image](https://github.com/user-attachments/assets/c89f79b4-4fe3-4974-9198-e05f79db1e4d)

#### Classe Test
O objetivo desse erro é mostrar que a falta de um parênteses, causará um erro de sintaxe.

```
class Test {
    testMethod() : Int {
                {  
(5 + 3;
        10;
   }
                    
    }
};
```
Resposta do Parser:

![image](https://github.com/user-attachments/assets/7a87579b-f206-4086-bd97-a7aed1d12723)

#### Classe ControlFlow
Na expressão if, é necessário que na sua estrutura termine com a palavra reservada fi.
Na expressão while, é necessário a presença do bloco pool para encerrar o loop. 

```
class ControlFlow {
    controlTest() : Int {
        if true then 5;
        while true loop 10;
    }
};
```
Resposta do Parser:
> Erro if:
![image](https://github.com/user-attachments/assets/9d188535-fecd-4a40-bece-79742ecd72b1)

>Erro while:
![image](https://github.com/user-attachments/assets/250f93c0-d135-4319-a3fb-79c92d11bd78)

#### Classe IncompleteExpressions
A expressão "5 +- 2" está incompleta ou incorreta. Caso incompleta, é necessário um valor entre os sinais de positivo e negativo. Caso incorreta, é necessário manter apenas um sinal. 
Na expressão "2*;" ela está incompleta, e nesse caso, o resto da operação foi deixada na linha abaixo. 

```
class IncompleteExpressions {
    incomplete() : Int {
        5 +- 2;
        2 * ;
        3;
    };
};
```
Resposta do Parser:

![image](https://github.com/user-attachments/assets/2952228d-9ebd-47bb-8e5d-b42d3071280c)
![image](https://github.com/user-attachments/assets/20a9a46c-f6e2-4bff-8c7f-16ea44a0288c)
![image](https://github.com/user-attachments/assets/2354f571-7793-4bcd-b663-dba2f333227b)

#### Classe class (sem nome)
Na linguagem Cool, é necessário que todas as classes tenham um nome. 

```
class {
    method() : Int {
        0;
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/729926b0-71c8-4c45-b321-e627c157511b)

#### Classe TypeError
É necessário que o tipo do retorno seja válido e reconhecido. "Stringabc oi" não é aceito. 

```
class TypeError {
    test() : Stringabc oi {
        let x : Stri <- 10 in x;
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/e7c24a41-459e-4369-ae43-eee2b7768c29)

#### Classe MethodError
Em missingReturnTypeMethod, não exite uma instrução de retorno. 

```
class MethodError {
    badMethod() : Int { 
        0;
    }

    missingReturnTypeMethod() : Int {
        5;
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/f9fa1b5f-3328-4be8-8e28-8b3b5ece3b05)

#### Classe AssignmentError
Antes de ser atribuída, a variável y não foi declarada. 
Em "x <= 5", o operador <= é usado para comparação e não para atribuição, sendo necessário uar <-.

```
class AssignmentError {
    assignTest() : Int {
         y <- 10
         x <= 5;
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/75631d90-57e1-434c-bb52-4555056375ea)


#### Classe NewError
O new foi usado de forma incompleta e incorreta, o new é usado para instanciar objetos de uma classe, sendo necessário estar seguido do nome da classe a ser instanciada. Assim, não foi instanciado um objeto da classe Object.

```
class NewError {
    createObject() : Object {
        new;
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/647d6525-9c5a-442d-a5e6-b50973a7e773)


#### Classe SequenceError
Está faltando um ponto e vírgula após o 5. Na linguagem Cool, é necessário que todas as instruções que pertencem ao mesmo método sejam encerradas com um ponto e vírgula. 

```
class SequenceError {
    sequenceTest() : Int {
        5
        10;
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/a8aa17da-b03c-4097-8c68-17a9e3b6ec8f)

#### Classe CaseError
Está faltando uma variável para o case, sendo necessário que x estivesse declarado previamente, e o bloco case em si não possui um padrão ou um esac para encerramento da construção. 

```
class CaseError {
    caseTest() : Int {
        case x of
        0 : 0;
    }
};

```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/841f4030-ef5d-4319-84bd-51165aa874a5)


#### Classe LetError
A variável X não é inicializada no bloco let, sendo necessário a atribuição de um valor a ela. 
Não é especificado o tipo de Y e façta atribuir um valor a essa variável.

```
class LetError {
    letTest() : Int {
        let x : Int in x; 
        let y in y + 1;  
    }
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/25956c81-876c-4520-a85c-8b1e78ae49dc)


#### Classe ReservedWordError
Não é permitido que palavras reservadas sejam usadas como identificadores na linguagem Cool. Dessa forma, o "let" não poderia ser usado como um identificador. 
```
class ReservedWordError {
    test() : Int {
        let let : Int <- 5 in let
    };
};
```

Resposta do Parser:
![image](https://github.com/user-attachments/assets/c0da6156-f86c-43c9-ab23-04d6326cf483)
