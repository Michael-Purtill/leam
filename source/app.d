import std.stdio;
import scan.scan;
import scan.types.token;

void main()
{
	string testCode = "
    i = 1.43234

    j = 2.25

    \"string!!!!\"

    'do'

    x = \"this is a test\"

    # this is a comment

    test = fn asdf do 
      q = 3
    end
  ";

  auto tokens = scanner(testCode.dup);

  foreach(Token token; tokens) {
    writeln(token.toString());
  }

  return;
}
