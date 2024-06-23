module parse.types.ast;
import std.sumtype;
import scan.types.token : Token;
import std.format;
import std.conv;

struct BinaryType {}  // i + j, 1 + 3 - 2
struct LiteralType {} // 2, "string example"
struct UnaryType {}   // -1, -3, not (x == 2)
struct AssignmentType {} // id = 234
struct IDType {} // id, varName

alias ExprType = SumType!(BinaryType, LiteralType, UnaryType, IDType, AssignmentType);

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
    if (operands.length == 0) {
      return value.to!string;
    }

    if (operands.length == 1) {
      return "operator: %s, right: %s".format(operator.toString, operands[0].toString);
    }

    return "operator: %s, left: %s, right: %s".format(
      operator.toString,
      operands[0].toString,
      operands[1].toString);
  }
}
