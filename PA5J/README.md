# Compilador para a Linguagem COOL (Classroom Oriented-Object Language)

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Código](#código)
3. [Testes](#testes)

## Descrição do Projeto

## Código
### CgenClassTable.java

Esse código implementa a classe CgenClassTable, que lida com a estrutura de herança das classes Cool e participa na geração de código assembly para a execução do programa. Ela organiza as classes do programa em uma árvore de herança; gera tabelas de apoio para atributos, métodos e constantes; produz o código assembly necessário para inicializar classes e executar métodos e faz uso de outras classes auxiliares (CgenNode, SymbolTable e Cgen Support) para gerenciar a estrutura do compilador.


Na parte dos atributos podemos ressaltar:
- private Vector nds: representa uma lista de todas as classs do programa, armazenadas como nós (CgenNode) e cada CgenNode encapsula informações sobre uma classe e suas relações hierárquicos.
- private PrintStream str: fluxo de saída para o código final, usado para escrever o código assembly gerado.
- private int stringclasstag, intclasstag, boolclasstag: tags únicos atribuídos ás classes básicas (String, Int e Bool), usados para identificar essas classes durante a execução do programa. 
- private static Map<AbstractSymbol, Integer> classTagMap: um mapa que associa nomes de classes (AbstractSymbol) aos seus respectivos "tags" (números inteiros únicos).


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

 
Descrevendo alguns dos principais métodos:
- installBasicClasses(): cria as classes básicas necessárias para a execução de qualquer programa Cool.
    Classes instaladas:
        Object: Classe raiz de todas as classes.
            Métodos: cool_abort (encerra o programa), type_name (retorna o nome da classe), copy (faz uma cópia do objeto).
        IO: Subclasse de Object para entrada e saída.
            Métodos: out_string, out_int, in_string, in_int.
        Int: Classe para inteiros, com o atributo val.
        Bool: Classe para valores booleanos, com o atributo val.
        String: Classe para strings, com os atributos val (tamanho) e str_field (conteúdo).
            Métodos: length, concat, substr.
- installClass(CgenNode nd): adiciona um nó de classe (CgenNode) à tabela de classes. Verifica se a classe já existe na tabela (probe(name)). Se não existir, adiciona o nó ao vetor nds e ao escopo atual.
- installClasses(Classes cs): adiciona classes definidas pelo usuário à tabela de classes. Itera sobre as classes fornecidas em cs e chama installClass para cada uma delas.
- buildInheritanceTree(): constrói a árvore de herança relacionando classes pais e filhos. Itera sobre todos os nós em nds e chama setRelations para configurar as relações de herança.
- setRelations(CgenNode nd): configura as relações de herança de um nó de classe. Obtém a classe pai usando probe(nd.getParent()). Configura o pai do nó atual e adiciona o nó atual como filho do pai.
- code(): método principal para gerar o código assembly do programa.
    Etapas:
        Mapeamento de tags: Atribui tags únicos às classes em nds.
        Código global:
            codeGlobalData: Declara nomes globais e dados da memória.
            codeSelectGc: Configura o coletor de lixo (garbage collector).
            codeConstants: Gera o código para constantes (String, Int, Bool).
    Tabelas:
        Gera tabelas como class_nameTab (mapeamento de tags para nomes) e class_parentTab (mapeamento de classes para pais).
        Gera tabelas de atributos (attrTabTab) e de despachos (dispatch tables).
    Prototipos e inicialização:
        Gera protótipos de objetos.
        Gera código de inicialização de objetos (codeObjInit).
        Gera métodos das classes.
- codeGlobalData(): emite código para a seção .data (segmento de dados) e declara nomes globais.
- codeGlobalText(): emite código para a seção .text (segmento de texto) e inicializações globais.
- codeConstants(): gera código para constantes de string, inteiros e booleanos. Adiciona constantes necessárias ao programa (ex.: "" e 0). Gera tabelas de constantes para String e Int.
- codeBools(int classtag): gera código para os valores booleanos (true e false).
- codeSelectGc(): gera código para configurar o coletor de lixo, dependendo das flags do compilador.
- root(): retorna a classe raiz (Object) da árvore de herança.


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

        expr.code(s, cgenTable);

        int notVoidDispatchLabel = CgenNode.getLabelCountAndIncrement();
        CgenNode selfie = (CgenNode) cgenTable.lookup(TreeConstants.self);
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.ZERO, notVoidDispatchLabel, s);
        CgenSupport.emitLoadString(CgenSupport.ACC, (StringSymbol) selfie.getFilename(), s);
        CgenSupport.emitLoadImm(CgenSupport.T1, this.lineNumber, s);
        CgenSupport.emitJal("_dispatch_abort", s);
        CgenSupport.emitLabelDef(notVoidDispatchLabel, s);

        CgenSupport.emitLoadAddress(CgenSupport.T1, type_name + CgenSupport.DISPTAB_SUFFIX, s);
        CgenSupport.emitLoad(CgenSupport.T1, 2, CgenSupport.T1, s);
        c1.printMethodOffsets();
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
            exprType = CgenNode.getCurrentType();
        }
        CgenNode c1 = (CgenNode) cgenTable.lookup(exprType);
        CgenSupport.emitComment(s, "BEGIN dispatch for method "+name+ " in class " + exprType);

        for(Enumeration en = actual.getElements(); en.hasMoreElements(); ) {
            Expression tmp = (Expression) en.nextElement();
            CgenSupport.emitComment(s, "Evaluating and pushing argument of type "+tmp.get_type()+ " to current frame");
            tmp.code(s, cgenTable);
            CgenSupport.emitPush(CgenSupport.ACC,s);
            CgenSupport.emitComment(s, "Done pushing argument of type "+tmp.get_type()+ " to current frame");
        }

        expr.code(s, cgenTable);

        int notVoidDispatchLabel = CgenNode.getLabelCountAndIncrement();
        CgenNode selfie = (CgenNode) cgenTable.lookup(TreeConstants.self);
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.ZERO, notVoidDispatchLabel, s);
        CgenSupport.emitLoadString(CgenSupport.ACC, (StringSymbol) selfie.getFilename(), s);
        CgenSupport.emitLoadImm(CgenSupport.T1, this.lineNumber, s);
        CgenSupport.emitJal("_dispatch_abort",s);
        CgenSupport.emitLabelDef(notVoidDispatchLabel, s);


        CgenSupport.emitLoad(CgenSupport.T1, 2, CgenSupport.ACC, s);
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
        pred.code(s, cgenTable);
        CgenSupport.emitLoadBool(CgenSupport.T1, BoolConst.truebool, s);
        CgenSupport.emitBeq(CgenSupport.ACC, CgenSupport.T1, ifTrueLabel, s);
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
        int whileLabel = CgenNode.getLabelCountAndIncrement();
        int whileEndLabel = CgenNode.getLabelCountAndIncrement();
        CgenSupport.emitLabelDef(whileLabel, s);
        pred.code(s, cgenTable);
        CgenSupport.emitLoadBool(CgenSupport.T1, BoolConst.truebool, s);
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.T1, whileEndLabel,s);
        body.code(s, cgenTable);
        CgenSupport.emitBranch(whileLabel,s);
        CgenSupport.emitLabelDef(whileEndLabel, s);
        CgenSupport.emitComment(s, "Leaving cgen for loop");

    }
```

A execução se dá quando se define os rótulos whileLabel e whileEndLabel e gera código para avaliar a condição. Se a condição for falsa, desvia para o rótulo whileEndLabel. Se a condição for verdadeira, executa o corpo do laço e volta para whileLabel. Por fim, sai do laço quando a condição não for mais verdadeira. Importante ressaltar aqui o uso de rótulos, que são essenciais para controlar o fluxo de repetição e a saída do laço.

- Classe `typcase`

Este método é usado em linguagens orientadas a objetos, permitindo a execução baseada no tipo em tempo de execução.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        List<branch> caseList = new ArrayList<branch>();
        for (Enumeration e = cases.getElements(); e.hasMoreElements();) {
            branch c = (branch) e.nextElement();
            caseList.add(c);
        }

        CgenSupport.emitComment(s, "Entering cgen for case");

        expr.code(s, cgenTable);

        int notVoidDispatchLabel = CgenNode.getLabelCountAndIncrement();
        CgenNode selfie = (CgenNode) cgenTable.lookup(TreeConstants.self);
        CgenSupport.emitBne(CgenSupport.ACC, CgenSupport.ZERO, notVoidDispatchLabel, s);
        CgenSupport.emitLoadString(CgenSupport.ACC, (StringSymbol) selfie.getFilename(), s);
        CgenSupport.emitLoadImm(CgenSupport.T1, this.lineNumber, s);
        CgenSupport.emitJal("_case_abort2", s);
        CgenSupport.emitLabelDef(notVoidDispatchLabel, s);

        CgenNode c1 = (CgenNode) cgenTable.lookup(expr.get_type());
        int curr_tag = cgenTable.getTagId(c1.name);

        int caseBeginLabel = CgenNode.getLabelCountAndIncrement();
        int lubMatchLabel = CgenNode.getLabelCountAndIncrement();
        int noMatchLabel = CgenNode.getLabelCountAndIncrement();


        CgenSupport.emitLoadImm(CgenSupport.T1, curr_tag, s);
        CgenSupport.emitLabelDef(caseBeginLabel, s);
        CgenSupport.emitBeq(CgenSupport.T1, "-2", noMatchLabel, s);
        for(branch b : caseList){
            int next_branch_label = CgenNode.getLabelCountAndIncrement();
            int branch_tag = cgenTable.getTagId(b.type_decl);
            CgenSupport.emitLoadImm(CgenSupport.T2, branch_tag, s);
            CgenSupport.emitBne(CgenSupport.T1, CgenSupport.T2, next_branch_label, s);
            b.expr.code(s, cgenTable);
            CgenSupport.emitBranch(lubMatchLabel, s);
            CgenSupport.emitLabelDef(next_branch_label, s);
        }
        CgenSupport.emitLoadAddress(CgenSupport.T1, "class_parentTab", s);
        CgenSupport.emitLoad(CgenSupport.T1, curr_tag, CgenSupport.T1, s);
        CgenSupport.emitBranch(caseBeginLabel, s);

        CgenSupport.emitLabelDef(noMatchLabel, s);
        CgenSupport.emitJal("_case_abort", s);

        CgenSupport.emitLabelDef(lubMatchLabel, s);

        CgenSupport.emitComment(s, "leaving cgen for case");
    }
```
O código avalia a expressão base (expr), trata o caso de objeto null (chama _case_abort2 se necessário), determina o tipo do objeto avaliado, itera pelos ramos para encontrar um tipo correspondente, onde executa o código do ramo correspondente, ou tenta o tipo do pai se não houver correspondência, e aborta o programa (_case_abort) se nenhum ramo for encontrado.

- Classe `block`

O método implementa a geração de código para um bloco delimitado por {} em cool.
O valor do bloco como um todo é o valor da última expressão avaliada. O método traduz essa lógica em código.

```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for block");
        for (Enumeration e = body.getElements(); e.hasMoreElements(); ) {
            ((Expression) e.nextElement()).code(s, cgenTable);
        }
        CgenSupport.emitComment(s, "Leaving cgen for block");
    }
```

O método inicia com um comentário para rastreamento, onde ele itera sobre todas as expressões no bloco, avaliando cada expressão na ordem. Conclui com um comentário indicando o fim da geração de código para o bloco.

- Classe `let`

O método trata da geração de código para uma expressão let, onde uma variável local é criada, inicializada e utilizada dentro de um escopo específico. Ele possui os elementos essenciais para lidar com a inicialização da variável e seu armazenamento na pilha.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for let with identifier " + identifier);
        init.code(s, cgenTable);
        CgenSupport.emitPush(CgenSupport.ACC,s);
        int offsetLet = CgenSupport.WORD_SIZE*2;


        CgenSupport.emitComment(s, "Leaving cgen for let with identifier " + identifier);
    }
```

O código cria um novo escopo na tabela de símbolos, avaliando a expressão inicial.
Em seguida, usa um valor padrão (ex.: 0) se não houver inicialização explícita e empilha o valor avaliado para alocar espaço para a variável. Por fim, gera o código para o corpo do let, onde a variável inicializada pode ser usada, removendo a variável da pilha e encerrando o escopo.

- Classe `plus`

Este método implementa a geração de código para uma operação de adição. Ele processa dois operandos (e1 e e2), realiza a operação de soma e armazena o resultado em um novo objeto inteiro, usando um modelo de heap para gerenciar números inteiros encapsulados.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for addition");
        e1.code(s, cgenTable);
        CgenSupport.emitPush(CgenSupport.ACC, s);

        e2.code(s, cgenTable);

        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);

        CgenSupport.emitLoad(CgenSupport.T1, 1, CgenSupport.SP, s);

        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.T1, s);
        CgenSupport.emitLoad(CgenSupport.T2, 3, CgenSupport.ACC, s);


        CgenSupport.emitAdd(CgenSupport.T1, CgenSupport.T1, CgenSupport.T2, s);

        CgenSupport.emitStore(CgenSupport.T1, 3, CgenSupport.ACC, s);

        CgenSupport.emitAddiu(CgenSupport.SP, CgenSupport.SP, 4, s);
        CgenSupport.emitComment(s, "Leaving cgen for addition");
    }

```

A execução se dá da seguinte forma:
Avalia e1 e empilha o valor na pilha, avalia e2 e mantém o resultado em $a0, cria um novo objeto inteiro para armazenar o resultado, recupera os valores inteiros de e1 (da pilha) e e2 ($a0), realiza a soma dos dois valores inteiros, armazena o resultado no novo objeto inteiro e libera o espaço usado na pilha para e1.

- Classe `sub`

O `sub` implementa a geração de código para uma operação de subtração no contexto de um compilador orientado a objetos. Assim como na adição, ele trabalha com números representados como objetos, o que requer extração, manipulação e armazenamento dos valores numéricos dentro desses objetos.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for subtract");
        e1.code(s, cgenTable);
        CgenSupport.emitPush(CgenSupport.ACC, s);

        e2.code(s, cgenTable);

        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);

        CgenSupport.emitLoad(CgenSupport.T1, 1, CgenSupport.SP, s);

        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.T1, s);
        CgenSupport.emitLoad(CgenSupport.T2, 3, CgenSupport.ACC, s);

        CgenSupport.emitSub(CgenSupport.T1, CgenSupport.T1, CgenSupport.T2, s);

        CgenSupport.emitStore(CgenSupport.T1, 3, CgenSupport.ACC, s);

        CgenSupport.emitAddiu(CgenSupport.SP, CgenSupport.SP, 4, s);
        CgenSupport.emitComment(s, "Leaving cgen for subtract");
    }
```

O fluxo é parecido, dado pela avaliação de e1 e e2, criação um novo objeto para armazenar o resultado, extração dos valores inteiros de e1 (da pilha) e e2 (de $a0), subtração (e1 - e2) e armazenamento do resultado no novo objeto e por fim libera o espaço reservado para e1 na pilha.

- Classe `mul`

Aqui é implementada a geração de código para uma operação de multiplicação no contexto de um compilador que trata números como objetos. Ele segue um padrão semelhante aos métodos para soma e subtração, ajustando a operação aritmética para multiplicação.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for multiply");
        e1.code(s, cgenTable);
        CgenSupport.emitPush(CgenSupport.ACC, s);

        e2.code(s, cgenTable);

        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);

        CgenSupport.emitLoad(CgenSupport.T1, 1, CgenSupport.SP, s);

        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.T1, s);
        CgenSupport.emitLoad(CgenSupport.T2, 3, CgenSupport.ACC, s);


        CgenSupport.emitMul(CgenSupport.T1, CgenSupport.T1, CgenSupport.T2, s);

        CgenSupport.emitStore(CgenSupport.T1, 3, CgenSupport.ACC, s);

        CgenSupport.emitAddiu(CgenSupport.SP, CgenSupport.SP, 4, s);
        CgenSupport.emitComment(s, "Leaving cgen for multiply");
    }
```

O fluxo avalia e1 e empilha o resultado, avalia e2 e mantém o resultado em $a0, cria um novo objeto para armazenar o resultado da multiplicação, extrai os valores inteiros de e1 (da pilha) e e2 (de $a0), realiza a operação de multiplicação (e1 * e2) e armazena o resultado no novo objeto e libera o espaço na pilha usado por e1.

- Classe `divide`

O método abaixo implementa a geração de código para uma operação de divisão no contexto de um compilador cool. Ele segue um padrão semelhante às outras operações aritméticas (soma, subtração, multiplicação), ajustando a operação para divisão.

```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for divide");
        e1.code(s, cgenTable);
        CgenSupport.emitPush(CgenSupport.ACC, s);

        e2.code(s, cgenTable);

        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);

        CgenSupport.emitLoad(CgenSupport.T1, 1, CgenSupport.SP, s);

        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.T1, s);
        CgenSupport.emitLoad(CgenSupport.T2, 3, CgenSupport.ACC, s);

        CgenSupport.emitDiv(CgenSupport.T1, CgenSupport.T1, CgenSupport.T2, s);

        CgenSupport.emitStore(CgenSupport.T1, 3, CgenSupport.ACC, s);

        CgenSupport.emitAddiu(CgenSupport.SP, CgenSupport.SP, 4, s);
        CgenSupport.emitComment(s, "Leaving cgen for divide");
    }
```

Como o método é semelhante, o fluxo também é semelhante sendo dado quando avalia e1 e empilha o resultado, avalia e2 e mantém o resultado em $a0, cria um novo objeto para armazenar o resultado da divisão, extrai os valores inteiros de e1 (da pilha) e e2 (de $a0), realiza a operação de divisão (e1 / e2) e armazena o resultado no novo objeto e Libera o espaço na pilha usado por e1.

- Classe `neg`

O método implementa a geração de código para uma operação de negação aritmética (como -x). Ele inverte o valor de um número inteiro representado como um objeto, criando um novo objeto com o valor negado.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entering cgen for negate");
        e1.code(s, cgenTable);

        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);
        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.ACC, s);
        CgenSupport.emitNeg(CgenSupport.T1, CgenSupport.T1, s);
        CgenSupport.emitStore(CgenSupport.T1, 3, CgenSupport.ACC, s);
        CgenSupport.emitComment(s, "Leaving cgen for negate");
    }
```

Resumidamente, ele avalia e1 e mantém o resultado em $a0, cria um novo objeto inteiro para armazenar o resultado da negação, extrai o valor numérico de e1 do objeto, realiza a operação de negação aritmética (-x) e armazena o valor negado no novo objeto.

- Classe `lt`

Aqui implementa-se a geração de código para a operação de comparação "menor que" (<) entre duas expressões em uma linguagem do compilador cool. A operação é realizada considerando que os operandos são objetos inteiros, e o resultado é um valor booleano (true ou false), representando se o primeiro operando é menor que o segundo.

```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entering cgen for less than");
        e1.code(s, cgenTable);
        CgenSupport.emitMove(CgenSupport.T1, CgenSupport.ACC, s);
        e2.code(s, cgenTable);

        int labelCountTrue = CgenNode.getLabelCountAndIncrement();
        int labelCountFalse = CgenNode.getLabelCountAndIncrement();
        int labelCountEnd = CgenNode.getLabelCountAndIncrement();

        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.T1, s);
        CgenSupport.emitLoad(CgenSupport.ACC, 3, CgenSupport.ACC, s);

        CgenSupport.emitBlt(CgenSupport.T1, CgenSupport.ACC, labelCountTrue, s);
        CgenSupport.emitLabelDef(labelCountFalse, s);
        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.falsebool,s);
        CgenSupport.emitBranch(labelCountEnd, s);
        CgenSupport.emitLabelDef(labelCountTrue,s);
        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.truebool,s);
        CgenSupport.emitLabelDef(labelCountEnd, s);
        CgenSupport.emitComment(s, "Leaving cgen for less than");
    }
```

Esse código avalia as expressões e1 e e2, movendo e1 para um registrador temporário ($T1), acessa os valores inteiros de e1 e e2 e realiza a comparação e1 < e2. Se e1 < e2, retorna true. Caso contrário, retorna false.

- Classe `eq`

O método abaixo implementa a geração de código para a operação de igualdade (==). Ele avalia duas expressões (e1 e e2) e determina se elas são iguais. A operação utiliza uma função auxiliar chamada equality_test para realizar a comparação, retornando um valor booleano (true ou false).

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entering cgen for equal to");

        int equalLabel = CgenNode.getLabelCountAndIncrement();

        e1.code(s, cgenTable);
        CgenSupport.emitMove(CgenSupport.T1, CgenSupport.ACC, s);
        e2.code(s, cgenTable);
        CgenSupport.emitMove(CgenSupport.T2, CgenSupport.ACC, s);

        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.truebool, s);
        CgenSupport.emitLoadBool(CgenSupport.A1, BoolConst.falsebool, s);
        CgenSupport.emitJal("equality_test", s);

        CgenSupport.emitLabelDef(equalLabel, s);

        CgenSupport.emitComment(s, "Leaving cgen for equal to");
    }
```

Ele avalia e1 e move o resultado para um registrador temporário (T1), avalia e2 e move o resultado para outro registrador temporário (T2). Após isso, carrega os valores booleanos true e false nos registradores apropriados ($ACC e $A1) e invoca a função equality_test para comparar os dois valores, além de definir um rótulo para a saída da operação e garantir que o valor booleano final esteja em $ACC.

- Classe `leq`

O método implementa a geração de código para a operação "menor ou igual a" (<=). Ele avalia duas expressões (e1 e e2), compara seus valores numéricos e retorna true ou false como resultado.

```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entering cgen for less than or equal to");
        e1.code(s, cgenTable);
        CgenSupport.emitMove(CgenSupport.T1, CgenSupport.ACC, s);
        e2.code(s, cgenTable);

        int labelCountTrue = CgenNode.getLabelCountAndIncrement();
        int labelCountFalse = CgenNode.getLabelCountAndIncrement();
        int labelCountEnd = CgenNode.getLabelCountAndIncrement();

        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.T1, s);
        CgenSupport.emitLoad(CgenSupport.ACC, 3, CgenSupport.ACC, s);

        CgenSupport.emitBleq(CgenSupport.T1, CgenSupport.ACC, labelCountTrue, s);
        CgenSupport.emitLabelDef(labelCountFalse, s);
        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.falsebool,s);
        CgenSupport.emitBranch(labelCountEnd, s);
        CgenSupport.emitLabelDef(labelCountTrue,s);
        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.truebool,s);
        CgenSupport.emitLabelDef(labelCountEnd, s);
        CgenSupport.emitComment(s, "Leaving cgen for less than or equal to");
    }
```

Aqui é avaliado e1 e armazenado o valor no registrador temporário $T1 e também avalia e2 e armazena o valor em $ACC.Depois de extrair os valores numéricos das expressões (armazenados como objetos inteiros), realiza a comparação e1 <= e2 usando o comando de salto condicional bleq (branch if less than or equal).Além disso, usa rótulos para organizar o controle de fluxo:
labelCountTrue: Caso a comparação seja verdadeira.
labelCountFalse: Caso a comparação seja falsa.
labelCountEnd: Ponto final da operação.

- Classe `comp`

O método implementa a geração de código para a operação lógica de negação (not). Ele inverte o valor booleano de uma expressão (true se torna false e vice-versa).

```
public void code(PrintStream s, CgenClassTable cgenTable) {

        CgenSupport.emitComment(s, "Entered cgen for not");
        e1.code(s, cgenTable);
        CgenSupport.emitLoad(CgenSupport.T1, 3, CgenSupport.ACC, s);
        CgenSupport.emitLoadImm(CgenSupport.T2, 1, s);

        int labelCountTrue = CgenNode.getLabelCountAndIncrement();
        int labelCountFalse = CgenNode.getLabelCountAndIncrement();
        int labelCountEnd = CgenNode.getLabelCountAndIncrement();

        CgenSupport.emitBeq(CgenSupport.T1, CgenSupport.T2, labelCountTrue, s);
        CgenSupport.emitLabelDef(labelCountFalse, s);
        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.truebool, s);
        CgenSupport.emitBranch(labelCountEnd, s);
        CgenSupport.emitLabelDef(labelCountTrue,s);
        CgenSupport.emitLoadBool(CgenSupport.ACC, BoolConst.falsebool, s);

        CgenSupport.emitLabelDef(labelCountEnd,s);

        CgenSupport.emitComment(s, "Leaving cgen for not");
    }
```

Aqui ele avalia a expressão e1 para determinar seu valor booleano, verifica o valor de e1 (true ou false) e inverte o valor. Se e1 for true, o resultado será false, se e1 for false, o resultado será true.
Abaixo, os rótulos usados para controle de fluxo:
labelCountTrue: Define o comportamento para o caso em que e1 é true.
labelCountFalse: Define o comportamento para o caso em que e1 é false.
labelCountEnd: Marca o final da operação.

- Classe `int_const`

Já esse método implementa a geração de código para uma constante inteira em cool. O objetivo é carregar uma constante inteira previamente definida (como 5 ou 42) no registrador acumulador ($ACC).

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for int const expression");
        CgenSupport.emitLoadInt(CgenSupport.ACC,
                (IntSymbol)AbstractTable.inttable.lookup(token.getString()), s);
        CgenSupport.emitComment(s, "Leaving cgen for int const expression");
    }
```

Seu fluxo consiste basicamente na busca na Tabela de Símbolos, localizando o símbolo associado ao valor da constante inteira e carregando o objeto constante no acumulador ($ACC).Por fim adiciona comentários para marcar o início e o fim do processo.

- Classe `bool_const`

Nesse método é implementado a geração de código para uma constante booleana (true ou false) para cool. O objetivo é carregar o valor booleano especificado no registrador acumulador ($ACC).

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for bool const expression");
        CgenSupport.emitLoadBool(CgenSupport.ACC, new BoolConst(val), s);
        CgenSupport.emitComment(s, "Leaving cgen for bool const expression");
    }
```

Ele instancia um objeto BoolConst com base no valor de val, carrega o objeto booleano correspondente (true ou false) no acumulador ($ACC) e adiciona comentários para facilitar a depuração.

- Classe `string_const`

Aqui foi implementado a geração de código para uma constante de string em cool. O objetivo é localizar ou criar um objeto representando a string na tabela de símbolos de strings (stringtable) e carregá-lo no registrador acumulador ($ACC).
```
    public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for string const expression");
        CgenSupport.emitLoadString(CgenSupport.ACC,
                (StringSymbol)AbstractTable.stringtable.lookup(token.getString()), s);
        CgenSupport.emitComment(s, "Leaving cgen for string const expression");
    }
```

O que foi feito foi a adição de comentários para indicar que o código gerado é para uma expressão constante de string, a busca da string literal na tabela de símbolos de strings usando o valor fornecido por token.getString() e a carga do objeto associado à string no registrador acumulador ($ACC).

- Classe `new_`

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for new");
        CgenSupport.emitLoadAddress(CgenSupport.ACC, this.type_name.toString()+"_protObj", s);
        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);
        CgenSupport.emitJal(this.type_name.toString()+"_init", s);
        CgenSupport.emitComment(s, "Leaving cgen for new");
    }
```

- Classe `isvoid`

O `isvoid` implementa a geração de código para a criação de um novo objeto em cool. A instrução new cria uma nova instância de uma classe, inicializa seus atributos e retorna o objeto no registrador acumulador ($ACC).

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for new");
        CgenSupport.emitLoadAddress(CgenSupport.ACC, this.type_name.toString()+"_protObj", s);
        CgenSupport.emitJal(CgenSupport.OBJECT_DOT_COPY, s);
        CgenSupport.emitJal(this.type_name.toString()+"_init", s);
        CgenSupport.emitComment(s, "Leaving cgen for new");
    }
```

Seu caminho para geração se dá quando o método localiza o protótipo do objeto (_protObj) correspondente à classe type_name, usa OBJECT_DOT_COPY para criar uma nova instância com a estrutura básica do protótipo, chama o método _init da classe para configurar os atributos do objeto e o objeto inicializado é armazenado no acumulador ($ACC).

- Classe `no_expr`

Já o método `no_expr` implementa a geração de código para uma expressão vazia ou "sem expressão" para a linguagem cool. O objetivo é lidar com casos onde uma expressão válida não é fornecida, garantindo que o programa tenha um comportamento consistente e sem erros.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered and exited cgen for no expression");
        CgenSupport.emitMove(CgenSupport.ACC, CgenSupport.ZERO, s);
    }
```
O método indica que uma expressão "vazia" foi processada e armazena 0 no acumulador ($ACC) para indicar a ausência de um valor.
O valor 0 no acumulador ($ACC) garante que o programa tenha um estado consistente, mesmo na ausência de uma expressão válida. O método é direto e eficiente, projetado para lidar com casos onde uma expressão é omitida e pode ser usado em vários contextos onde uma "não expressão" pode aparecer, como em blocos ou declarações de inicialização.

- Classe `object`
- 
Este método implementa a geração de código para o acesso a um objeto identificado por name, seja ele o próprio objeto self, um atributo da classe atual, ou uma variável local em um contexto de execução. Ele decide onde o objeto está localizado e gera o código necessário para carregá-lo no registrador acumulador ($ACC). Caso o objeto não seja self, o código verifica onde ele está armazenado.

```
public void code(PrintStream s, CgenClassTable cgenTable) {
        CgenSupport.emitComment(s, "Entered cgen for object: "+name);
        if(this.name.equals(TreeConstants.self)){
            CgenSupport.emitMove(CgenSupport.ACC,CgenSupport.SELF, s);
        }else {
            if(cgenTable.probe(this.name) == null) {
                Object lookUpSelf = cgenTable.lookup(TreeConstants.self);
                CgenNode nd = (CgenNode) lookUpSelf;
                int attrOffset = CgenNode.attrOffsetMap.get(nd.name).get(name);
                CgenSupport.emitLoad(CgenSupport.ACC, (2+attrOffset), CgenSupport.SELF, s);
            } else {
                int frameOffset = (Integer) cgenTable.probe(name) + 1;
                CgenSupport.emitLoad(CgenSupport.ACC, frameOffset, CgenSupport.FP, s);
            }
        }
        CgenSupport.emitComment(s, "Exited cgen for object");
    }
```
Para o fluxo desse método code, o primeiro passo é verificar se o objeto é `self`. Se o objeto for self, carrega o registrador SELF no acumulador ($ACC) caso não seja self, calcula o deslocamento do atributo na tabela de atributos e carrega seu valor. Se for uma variável local, calcula o deslocamento na pilha e carrega seu valor. Por fim, adiciona comentários indicando o início e o fim da operação.

## Testes
