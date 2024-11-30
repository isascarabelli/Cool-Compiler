# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Código](#código)
3. [Testes](#testes)

## Descrição do Projeto

## Código
### CgenClassTable.java

Esse código implementa a classe CgenClassTable, que lida com a estrutura de herança das classes Cool e gera código assembly para a execução do programa. Ela organiza as classes do programa em uma árvore de herança; gera tabelas de apoio para atributos, métodos e constantes; produz o código assembly necessário para inicializar classes e executar métodos; faz uso de outras classes auxiliares (CgenNode, SymbolTable e Cgen Support) para gerenciar a estrutura do compilador.

Essa classe possui vários métodos, mas podemos separá-los nas seguintes etapas principais:
- Gerenciamento da Árvore de Herança:
     * installBasicClasses(): Instala classes básicas de Cool (como Object, IO, Int, Bool, e 
       String) e as adiciona na árvore de herança.
     * installClasses(): Adiciona as classes definidas pelo programador na árvore de herança.
     * buildInheritanceTree(): Conecta cada classe ao seu pai na árvore, definindo relações 
       de herança.

- Gerenciamento de Tabelas: criação das tabelas que suportam a execução do programa
    * classTagMap: Associa cada classe a um número único (um "tag").
    * Tabelas globais: Criadas no método codeGlobalData() para mapear nomes de classes, 
       constantes, e funções de coleta de lixo.
    * Tabelas de atributos e métodos: Incluem informações sobre os atributos e métodos de 
      cada classe, geradas com métodos como codeAttrTables() e codeClassMethods().

- Geração de Código Assembly
    * codeConstants(): Cria representações de constantes (como strings e inteiros) no 
      assembly.
    * codeGlobalText(): Define referências globais no segmento .text do assembly, como 
      inicializadores e métodos.
    * codeObjInit() e codeClassMethods(): Geram o código para inicializar objetos e 
      implementar os métodos de cada classe.

- Função Principal: code()
    * Preenche o mapa de "tags" das classes.
    * Gera dados globais e constantes.
    * Constrói tabelas de apoio como:
    * class_nameTab (tabela de nomes de classes).
    * class_objTab (tabela de objetos protótipos das classes).
    * Tabelas de atributos e métodos.
    * Gera o código para inicializadores e métodos.
 
  Resumindo, o compilador lê o programa Cool e cria um conjunto de classes. A CgenClassTable vai então instalar as classes básicas e as classes do programa, construir a árvore de herança e gerar as tabelas e o código assembly para inicialização e execução. 

### cool-tree.java

Para esse arquivo, foi implementado em diferentes classes o método `code`, que se encontra definido porém vazio. O método `code` é responsável pela geração do código assembly para o nó da AST que está sendo definido naquela classe. Então, o que fizemos foi implementar esse método nas diferentes classes declaradas, conforme iremos definir a seguir.

- Classe `assign`

Na classe assign, responsável por criar os nós de `assign` da AST, implementamos a seguinte definição para o método `code`.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for assign");

        expr.code(s, cgenTable);

        if(cgenTable.probe(name) == null) {
            CgenNode nd = (CgenNode) cgenTable.lookup(TreeConstants.self);
            int attrOffset = CgenNode.attrOffsetMap.get(nd.name).get(name);
            CgenSupport.emitStore(CgenSupport.ACC, (2+attrOffset), CgenSupport.SELF, s);
            if (Flags.cgen_Memmgr != Flags.GC_NOGC) {
                CgenSupport.emitAddiu(CgenSupport.A1, CgenSupport.SELF, attrOffset,s);
                CgenSupport.emitJal("_GenGC_Assign", s);
            }
        } else {
            int frameOffset = (Integer) cgenTable.probe(name);
            CgenSupport.emitStore(CgenSupport.ACC, frameOffset, CgenSupport.FP, s);
        }

        CgenSupport.emitComment(s, "Leaving cgen for assign");
    }
```

Este método é responsável por gerar o código para realizar uma operação de `assign`. Ele cuida de armazenar o resultado da expressão de atribuição na localização correta. Inicialmente, é emitido um comentário para assinalar o início do processo. Em seguida, a expressão do lado direito da atribuição é avaliada e armazenada no acumulador. Após isso, é decidido onde armazenar esse valor (No atributo de classe ou variável local) com base no escopo. Por fim, também realiza o garbage collector e adiciona o comentário que finaliza a execução.

- Classe `static_dispatch`

Para as implementações da classe `static_dispatch` foi desenvolvido o código abaixo:

```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenNode c1 = (CgenNode) cgenTable.lookup(type_name);
        CgenSupport.emitComment(s, "BEGIN static dispatch for method "+name+ " in static class " + type_name);

        for(Enumeration en = actual.getElements(); en.hasMoreElements(); ) {
            Expression tmp = (Expression) en.nextElement();
            CgenSupport.emitComment(s, "Evaluating and pushing argument of type "+tmp.get_type()+ " to current frame");
            //Evaluate expression
            tmp.code(s, cgenTable);
            //push value of expression to stack
            CgenSupport.emitPush(CgenSupport.ACC, s);
            CgenSupport.emitComment(s, "Done pushing argument of type " + tmp.get_type() + " to current frame");
        }

        //evaluate object expression
        expr.code(s, cgenTable);

        //handle dispatch on void
        int notVoidDispatchLabel = CgenNode.getLabelCountAndIncrement();
        CgenNode selfie = (CgenNode) cgenTable.lookup(TreeConstants.self);
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.ZERO, notVoidDispatchLabel, s);
        CgenSupport.emitLoadString(CgenSupport.ACC, (StringSymbol) selfie.getFilename(), s);
        CgenSupport.emitLoadImm(CgenSupport.T1, this.lineNumber, s);
        CgenSupport.emitJal("_dispatch_abort", s);
        CgenSupport.emitLabelDef(notVoidDispatchLabel, s);

        //if not void continue as normal

        //load dispatch table into T1

        //CgenSupport.emitLoad(CgenSupport.T1, 2, CgenSupport.ACC, s);
        CgenSupport.emitLoadAddress(CgenSupport.T1, type_name + CgenSupport.DISPTAB_SUFFIX, s);
        CgenSupport.emitLoad(CgenSupport.T1, 2, CgenSupport.T1, s);
        c1.printMethodOffsets();
        //get offset in distpatch table to desired method and execute method
        CgenSupport.emitLoad(CgenSupport.T1, c1.getMethodOffset(name), CgenSupport.T1, s);
        CgenSupport.emitJalr(CgenSupport.T1, s);

        CgenSupport.emitComment(s, "DONE dispatch for method "+name+ " in static class " + type_name);
    }
```

Esse método foi desenvolvido para suportar chamadas de método estáticas, traduzindo uma construção em cool para código de máquina, garantindo que chamadas em objetos nulos sejam tratadas corretamente. Aqui o objetivo é avaliar os argumentos passados para o método e empilhá-los, avaliar a expressão do objeto que invoca o método, tratar chamadas em objetos nulos e determinar e invocar o método correto no contexto estático da classe. Para empilhar os argumentos, é utilizado um for que itera sobre os argumentos da chamada e gera código para avaliar cada argumento, empilhando o valor de cada argumento no topo da pilha. Da mesma forma que o anterior, o valor é armazenado no acumulador.

- Classe `dispatch`

Aqui tratamos do `dispatch`, que trata de despachos também, porém dinamicamente. Segue o código analisado:

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        AbstractSymbol exprType = expr.get_type();
        if (exprType.equals(TreeConstants.SELF_TYPE)) {
            // assign the current type to exprType 
            exprType = CgenNode.getCurrentType();
        }
        CgenNode c1 = (CgenNode) cgenTable.lookup(exprType);
        CgenSupport.emitComment(s, "BEGIN dispatch for method "+name+ " in class " + exprType);

        for(Enumeration en = actual.getElements(); en.hasMoreElements(); ) {
            Expression tmp = (Expression) en.nextElement();
            CgenSupport.emitComment(s, "Evaluating and pushing argument of type "+tmp.get_type()+ " to current frame");
            //Evaluate expression
            tmp.code(s, cgenTable);
            //push value of expression to stack
            CgenSupport.emitPush(CgenSupport.ACC,s);
            CgenSupport.emitComment(s, "Done pushing argument of type "+tmp.get_type()+ " to current frame");
        }

        //evaluate object expression
        expr.code(s, cgenTable);

        //handle dispatch on void
        int notVoidDispatchLabel = CgenNode.getLabelCountAndIncrement();
        CgenNode selfie = (CgenNode) cgenTable.lookup(TreeConstants.self);
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.ZERO, notVoidDispatchLabel, s);
        CgenSupport.emitLoadString(CgenSupport.ACC, (StringSymbol) selfie.getFilename(), s);
        CgenSupport.emitLoadImm(CgenSupport.T1, this.lineNumber, s);
        CgenSupport.emitJal("_dispatch_abort",s);
        CgenSupport.emitLabelDef(notVoidDispatchLabel, s);

        //if not void continue as normal

        //load dispatch table into T1
        CgenSupport.emitLoad(CgenSupport.T1, 2, CgenSupport.ACC, s);
        //c1.printMethodOffsets();
        //get offset in distpatch table to desired method and execute method
        CgenSupport.emitLoad(CgenSupport.T1, c1.getMethodOffset(name), CgenSupport.T1, s);
        CgenSupport.emitJalr(CgenSupport.T1, s);

        CgenSupport.emitComment(s, "DONE dispatch for method "+name+ " in class " + exprType);

    }
```

As principais diferenças aqui em relação ao `static_dispatch` é que dinamicamente ele é determinado em tempo de execução, e no estático é determinado em tempo de compilação. O fluxo aqui é feito determinando o tipo do objeto invocador, em seguida gera código para avaliar e empilhar os argumentos e código para avaliar o objeto, trata objetos nulos (void), abortando a execução se necessário, carrega a tabela de despacho do objeto e determina o deslocamento do método e invoca o método usando um salto para a posição correspondente.

- Classe `cond`

O método `code` aqui implementa a geração de código para as estruturas condicionais de cool. Ele avalia uma expressão booleana e executa um dos dois blocos de código, dependendo se a condição avaliada é verdadeira ou falsa.

```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for conditional");
        int ifFalseLabel = CgenNode.getLabelCountAndIncrement();
        int ifTrueLabel = CgenNode.getLabelCountAndIncrement();
        int ifEndLabel = CgenNode.getLabelCountAndIncrement();
        //evaluate predicate
        pred.code(s, cgenTable);
        CgenSupport.emitLoadBool(CgenSupport.T1, BoolConst.truebool, s);
        //branch on predicate value
        CgenSupport.emitBeq(CgenSupport.ACC, CgenSupport.T1, ifTrueLabel, s);
        //if pred is false
        CgenSupport.emitLabelDef(ifFalseLabel, s);
        else_exp.code(s, cgenTable);
        CgenSupport.emitBranch(ifEndLabel, s);
        CgenSupport.emitLabelDef(ifTrueLabel, s);
        then_exp.code(s, cgenTable);
        CgenSupport.emitLabelDef(ifEndLabel, s);
        CgenSupport.emitComment(s, "Leaving cgen for conditional");

    }
```

O método segue o fluxo básico de uma instrução condicional que avalia o predicado, usa labels para ramificar o fluxo de execução com base no resultado do predicado, gera o código do bloco then se a condição for verdadeira, ou o bloco else se for falsa e garante que o controle continue após o bloco condicional, independentemente do caminho seguido.

- Classe `loop`

Esse método faz a tradução da lógica de um loop em código de máquina. Ele utiliza dois labels para controlar o fluxo. Um rótulo para o início do laço e um rótulo para o final do laço, quando a condição não for mais verdadeira.
```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for loop");
        //make two labels one for while loop and one for end of while loop
        int whileLabel = CgenNode.getLabelCountAndIncrement();
        int whileEndLabel = CgenNode.getLabelCountAndIncrement();
        //while loop label definition
        CgenSupport.emitLabelDef(whileLabel, s);
        //evaluate predicate
        pred.code(s, cgenTable);
        //load true boolean const
        CgenSupport.emitLoadBool(CgenSupport.T1, BoolConst.truebool, s);
        //check to see if predicate value is not equal to true
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.T1, whileEndLabel,s);
        //CgenSupport.emitLabelDef(whileLabel, s);
        //evaluate body
        body.code(s, cgenTable);
        CgenSupport.emitBranch(whileLabel,s);
        //end of while loop label
        CgenSupport.emitLabelDef(whileEndLabel, s);
        //CgenSupport.emitLoadImm(CgenSupport.ACC, 0, s);
        CgenSupport.emitComment(s, "Leaving cgen for loop");

    }
```

A execução se dá quando se define os rótulos whileLabel e whileEndLabel e gera código para avaliar a condição. Se a condição for falsa, desvia para o rótulo whileEndLabel. Se a condição for verdadeira, executa o corpo do laço e volta para whileLabel. Por fim, sai do laço quando a condição não for mais verdadeira. Importante ressaltar aqui o uso de rótulos, que são essenciais para controlar o fluxo de repetição e a saída do laço.

- Classe `typcase`

## Testes
