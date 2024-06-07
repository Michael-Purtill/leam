module scan.types.token;
import std.format;
import std.conv;

enum TokenType {
  // Arithmetic and Logic
  ADD, // +
  SUB, // -
  MUL, // *
  DIV, // /
  PAREN_LEFT,
  PAREN_RIGHT,
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
  AND,
  OR,
  NOT,
  HASH, // #, start comment
  APPLY, // apply fn a b c do .. end x y z

  // StdLib:
  MAP, // map arrvar fn a do ... end
  LOAD, // obj = load "/path/to/file"
  WRITE, // write obj #write to the console for consumption by unix util
  TO_JSON, // newobj = tojson obj
  TO_YAML, // toyaml obj
  TO_TOML, // totoml obj
  KEYS, // keys obj -> ['these', 'are', 'all', 'keys']
  VALS, // values obj -> ['these', 'are', 'all', 'values']

  // Basic data types like strings, numbers
  STRING,
  INT, // 123
  FLOAT, // 123.123
  ID, // variable names, alphanumeric starting with letters, including _
  TRUE,
  FALSE,

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
  AUTOINIT, // init json, yaml, toml objects respectively, autoinit will do type inference.

  NEWLINE,
  // End of File
  EOF
}

// a helper hashmap to avoid making huge switch statements in the scanner
const TokenType[string] TokenTypeMap = [
  // Arithmetic and Logic
  "+": TokenType.ADD,
  "-": TokenType.SUB,
  "*": TokenType.MUL,
  "/": TokenType.DIV,
  "(": TokenType.PAREN_LEFT,
  ")": TokenType.PAREN_RIGHT,
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
  "and": TokenType.AND,
  "or": TokenType.OR,
  "not": TokenType.NOT,
  "#": TokenType.HASH,
  "apply": TokenType.APPLY,
  // Stdlib
  "map": TokenType.MAP,
  "load": TokenType.LOAD,
  "write": TokenType.WRITE,
  "keys": TokenType.KEYS,
  "values": TokenType.VALS,
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
  "true": TokenType.TRUE,
  "false": TokenType.FALSE
];

const string[] keywords = [ // I wonder if the D compiler is smart enough to turn this into a static array at compile time
  "map", "load", "write", "toyaml", "tojson", "totoml",
  "json", "yaml", "toml", "auto", "if", "else", "and", "or", "do", "end", "fn",
  "keys", "values", "apply", "not", "true", "false"
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

  override string toString() const @safe{
    return "type:\t\t%s\n
            value:\t\t%s\n
            line:\t\t%d\n
            char:\t\t%d\n
            ".format(to!string(this.type), this.value, this.lineNum, this.charIndex);
  }
}