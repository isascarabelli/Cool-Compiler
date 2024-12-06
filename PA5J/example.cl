-- Classes para Teste de SELF_TYPE
class A {
    x : SELF_TYPE;
    init() : Object { x <- new SELF_TYPE };
    foo() : Int { 1 };
    getx() : A { x };
};

class B inherits A {
    foo() : Int { 2 };
};

-- Classes relacionadas ao analisador sintático

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

-- Ambiguity of Inheritance and Overwriting (Dispatch)---------------------------------------------------------------------------

class A {
	-- Testing if identifiers introduced by let hide any definitions for the same names in outer scopes
	testLet() : Int {
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

-- Classe principal com funcionalidades de teste
class Main inherits IO {
    ch : String;
    p : String;
    q : String;
    n : Int;
    m : Int;
    result : Int;
    nil : Stack;
    stack : Stack <- new Stack.init("-1", nil);

    (* Funcao exponenciacao recursiva *)
	exp(b : Int, x : Int) : Int {
		if (x = 0)
		then
		1
		else
		if (x = (2 * (x / 2)))
		then
			let y : Int <- exp(b, (x / 2)) in
			y * y
		else
			b * exp(b, x - 1)
		fi
		fi
	};

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
        	fi fi fi fi fi fi fi fi fi fi
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

    main(): Object {
    {
        (* Print exponenciacao - Teste Tipo Int *)
        let s : String <- "this is a" in {
            out_int(s.length());
            out_string("\n".concat(s.concat(" string\n")));
            out_string(s.substr(5, 2).concat("\n"));
        };

        (* Print exponenciacao - Teste Tipo Int *)
        out_int(exp(2, 7));
        out_string("\n");
        out_int(exp(3, 6));
        out_string("\n");
        out_int(exp(8, 3));
        out_string("\n");

       (* Grande expressao - Teste Tipo Int *)
        let x:Int <- 5 in {
			out_int((x <- 1) + ((x <- x+1) 
					+ (3 + (4 + (5 + (6 + (7+ (x+6))))))));
		};

        (* Objetos e variáveis Booleanas - Teste Tipo Bool *)
		let
			t:Bool <- true,
			f:Bool <- false,
			t1:Object <- t,
			t2:Object <- true,
			f1:Object <- f,
			f2:Object <- false,
			b1:Bool,
			b2:Object,
			io:IO <- new IO
		in {
			io.out_string("t: ");
			io.out_string(t.type_name());
			io.out_string("\n");

			b1 <- t;
			io.out_string("b1: ");
			io.out_string(b1.type_name());
			io.out_string("\n");

			b2 <- t1;
			io.out_string("b2: ");
			io.out_string(b2.type_name());
			io.out_string("\n");

			b1 <- f.copy();
			io.out_string("b1: ");
			io.out_string(b1.type_name());
			io.out_string("\n");

			b2 <- f2.copy();
			io.out_string("b2: ");
			io.out_string(b2.type_name());
			io.out_string("\n");
		};

        (* Teste Tipo SELF_TYPE *)

		let a:A <- new B in { 
			a.init();
			out_int(a.getx().foo());
		};
		out_string("\n");

        -- Teste com pilha
{
			ch <- (new IO).in_string();

			while not (ch = "x") loop  
            {
				-- checking if-then-else inside if-then-else structure
               if ch = "e" then {
					if stack.head() = "-1" then "Do Nothing" 
					else {
						ch <- stack.head();
						stack <- stack.tail();

						if ch = "+" then
						{
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
						if ch = "s" then
							{
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
               
			    ch <- (new IO).in_string();  
            } pool;
		}
};
