import std.stdio;
import scan.scan;
import scan.types.token;
import parse.parse;
import parse.types.ast;
import interpret.interpret;

void main()
{
	string testCode = "
    x = 2
    x >= 3
  ";

  Token[] tokens = scanner(testCode.dup);

  Expr[] statements = new Parser(tokens).parse();

  Evaluator evaluator = new Evaluator(statements);

  evaluator.evaluate();

  return;
}
