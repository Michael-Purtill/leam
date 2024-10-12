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
    (float l, float r) => returnVal = mixin("l " ~ operator ~ " r"), // can't use dlang + operator for strings, need to use ~
    (string l, string r) => returnVal = mixin("l ~ r"),
    (_1, _2) => throw new Exception("INVALID ARITHMETIC OPERATION"));
}

class Evaluator {
  Literal[string] symbolTable = null; // you evaluate expressions and add them to symbol tables
  Expr[] statements;

  this(Expr[] stmts) {
    statements = stmts;
  }

  this(Expr[] stmts, Literal[string] syms) { // provide a copy of parent scope symbol table for evaluating lambda applications.
    statements = statements;
    symbolTable = syms;
  }

  void evaluate() {
    foreach (Expr statement; statements) {
      writeln(interpret(statement));
    }
  }

  Literal evalReturn() {
    Literal retVal;
    foreach (Expr statement; statements) {
      retVal = interpret(statement);
    }
    return retVal;
  }

  Literal[] evalReturnArr() {
    Literal[] retVals = null;
    foreach (Expr statement; statements) {
      retVals ~= interpret(statement);
    }
    return retVals;
  }

  Literal interpret(Expr expr) {
    ExprType type = expr.type;

    return type.match!(
      (LiteralType _) => evalLiteral(expr),
      (BinaryType _) => evalBinary(expr),
      (UnaryType _) => evalUnary(expr),
      (IDType _) => evalID(expr),
      (AssignmentType _) => evalAssignment(expr),
      (LambdaType _) => evalLiteral(expr), // lambda expressions evaluate to themselves.
      (ApplyType _) => evalApply(expr)
    );
  }

  Literal evalLiteral(Expr expr) {
    return expr.value;
  }

  Literal evalBinary(Expr expr) {
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
    case TokenType.AND:
      mixin binCaseGen!("&&");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    case TokenType.OR:
      mixin binCaseGen!("||");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    case TokenType.GREATER:
      mixin binCaseGen!(">");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    case TokenType.GREATER_EQ:
      mixin binCaseGen!(">=");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    case TokenType.LESS:
      mixin binCaseGen!("<");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    case TokenType.LESS_EQ:
      mixin binCaseGen!("<=");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    case TokenType.EQ:
      mixin binCaseGen!("==");
      matchOperands(leftVal, rightVal);
      return returnVal;
      break;
    default:
      throw new Exception("FAILED TO PARSE BINARY EXPRESSION");
    }
  }

  Literal evalUnary(Expr expr) {
    Literal value = interpret(expr.operands[0]);
    Literal retVal;
    if (expr.operator.type == TokenType.SUB) {
      value.match!(
        (int v) => retVal = -1 * v,
        (_) => throw new Exception("ILLEGAL UNARY OPERATION: + applied to non-number")
      );

      return retVal;
    }
    else if (expr.operator.type == TokenType.NOT) {
      value.match!(
        (bool v) => retVal = !v,
        (_) => throw new Exception("ILLEGAL UNARY OPERATION: `not` applied to non-bool")
      );

      return retVal;
    }

    throw new Exception("ERROR INTERPRETING UNARY EXPRESSION");
  }

  Literal evalID(Expr expr) {
    return symbolTable[to!string(expr.value)];
  }

  Literal evalAssignment(Expr expr) {
    Expr right = expr.operands[1];
    Literal rightVal = interpret(right);
    symbolTable[to!string(expr.operands[0].value)] = rightVal;

    return rightVal;
  }

  Literal evalApply(Expr expr) {
    return expr.value.match!(
      (Apply a) { 
        Literal[] paramVals = new Evaluator(a.params).evalReturnArr(); 
        Literal[string] newSymTable = symbolTable.dup();

        Token[] lambdaParams = a.lambda.value.match!(
          (Lambda l) => l.params,
          (_) => throw new Exception("INVALID LAMBDA")
        );

        foreach (i, Token t; lambdaParams) {
          newSymTable[t.value] = paramVals[i];
        }

        return a.lambda.value.match!(
          (Lambda l) => new Evaluator(l.bodyExprs, newSymTable).evalReturn(),
          (_) => throw new Exception("INVALID LAMBDA")
        );
      },
      (_) => throw new Exception("INVALID APPLICATION")
    );

    // Evaluator lambdaEval = new 
  }

}
