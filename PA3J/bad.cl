class HashSymbol {
           x : Int;  #
};

class Test {
    testMethod() : Int {
                {  
(5 + 3;
        10;
   }
                    
    }
};

class ControlFlow {
    controlTest() : Int {
        if true then 5;
        while true loop 10;
    }
};

class IncompleteExpressions {
    incomplete() : Int {
        5 +- 2;
        2 * ;
        3;
    };
};

class {
    method() : Int {
        0;
    }
};

class TypeError {
    test() : Stringabc oi {
        let x : Stri <- 10 in x;
    }
};

class MethodError {
    badMethod() : Int { 
        0;
    }

    missingReturnTypeMethod() : {
        5;
    }
};

class AssignmentError {
    assignTest() : Int {
         y <- 10;
         x <= 5;
    }
};

class NewError {
    createObject() : Object {
        new;
    }
};

class SequenceError {
    sequenceTest() : Int {
        5
        10;
    }
};

class CaseError {
    caseTest() : Int {
        case x of
        0 : 0;
    }
};

class LetError {
    letTest() : Int {
        let x : Int in x
        let y in y + 1;  
    }
};

class ReservedWordError {
    test() : Int {
        let let : Int <- 5 in let
    };
};
