-- Declaration classes 
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

-- Operators 
class Math {
	f() : Int {
		{
			a+-c;
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

-- Ambiguity of Inheritance and Overwriting (Dispatch)---------------------------------------------------------------------------

class A {
	-- Testing if identifiers introduced by let hide any definitions for the same names in outer scopes
	testLet(: Int {
        let x : Int <- 5 in  -- x defined in the outer scope
        {
                let x : Int <- 10 in x;  -- Here, x is 10, the inner definition is used
                x;  -- Here, x is 5, the outer definition is used
        }
    };

	foo() : Int { 42 };
};

class B inherits A {
    foo() : Int { 100 }; 
    bar() : Int { foo() + 10 };
    test() : IO {
        let b : B <- new B in 
			b.bar()
    };
};


-- Main e (atribuicoes, loops e comparacoes) -----------------------------------------------------------------------


-- Functions --------------------------------------------------------------------------------------	
   print_stack(s : Stack) : Object {
      if s.head() = "-1" then (new IO).out_string("\nEnd\n")
    	else {
			   (new IO).out_string("\n");
			   (new IO).out_string(s.head());
			   s <- s.tail();
			   print_stack(s);
		}
      fi
   };

	c2i(char : String) : Int {
        	if char = "0" then 0 else
        	if char = "1" then 1 else
        	if char = "2" then 2 else
        	if char = "3" then 3 else
        	if char = "4" then 4 else
        	if char = "5" then 5 else
        	if char = "6" then 6 else
        	if char = "7" then 7 else
        	if char = "8" then 8 else
        	if char = "9" then 9 else
        	{ abort(); 0; } 
        	
       };


      i2c(i : Int) : String {
        	if i = 0 then "0" else
        	if i = 1 then "1" else
       		if i = 2 then "2" else
        	if i = 3 then "3" else
        	if i = 4 then "4" else
        	if i = 5 then "5" else
        	if i = 6 then "6" else
        	if i = 7 then "7" else
        	if i = 8 then "8" else
        	if i = 9 then "9" else
        	{ abort(); ""; }  
        	fi fi fi fi fi fi fi fi fi fi
     };
};
