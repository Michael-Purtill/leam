module parse.types.lambda;
import parse.types.ast;
import scan.types.token;
import parse.parse;

class Lambda : Expr {
  Expr[] exprs;
  Token[] parameters;

  this(Token[] params, Token[] code) {
    parameters = params;
    exprs = (new Parser(code)).parse();
  }

  
}