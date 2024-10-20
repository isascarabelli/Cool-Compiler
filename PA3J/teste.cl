class Main {
    main() : Int {
        let t : Test <- new Test in {
            t.testMethod();
        };

        let cf : ControlFlow <- new ControlFlow in {
            cf.controlTest();
        };

        let ie : IncompleteExpressions <- new IncompleteExpressions in {
            ie.incomplete();
        };

        let nc : NamedClass <- new NamedClass in {
            nc.method();
        };

        let te : TypeError <- new TypeError in {
            te.test();
        };

        let me : MethodError <- new MethodError in {
            me.badMethod();
            me.missingReturnTypeMethod();
        };

        let ae : AssignmentError <- new AssignmentError in {
            ae.assignTest();
        };

        let ne : NewError <- new NewError in {
            ne.createObject();
        };

        let se : SequenceError <- new SequenceError in {
            se.sequenceTest();
        };

        let ce : CaseError <- new CaseError in {
            ce.caseTest();
        };

        let le : LetError <- new LetError in {
            le.letTest();
        };

        let rw : ReservedWordError <- new ReservedWordError in {
            rw.test();
        };

        let hs : HashSymbol <- new HashSymbol in {
            hs.hstest();  
        };

        0;
    }
};

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
