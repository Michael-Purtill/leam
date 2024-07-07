module parse.types.lambda;
import parse.types.ast;
import scan.types.token;
import parse.parse;
import std.array;

class Lambda : Expr {
  Expr[] exprs;
  Token[] parameters;

  this(Token[] params, Token[] code) {
    parameters = params;
    exprs = (new Parser(code)).parse();
  }

  override string toString() const @safe {
    string[] exprStrings = null;

    foreach (ref expr; exprs) {
      exprStrings ~= expr.toString();
    }

    return join(exprStrings, '\n');
  }
}