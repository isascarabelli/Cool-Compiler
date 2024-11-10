class TypeMismatch {
    x : Int <- "Isso é uma String";
};

class CyclicInheritance inherits CyclicInheritance {};

class Market {
    foodCode(x : Int) : Int { x + 1 };
};

class MarketSector inherits Market {
    foodCode(x : String) : String { "secao de verduras"};
};

class PrimitiveInheritance inherits String {};

class Main inherits UndefinedClass {  
    main(): Int { 0 };
};

class DuplicateClasses {
    foo(): Int { 0 };
};

class DuplicateClasses {  
    bar(): Int { 1 };
};

class DuplicateMethods {
    foo(): Int { 0 };
    foo(): Int { 1 };  
};

class ReservedIdentifiers {
    self: Int <- 0;  
};
