class Test {
    testMethod() : Int {
        (5 + 3;
        10;
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
    }
};

class NamedClass {
    method() : Int {
        0;
    }
};

class TypeError {
    test() : Int {
        let x : String <- 10 in x;
    }
};

class MethodError {
    badMethod() : Int { 
        0;
    }

    missingReturnTypeMethod() : Int {
        5;
    }
};

class AssignmentError {
    assignTest() : Int {
         y <- 10;
         x <- 5;
    }
};

class NewError {
    createObject() : Object {
        new Object;
    }
};

class SequenceError {
    sequenceTest() : Int {
        5;
        10;
    }
};

class CaseError {
    caseTest() : Int {
        case x of
        0 : 0;
        esac;
    }
};

class LetError {
    letTest() : Int {
        let x : Int <- 5 in x;
        let y : Int <- 1 in y + 1;
    }
};

class ReservedWordError {
    test() : Int {
        let myClass : Int <- 5 in myClass;
    }
};

class HashSymbol {
    hstest() : Int{
           x : Int;  #
    }
};
