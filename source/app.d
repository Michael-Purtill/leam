import std.stdio;
import scan.scan;
import scan.types.token;
import parse.parse;
import parse.types.ast;
import interpret.interpret;

void main()
{
	string testCode = "
    fn x y z do 2 + 2 end
  ";

  Token[] tokens = scanner(testCode.dup);

  Expr[] statements = new Parser(tokens).parse();

  foreach (Expr key; statements) {
    writeln(key);
  }

  // Evaluator evaluator = new Evaluator(statements);

  // evaluator.evaluate();

  return;
}
