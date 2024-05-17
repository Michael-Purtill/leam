// The primary scanner for Leamhan
module scan.scan;
import scan.types.token;
import scan.utils.utils;
import std.typecons;
import std.format;
import std.regex;
import std.algorithm;
import std.stdio;

Tuple!(int, Token) scanString(char[] stream, int lineNo, int charNo) {
  int i = 0;

  char[] str;

  while (stream[i] != '"' && stream[i] != '\'') {
    str ~= stream[i];
    i += 1;

    if (stream[i] != '\n') {
      charNo += 1;
    }
    else {
      charNo = 0;
      lineNo += 1;
    }
  }

  return tuple(i, new Token(TokenType.STRING, str.idup, lineNo, charNo));
}

Tuple!(int, Token) scanNumber(char[] stream, int lineNo, int charNo) {
  // take in a number. return either integer or float
  int i = 0;

  char[] number;

  TokenType type = TokenType.INT; // default to integer

  while (matchFirst("%c".format(stream[i]), r"[0-9\.]")) {
    if (stream[i] == '.') {
      if (i == 0 || type == TokenType.FLOAT) {
        // we saw a dot before any integer part, or we saw multiple dots in a number
        // i think this is illegal in every langauge we're dealing with but double check
        throw new Exception(
          "Unexpected token '.', (float values must have an integer part and cannot have multiple .'s)");
      }
      else { // we saw a period so we switch to float.
        type = TokenType.FLOAT;
        number ~= stream[i];
        i += 1;
      }
    }
    else {
      number ~= stream[i];
      i += 1;
    }
  }

  return tuple(i, new Token(type, number.idup, lineNo, charNo + i));
}

Token[] scanner(char[] source) {
  int lineNo = 1;
  int charNo = 0;

  Token[] tokenStream;

  int i = 0;

  while (i < source.length) {
    charNo += 1;

    char ch = source[i];

    if (ch == ' ') {
      i += 1;
      continue;
    }

    if (ch == '\n') {
      lineNo += 1;
      charNo = 0;
      i += 1;
      continue;
    }

    if (ch == '#') {
      i = i + endOfLineIndex(source[i .. $].idup);
      continue;
    }

    // Strings:
    if (ch == '"' || ch == '\'') {
      // we are in a string.
      i += 1;
      auto strTuple = scanString(source[i .. $], lineNo, charNo);
      int strTokenLength = strTuple[0];
      Token strToken = strTuple[1];

      tokenStream ~= strToken;
      charNo += strToken.charIndex;
      lineNo = strToken.lineNum;
      i += strTokenLength + 1;
      continue;
    }

    // Identifiers:

    if (matchFirst("%c".format(ch), r"[a-zA-Z]")) {
      // We are in an id or a keyword.``
      string word = peekToWhiteSpace(source[i .. $].idup);

      if (keywords.canFind(word)) {
        tokenStream ~= new Token(TokenTypeMap[word], "", lineNo, charNo);
      }
      else {
        tokenStream ~= new Token(TokenType.ID, word, lineNo, charNo);
      }

      i += word.length; // read the word, then put the index onto the whitespace that is after the word.
      charNo += word.length;
      continue;
    }

    // Numbers:
    if (matchFirst("%c".format(ch), r"[0-9]")) {
      auto numTuple = scanNumber(source[i .. $], lineNo, charNo);
      int numTokenLength = numTuple[0];
      Token numToken = numTuple[1];

      tokenStream ~= numToken;
      charNo += numTokenLength;
      ;
      i += numTokenLength;
      continue;
    }

    // assignment and comparison
    if (ch == '=' || ch == '<' || ch == '>') {
      char nextCh = source[i + 1];

      if (nextCh == '=') {
        tokenStream ~= new Token(TokenTypeMap["%c%c".format(ch, nextCh)], "", lineNo, charNo);
        i += 2;
        charNo += 1;
        continue;
      }
    }

    // Everything else which doesn't require special rules
    tokenStream ~= new Token(TokenTypeMap["%c".format(ch)], "", lineNo, charNo);

    i += 1;
  }

  return tokenStream;
}