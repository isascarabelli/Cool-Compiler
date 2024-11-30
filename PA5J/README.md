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
- Gerenciamento da Árvore de Herança

- Gerenciamento de Tabelas

- Geração de Código Assembly

- Função Principal


## Testes
