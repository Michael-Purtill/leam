module interpret.interpret;
import parse.types.ast;
import std.sumtype;

Literal parseLiteral(Expr expr) {
  return expr.value;
}

Literal parseBinary(Expr expr) {
  return expr.value;
}

Literal parseUnary(Expr expr) {
  return expr.value;
}

Literal parseGrouping(Expr expr) {
  return expr.value;
}

Literal interpret(Expr expr) {
  ExprType type = expr.type;

  return type.match!(
    (LiteralType _) => parseLiteral(expr),
    (BinaryType _) => parseBinary(expr),
    (UnaryType _) => parseUnary(expr),
    (GroupingType _) => parseGrouping(expr)
  );
}