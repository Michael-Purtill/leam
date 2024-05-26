import std.stdio;
import scan.scan;
import scan.types.token;
import parse.parse;
import parse.types.ast;
import interpret.interpret : interpret;

void main()
{
	string testCode = "
    ((25 + 10) * 2) / 2
  ";

  Token[] tokens = scanner(testCode.dup);

  Expr ast = new Parser(tokens).parse();

  writeln(interpret(ast));

  return;
}
