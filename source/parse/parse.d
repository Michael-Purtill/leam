module parse.parse;
import scan.types.token : Token, TokenType;
import parse.types.ast;
import std.typecons;
import std.algorithm : canFind;
import std.conv;
import std.stdio;
import std.format;

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
      res ~= enterParse();
      while (tokens[tokenIndex].type == TokenType.NEWLINE) {
        incrementToken();
      }
    }

    return res;
  }

  Expr enterParse() {
    return parseLogical();
  }

  Expr parseLambda() {
    if (checkTokenType(nextToken(), [TokenType.FN])) { // saw the start of a lambda value.
      incrementToken(); // consume fn keyword.

      Token[] params = null;

      // look for params and add them to params array if they exist.
      while (checkTokenType(nextToken(), [TokenType.ID])) {
        params ~= incrementToken();
      }

      Token[] lambdaBodyTokens = null;

      int doEndBalance = 0;

      do {
        if (checkTokenType(nextToken(), [TokenType.DO])) {
          doEndBalance += 1;
          lambdaBodyTokens ~= incrementToken();
        }
        else if (checkTokenType(nextToken(), [TokenType.END])) {
          doEndBalance -= 1;
          lambdaBodyTokens ~= incrementToken();
        }
        else {
          lambdaBodyTokens ~= incrementToken();
        }
      }
      while (doEndBalance != 0);

      lambdaBodyTokens = lambdaBodyTokens[1 .. lambdaBodyTokens.length - 1]; // get rid of redundant do end keywords bookending the array.

      // construct the lambda literal expr:
      // step 1: make an expr out of the lambda body tokens:
      Expr[] lambdaBody = new Parser(lambdaBodyTokens).parse();

      // step 2: create lamda literal with params and body:
      Lambda func = new Lambda(params, lambdaBody);

      // step 3: build the Expr which holds the lambda literal.
      LambdaType lambdaType;

      ExprType type = lambdaType;

      Expr lambdaExpr = new Expr(null, [], func, type);

      return lambdaExpr;
    }
    else {
      return enterParse();
    }
  }

  Expr parseApply() {
    if (checkTokenType(nextToken(), [TokenType.APPLY])) {
      incrementToken(); // don't store apply keyword.
      Expr lambda = parseLambda(); // parse the lambda expression
      Expr[] arguments = null; //arguments are exprs evaluated at runtime.

      foreach (Token t; lambda.value.params) { // build array of arguments
        arguments ~= enterParse();
      }

      ApplyType applyType;

      ExprType type = applyType;

      Expr applyExpr = new Expr(null, [], lambda, applyType);

      return applyExpr;

    }
    else {
      return enterParse();
    }
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

      Literal val = id.value;

      return new Expr(null, [], val, type);
    }

    throw new Exception("Failed to parse identifier. Failed on token %".format(nextToken()));
  }

  Expr parseAssignment() {
    Expr assignment = parseID();

    if (checkTokenType(nextToken(), [TokenType.ASSIGN])) {
      Token operator = incrementToken();
      Expr right = enterParse();

      Literal empty = "";

      AssignmentType assignType;

      ExprType type = assignType;

      assignment = new Expr(operator, [assignment, right], empty, type);
    }

    return assignment;
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
      return parseAssignment();
    }

    if (checkTokenType(nextToken(), [TokenType.FN])) {
      return parseLambda();
    }

    if (checkTokenType(nextToken(), [TokenType.APPLY])) {
      return parseApply();
    }

    throw new Exception(
      "Failed parsing for some reason, here's the token I got stuck on:\n "
        ~ tokens[tokenIndex].toString());
  }

}
