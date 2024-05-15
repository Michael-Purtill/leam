module scan.utils.utils;
import std.algorithm;

string peekToWhiteSpace(string stream) {
  char[] whitespace = [' ', '\t', '\n'];
  char[] res;

  for (int i = 0; i < stream.length && !whitespace.canFind(stream[i]); i++) {
    res ~= stream[i];
  }

  return res.idup;
}