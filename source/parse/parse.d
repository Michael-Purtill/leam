module parse.parse;
import scan.types.token : Token, TokenType;
import parse.types.ast;
import std.typecons;
import std.algorithm : canFind;
import std.conv;

class Parser {
  int tokenIndex;
  Token[] tokens;

  this(Token[] t) {
    tokens = t;
    tokenIndex = 0;
  }

  // utils:

  Token nextToken() { // look but don't change 
    return tokens[tokenIndex + 1];
  }

  Token incrementToken() { // look and change.
    tokenIndex += 1;
    return tokens[tokenIndex];
  }

  bool checkTokenType(Token token, TokenType[] types) {
    return types.canFind(token.type);
  }

  Expr parse() {
    return parseEquality();
  }

  Expr binaryExprMaker(TokenType[] operatorTypes, Expr delegate() exprParser) {
    Expr binExpr = exprParser();

    while (checkTokenType(nextToken(), operatorTypes)) {
      Token operator = incrementToken();
      Expr right = exprParser();

      Literal empty = "";

      BinaryType binType;

      ExprType type = binType;

      binExpr = new Expr(operator, [binExpr, right], empty, type);
    }

    return binExpr;
  }

  Expr parseEquality() {
    return binaryExprMaker([TokenType.EQ, TokenType.NOT], &parseComparison);
  }

  Expr parseComparison() {
    return binaryExprMaker([TokenType.GREATER, TokenType.GREATER_EQ, TokenType.LESS, TokenType.LESS_EQ], &parseTerm);
  }

  Expr parseTerm() {
    return binaryExprMaker([TokenType.SUB, TokenType.ADD], &parseFactor);
  }

  Expr parseFactor() {
    return binaryExprMaker([TokenType.MUL, TokenType.DIV], &parseUnary);
  }

  Expr parseUnary() {
    if (checkTokenType(nextToken(), [TokenType.NOT, TokenType.SUB])) {
      Token operator = incrementToken();
      Expr right = parseUnary();

      Literal empty = "";
      UnaryType uType;

      ExprType type = uType;

      return new Expr(operator, [right], empty, type);

    }

    return parsePrimary();
  }

  Expr parsePrimary() {
    if (checkTokenType(nextToken(), [TokenType.TRUE, TokenType.FALSE])) {
      Token boolToken = incrementToken();
      Literal val = to!bool(boolToken.value);
      LiteralType lt;
      ExprType type = lt;
      return new Expr(null, [], val, type);
    }

    if (checkTokenType(nextToken(), [TokenType.STRING, TokenType.INT, TokenType.FLOAT])) {
      Token valToken = incrementToken();
      Literal val = valToken.value;
      
      if (valToken.type == TokenType.INT) {
        val = to!int(valToken.value);
      }

      if (valToken.type == TokenType.FLOAT) {
        val = to!float(valToken.value);
      }

      LiteralType lt;
      ExprType type = lt;
      return new Expr(null, [], val, type);
    }

    if (checkTokenType(nextToken(), [TokenType.PAREN_LEFT])) {
      incrementToken();

      Expr expr = parseEquality();

      if (!checkTokenType(nextToken(), [TokenType.PAREN_RIGHT])) {
        throw new Exception("Expect ')' after expression");
      }

      incrementToken();

      GroupingType gt;
      ExprType type = gt;

      expr.type = type;

      return expr;
    }

    throw new Exception("Expect ')' after expression");
  }
}

