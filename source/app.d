import std.stdio;
import scan.scan;
import scan.types.token;
import parse.parse;
import parse.types.ast;
import interpret.interpret : interpret;

void main()
{
	string testCode = "
    2 + 2
    
    3 + 3
  ";

  Token[] tokens = scanner(testCode.dup);

  Expr[] statements = new Parser(tokens).parse();

  foreach (Expr statement; statements) {
    writeln(interpret(statement));
  }

  // Expr ast = new Parser(tokens).parse();

  // writeln(interpret(ast));

  return;
}
