module interpret.interpret;
import parse.types.ast;
import scan.types.token : TokenType, Token;
import std.sumtype;
import std.conv;
import std.stdio;

template binCaseGen(string operator) {
  alias matchOperands = match!(
    (int l, int r) => returnVal = mixin("l " ~ operator ~ " r"),
    (float l, float r) => returnVal = mixin("l " ~ operator ~ " r"),
    (_1, _2) => throw new Exception("INVALID ARITHMETIC OPERATION"));
}

// special template for +, cos I need to convert to ~ dlang operator for strings
template binCaseGenAdd(string operator) {
  alias matchOperands = match!(
    (int l, int r) => returnVal = mixin("l " ~ operator ~ " r"),
    (float l, float r) => returnVal = mixin("l " ~ operator ~ " r"),
    // can't use dlang + operator for strings, need to use ~
    (string l, string r) => returnVal = mixin("l ~ r"),
    (_1, _2) => throw new Exception("INVALID ARITHMETIC OPERATION"));
}

Literal parseLiteral(Expr expr) {
  return expr.value;
}

Literal parseBinary(Expr expr) {
  Expr left = expr.operands[0];
  Expr right = expr.operands[1];

  Literal leftVal = interpret(left);
  Literal rightVal = interpret(right);
  Literal returnVal;

  switch (expr.operator.type) {
  case TokenType.ADD:
    mixin binCaseGenAdd!("+");
    matchOperands(leftVal, rightVal);
    return returnVal;
    break;
  case TokenType.SUB:
    mixin binCaseGen!("-");
    matchOperands(leftVal, rightVal);
    return returnVal;
    break;
  case TokenType.MUL:
    mixin binCaseGen!("*");
    matchOperands(leftVal, rightVal);
    return returnVal;
    break;
  case TokenType.DIV:
    mixin binCaseGen!("/");
    matchOperands(leftVal, rightVal);
    return returnVal;
    break;
  default:
    throw new Exception("FAILED TO PARSE BINARY EXPRESSION");
  }
}

Literal parseUnary(Expr expr) {
  Literal value = interpret(expr.operands[0]);

  if (expr.operator.type == TokenType.SUB) {
    Literal retVal;

    value.match!(
      (int v) => retVal = -1 * v,
      (_) => throw new Exception("ILLEGAL UNARY OPERATION: + applied to non-number")
    );

    return retVal;
  } else if (expr.operator.type == TokenType.NOT) {
    Literal retVal;

    value.match!(
      (bool v) => retVal = !v,
      (_) => throw new Exception("ILLEGAL UNARY OPERATION: `not` applied to non-bool")
    );

    return retVal;
  }
  
  throw new Exception("ERROR INTERPRETING UNARY EXPRESSION");
}

Literal interpret(Expr expr) {
  ExprType type = expr.type;

  return type.match!(
    (LiteralType _) => parseLiteral(expr),
    (BinaryType _) => parseBinary(expr),
    (UnaryType _) => parseUnary(expr)
  );
}