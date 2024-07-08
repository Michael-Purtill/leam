module parse.types.apply;
import parse.types.ast;
import parse.types.lambda;
import scan.types.token;

class Apply : Expr {
  Lambda lambda;
  Token[] arguments;

  this(Lambda l, Token[] args) {
    lambda = l;
    arguments = args;
  }
}