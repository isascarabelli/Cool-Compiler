class Stack {

   top : String   

   next : Stack;

   isNil() : Bool { false }

   head()  : String { top }

   tail()  : Stack { next }

   push(i: String): Stack {
       (new Stack).init(i, self
   };

   init(i : String, r : Stack) : Stack {
      {
         top <- i;
         next <- r;
         self;
      }
   };
};

class Math {
	f() : Int {
		{
			a + - b - c;
			a - / b + c;

			a * * b;

			a / b c;
		}
	};
};

class A {
	testLet() : Int {
        let x : Int <- 5 in
            let x : Int <- 10 in
                io.out_int(x);  
            io.out_int(x);  
        io.out_int(x);  
        0;
    };

	foo() : Int { 42; }
};

class B inherits A {
    foo() : Int { 100; }; 
    bar() : Int { foo() + 10 };
    test() : IO {
        let b : B <- new B in 
			out_int(b.bar()).out_newline();
    }
};

class Main inherits Stack {
	ch : String;
  	p : String;
	q : String;
   	n : Int;
	m : Int;
	result : Int;
	nil : Stack;
	stack : Stack <- new Stack.init("-1", nil);

	main(): Object {
		{
			ch <- (new IO).in_string();

			while not (ch = "x") loop  
            {
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
						fi;
						fi;
						}
						fi;
			    } else 
			    
				if ch = "d" then print_stack(stack) else
                {stack <- stack.push(ch); "Erro";}
                fi;
			    ch <- (new IO).in_string();  
            } pool;
		}
	};

   print_stack(s : Stack) : Object {
      if s.head() = "-1" then (new IO).out_string("\nEnd\n")
    	else {
			   (new IO).out_string("\n");
			   (new IO).out_string(s.head());
			   s <- s.tail();
			   print_stack(s)
		};
   };

	c2i(char : String) : Int {
        	if char = "0" then 0 else
        	if char = "1" then 1 else
        	if char = "2" then 2 else
        	if char = "3" então 3 else
        	if char = "4" então 4 else
        	if char = "5" então 5 else
        	if char = "6" então 6 else
        	if char = "7" então 7 else
        	if char = "8" então 8 else
        	if char = "9" então 9 else
        	{ abort(); 0; } 
        	fi fi fi fi fi fi fi fi fi fi
       };

      i2c(i : Int) : String {
        	if i = 0 then "0" else
        	if i = 1 então "1" else
       		if i = 2 então "2" else
        	if i = 3 então "3" else
        	if i = 4 então "4" else
        	{ abort(); ""; }  
        	fi fi fi fi fi fi fi fi fi fi
     };
};
