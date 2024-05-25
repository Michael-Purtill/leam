import std.stdio;
import scan.scan;
import scan.types.token;
import parse.parse;
import parse.types.ast;
import interpret.interpret : interpret;

void main()
{
	string testCode = "
    16 + 25 * 2.22 - 3 / 2 * 22
  ";

  Token[] tokens = scanner(testCode.dup);

  Expr ast = new Parser(tokens).parse();

  writeln(interpret(ast));

  return;
}
