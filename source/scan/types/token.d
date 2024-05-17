module scan.types.token;
import std.format;
import std.conv;

enum TokenType {
  // Arithmetic and Logic
  ADD, // +
  SUB, // -
  MUL, // *
  DIV, // /
  EQ, // ==
  LESS, // <,
  LESS_EQ, // <=,
  GREATER, // >
  GREATER_EQ, // >=
  ASSIGN, // =

  // Keywords
  // User code:
  FN, // fn :var1 :var2... do ... end
  DO, // do ... end
  END, // do ... end
  IF, // if boolean_expr do .. end else do ... end
  ELSE, // ^
  HASH, // #, start comment

  // StdLib:
  MAP, // map arrvar fn a do ... end
  LOAD, // obj = load "/path/to/file"
  TO_JSON, // newobj = tojson obj
  TO_YAML, // toyaml obj
  TO_TOML, // totoml obj

  // Basic data types like strings, numbers
  STRING,
  INT, // 123
  FLOAT, // 123.123
  ID, // variable names, alphanumeric starting with letters, including _

  // Leam's internal data types (which are a lot like javascript's arrays/objects)
  SQUARE_LEFT,
  SQUARE_RIGHT,
  CURLY_LEFT,
  CURLY_RIGHT,
  COLON,
  DOT,
  COMMA,

  // Init format objects:
  JSONINIT,
  YAMLINIT,
  TOMLINIT,
  AUTOINIT // init json, yaml, toml objects respectively, autoinit will do type inference.
}

// a helper hashmap to avoid making huge switch statements in the scanner
const TokenType[string] TokenTypeMap = [
  // Arithmetic and Logic
  "+": TokenType.ADD,
  "-": TokenType.SUB,
  "*": TokenType.MUL,
  "/": TokenType.DIV,
  "==": TokenType.EQ,
  "<": TokenType.LESS,
  "<=": TokenType.LESS_EQ,
  ">": TokenType.GREATER,
  ">=": TokenType.GREATER_EQ,
  "=": TokenType.ASSIGN,
  // User code
  "fn": TokenType.FN,
  "do": TokenType.DO,
  "end": TokenType.END,
  "if": TokenType.IF,
  "else": TokenType.ELSE,
  "#": TokenType.HASH,
  // Stdlib
  "map": TokenType.MAP,
  "load": TokenType.LOAD,
  "tojson": TokenType.TO_JSON,
  "toyaml": TokenType.TO_YAML,
  "totoml": TokenType.TO_TOML,
  // Arrays and Objects
  "[": TokenType.SQUARE_LEFT,
  "]": TokenType.SQUARE_RIGHT,
  "{": TokenType.CURLY_LEFT,
  "}": TokenType.CURLY_RIGHT,
  ":": TokenType.COLON,
  ".": TokenType.DOT,
  ",": TokenType.COMMA,
  // object initers
  "json": TokenType.JSONINIT,
  "yaml": TokenType.YAMLINIT,
  "toml": TokenType.TOMLINIT,
  "auto": TokenType.AUTOINIT,
];

const string[] keywords = [
  "map", "load", "toyaml", "tojson", "totoml",
  "json", "yaml", "toml", "auto", "if", "else", "do", "end", "fn"
];

class Token {
  TokenType type;
  string value;
  // Line number and character position in line for error reporting.
  int lineNum;
  int charIndex;

  this(TokenType t, string v, int ln, int ci) {
    this.type = t;
    this.value = v;
    this.lineNum = ln;
    this.charIndex = ci;
  }

  override string toString() {
    return "type:\t\t%s\n
            value:\t\t%s\n
            line:\t\t%d\n
            char:\t\t%d\n
            ".format(to!string(this.type), this.value, this.lineNum, this.charIndex);
  }
}