
(* Classes Teste SELF_TYPE *)

class A {
	x:SELF_TYPE;
	init():Object { x <- new SELF_TYPE };
	foo():Int { 1 };
	getx():A { x };
};

class B inherits A {
	foo():Int { 2 };
};

class Main inherits IO{

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

	(* Declaracao variavel para concatenacao *)
	s : String <- "this is a";

  main():Object {
	{
		(* Concatenacao - Teste Tipo String *)
		out_int(s.length());
		out_string("\n".concat(s.concat(" string\n")));
		out_string(s.substr(5, 2).concat("\n"));

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

    }
  };
};