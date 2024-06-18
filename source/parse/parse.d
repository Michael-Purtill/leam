module parse.parse;
import scan.types.token : Token, TokenType;
import parse.types.ast;
import std.typecons;
import std.algorithm : canFind;
import std.conv;
import std.stdio;

class Parser {
  int tokenIndex;
  Token[] tokens;

  this(Token[] t) {
    tokens = t;
    tokenIndex = -1;
  }

  // utils:

  Token nextToken() { // look but don't change 
    if (tokenIndex + 1 >= tokens.length) {
      return new Token(TokenType.EOF, "", 0, 0);
    }

    return tokens[tokenIndex + 1];
  }

  Token incrementToken() { // look and change.
    tokenIndex += 1;
    return tokens[tokenIndex];
  }

  bool checkTokenType(Token token, TokenType[] types) {
    return types.canFind(token.type);
  }

  Expr[] parse() {
    Expr[] res = [];
    while (nextToken().type != TokenType.EOF) {
      res ~= subParse();
      while (tokens[tokenIndex].type == TokenType.NEWLINE) {
        incrementToken();
      }
    }

    return res;
  }

  Expr subParse() {
    return parseLogical();
  }

  Expr binaryExprMaker(TokenType[] operatorTypes, Expr delegate() exprParser) {
    Expr binExpr = exprParser(); // parse the left side of the expression.

    while (checkTokenType(nextToken(), operatorTypes)) { // check if the next token is one of the operators I'm looking for
      Token operator = incrementToken();
      Expr right = exprParser(); // parse the right side of the expression.

      Literal empty = "";

      BinaryType binType;

      ExprType type = binType;

      binExpr = new Expr(operator, [binExpr, right], empty, type);
    }

    return binExpr;
  }

  Expr parseLogical() {
    return binaryExprMaker([TokenType.AND, TokenType.OR], &parseEquality);
  }

  Expr parseEquality() {
    return binaryExprMaker([TokenType.EQ, TokenType.NOT], &parseComparison);
  }

  Expr parseComparison() {
    return binaryExprMaker([
      TokenType.GREATER, TokenType.GREATER_EQ, TokenType.LESS, TokenType.LESS_EQ
    ], &parseTerm);
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

  Expr parseID() {
    if (checkTokenType(nextToken(), [TokenType.ID])) {
      Token id = incrementToken();

      IDType idType;

      ExprType type = idType;

      return new Expr(null, [], id.value, type);
    }
  }

  Expr parseAssignment() {
    Expr left = parseID();

    if (checkTokenType(nextToken(), [TokenType.ASSIGN])) {
      Token operator = incrementToken();
      Expr right = parseLogical();

      Literal empty = "";

      BinaryType binType;

      ExprType type = binType;

      binExpr = new Expr(operator, [left, right], empty, type);
    }
  }

  Expr parsePrimary() {
    if (checkTokenType(nextToken(), [TokenType.TRUE, TokenType.FALSE])) {
      Token boolToken = incrementToken();
      Literal val = to!bool(boolToken.value);
      LiteralType lt;
      ExprType type = lt;
      return new Expr(null, [], val, type);
    }

    if (checkTokenType(nextToken(), [
          TokenType.STRING, TokenType.INT, TokenType.FLOAT
        ])) {
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

      return expr;
    }

    if (checkTokenType(nextToken(), [TokenType.ID])) {
      if (tokens[tokenIndex + 2].type == TokenType.ASSIGN) {
        return parseAssignment();
      } else {
        return parseID();
      }
    }

    throw new Exception(
      "Failed parsing for some reason, here's the token I got stuck on: "
        ~ tokens[tokenIndex].toString());
  }
  
}
