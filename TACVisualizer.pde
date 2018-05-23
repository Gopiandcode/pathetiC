import java.util.List;

StringBuilder builder = new StringBuilder("int i = 0; int j = 0; int k = 0; int l = 0; int m = 0; int n = 0; int o = 0; int p = 0; int q = 0; int r = 0; int s = 0;\n" +
"i = i; j = j; k = k; l = l; m = m; n = n; o = o; p = p; q = q; r = r");
int choice = 0;

void setup() {
  size(1280, 720);
  background(255);
}


void keyPressed() {
  println("Key " + key + " pressed" );
  if(key == BACKSPACE && builder.length() > 0)
    builder.deleteCharAt(builder.length()-1);
   else if(key != CODED) {
     builder.append(key);
   } 
}

void mousePressed() {
 
     choice = (choice + 1)%3; 
}

void draw() {
   background(255);
   String pos = builder.toString();
   String out = toLexed(pos);
   String parsed;
   if(choice == 0) 
   parsed = toTAC(pos);
   else if(choice == 2)
   parsed = toParsed(pos);
   else
   parsed = toMIPS(pos);
   fill(0);
   text(pos, width/2 - textWidth(pos)/2, height/4);
   text(out, width/2 - textWidth(out)/2, 2 * height/4);
   if(choice == 0 || choice == 1)
   text(parsed, width/2 - textWidth(parsed)/2,  height/2 + 10);
   else
   text(parsed, width/2 - textWidth(parsed)/2, 3 * height/4);
}

String toTAC(String input) {
     List<Token> items = lex(input);
   ParserState state = new ParserState(items);
   Program result = parseProgram(state);
   TACGenerator generator = new TACGenerator();
   result.accept(generator);
   return generator.getState().toString();
}
String toParsed(String input) {
    
   List<Token> items = lex(input);
   ParserState state = new ParserState(items);
   Program result = parseProgram(state);
   println("Parsing complete\n\n");
   if(result != null) {
      return result.toString(); 
   }
   else {
     return "ERROR WHILE PARSING!";
   }
}

String toMIPS(String input) {
   List<Token> items = lex(input);
   ParserState state = new ParserState(items);
   Program result = parseProgram(state);
   TACGenerator generator = new TACGenerator();
   result.accept(generator);
   Generator mipsGen = new Generator(generator.getState().getConverted());
   mipsGen.generate();
   return mipsGen.toString();
}


String toLexed(String input) {
   List<Token> items = lex(input);
   StringBuilder temp = new StringBuilder();
   for(Token t : items) {
     temp.append("(" + t.toString() + ")");
   }
   return temp.toString();
}