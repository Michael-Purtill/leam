module parse.types.ast;
import std.sumtype;
import scan.types.token : Token;

struct BinaryType {} // i + j, 1 + 3 - 2
struct LiteralType {} // 2, "string example"
struct UnaryType {} // -1, -3, not (x == 2)

alias ExprType = SumType!(BinaryType, LiteralType, UnaryType);

alias Literal = SumType!(string, int, float, bool);

class Expr {
  Token operator;
  Expr[] operands;
  Literal value;
  ExprType type;

  this(Token o, Expr[] ops, Literal l, ExprType t) {
    operator = o;
    operands = ops;
    value = l;
    type = t;
  }

  override string toString() const @safe {
    return "";
  }
}