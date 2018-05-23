import java.util.List;
import java.util.ArrayList;


//
//
   static enum TokenType {
	  FOR,            // for
	  WHILE,          // while
	  IF,             // if
	  INT,            // int 
	  ELSE,           // else
	  ELIF,           // elif
    BREAK,          // break
	  LPAREN,         // (
	  RPAREN,         // )
	  LBRACE,         // {
	  RBRACE,         // }
	  ASSIGN,         // =
	  ASSIGN_ADD,     // +=
	  ASSIGN_MULT,    // *=
	  ASSIGN_DIV,     // /=
	  ASSIGN_SUB,     // -=
	  INCR,           // ++
	  DECR,           // --
	  PLUS,           // +
	  MINUS,          // -
	  MUL,            // *
	  DIV,            // /
	  LSHIFT,         // <<
	  RSHIFT,         // >>
	  AND,            // &&
	  OR,             // ||
	  GE,             // >
	  LE,             // <
	  GEQ,            // >=
	  LEQ,            // <=
	  EQ,             // ==
    SEMI,           // ;
	  ID,
	  NUMBER,
	  EOF
  }
  
  public static class Token {
     public final TokenType t;
     public final String c;
     
     public Token(TokenType t, String c) {
      this.t = t;
      this.c = c;
     }
     
     public String toString() {
        if(t == TokenType.ID) {
          return "ID<" + c + ">";
        } else if(t == TokenType.NUMBER) {
          return "NUMBER<" + c + ">"; 
        }
        return t.toString();
     }
  }
  
   static String getAtom(String s, int i) {
   int j = i;
   for(; j < s.length(); ){
     if(Character.isLetterOrDigit(s.charAt(j))){
       j++;
     } else {
      return s.substring(i, j); 
     }
   }
   return s.substring(i,j);
  }
 public static String getNumber(String s, int i) {
   int j = i;
   for(; j < s.length(); ){
     if(Character.isDigit(s.charAt(j))){
       j++;
     } else {
      return s.substring(i, j); 
     }
   }
   return s.substring(i,j);
  }
  
 

  
    List<Token> lex(String input) {
   List<Token> result = new ArrayList<Token>();
   
   for(int i = 0; i < input.length();) {
    switch(input.charAt(i)) {
      case '(':
      result.add(new Token(TokenType.LPAREN, "("));
      i++;
      break;
      case ')':
      result.add(new Token(TokenType.RPAREN, ")"));
      i++;
      break;
      case '{':
      result.add(new Token(TokenType.LBRACE, "{"));
      i++;
      break;
      case '}':
      result.add(new Token(TokenType.RBRACE, "}"));
      i++;
      break;
      case ';':
      result.add(new Token(TokenType.SEMI, ";"));
      i++;
      break; 
      case '|':
      if(i + 1 < input.length() && input.charAt(i+1) == '|') {
        result.add(new Token(TokenType.OR, "||"));
        i++;
        i++;
        break;
      } else {
        System.err.println("ERROR: Foreign character " + input.charAt(i));
        i++;
        break;
      }

      case '&':
      if(i + 1 < input.length() && input.charAt(i+1) == '&') {
        result.add(new Token(TokenType.AND, "&&"));
        i++;
        i++;
        break;
      } else {
        System.err.println("ERROR: Foreign character " + input.charAt(i));
        i++;
        break;
      }

      case '=':
      if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.EQ, "=="));
	      i++;
	      i++;
      } else {
	      result.add(new Token(TokenType.ASSIGN, "="));
	      i++;
      }
      break;
      case '+':
      if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.ASSIGN_ADD, "+="));
	      i++;
	      i++;
      } else if(i + 1 < input.length() && input.charAt(i+1) == '+') {
	      result.add(new Token(TokenType.INCR, "++"));
	      i++;
	      i++;
      }
      else {
	      result.add(new Token(TokenType.PLUS, "+"));
	      i++;
      }
      break;
      case '-':
      if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.ASSIGN_SUB, "-="));
	      i++;
	      i++;
      } else if(i + 1 < input.length() && input.charAt(i+1) == '-') {
	      result.add(new Token(TokenType.DECR, "--"));
	      i++;
	      i++;
      }
      else {
	      result.add(new Token(TokenType.MINUS, "-"));
	      i++;
      }
      break;
      case '*':
      if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.ASSIGN_MULT, "*="));
	      i++;
	      i++;
      }
      else {
	      result.add(new Token(TokenType.MUL, "*"));
	      i++;
      }
      break;
      case '/':
      if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.ASSIGN_DIV, "/="));
	      i++;
	      i++;
      }
      else {
	      result.add(new Token(TokenType.DIV, "/"));
	      i++;
      }
      break;
      case '<':
      if(i + 1 < input.length() && input.charAt(i+1) == '<') {
	      result.add(new Token(TokenType.LSHIFT, "<<"));
	      i++;
	      i++;
      }
      else if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.LEQ, "<="));
	      i++;
	      i++;
      }
      else {
	      result.add(new Token(TokenType.LE, "<"));
	      i++;
      }
      break;
      case '>':
      if(i + 1 < input.length() && input.charAt(i+1) == '>') {
	      result.add(new Token(TokenType.RSHIFT, ">>"));
	      i++;
	      i++;
      }
      else if(i + 1 < input.length() && input.charAt(i+1) == '=') {
	      result.add(new Token(TokenType.GEQ, ">="));
	      i++;
	      i++;
      }
      else {
	      result.add(new Token(TokenType.GE, ">"));
	      i++;
      }
      break;

      default:
      // 
      // for
      // while
      // if
      // int
      //
      if(input.charAt(i) == 'f' && i + 2 < input.length() && input.charAt(i+1) == 'o' && input.charAt(i+2) == 'r' && (i + 3 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+3)))) {
	      result.add(new Token(TokenType.FOR, "for"));
	      i++;
	      i++;
	      i++;
	      break;
      } else if(input.charAt(i) == 'w' && i + 4 < input.length() && input.charAt(i+1) == 'h' && input.charAt(i+2) == 'i' && input.charAt(i+3) == 'l' && input.charAt(i+4) == 'e' && (i + 5 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+5)))) {
	      result.add(new Token(TokenType.WHILE, "while"));
	      i++;
	      i++;
	      i++;
	      i++;
	      i++;
	      break;
      }
      else if(input.charAt(i) == 'b' && i + 4 < input.length() && input.charAt(i+1) == 'r' && input.charAt(i+2) == 'e' && input.charAt(i+3) == 'a' && input.charAt(i+4) == 'k' && (i + 5 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+5)))) {
        result.add(new Token(TokenType.BREAK, "break"));
        i++;
        i++;
        i++;
        i++;
        i++;
        break;
      }
      else if(input.charAt(i) == 'e') {
	if(i + 3 < input.length() && input.charAt(i+1) == 'l' && input.charAt(i+2) == 's' && input.charAt(i+3) == 'e' && (i + 4 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+4)))) {
	      result.add(new Token(TokenType.ELSE, "else"));
	      i++;
	      i++;
	      i++;
	      i++;
	      break;
	} else if(i + 3 < input.length() && input.charAt(i+1) == 'l' && input.charAt(i+2) == 'i' && input.charAt(i+3) == 'f' && (i + 4 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+4)))) {
	      result.add(new Token(TokenType.ELIF, "elif"));
	      i++;
	      i++;
	      i++;
	      i++;
	      break;
}
      } else if(input.charAt(i) == 'i') {
	if(i + 1 < input.length() && input.charAt(i+1) == 'f' && (i + 2 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+2)))) {
	      result.add(new Token(TokenType.IF, "if"));
	      i++;
	      i++;
	      break;
	} else if(i + 2 < input.length() && input.charAt(i+1) == 'n' && input.charAt(i+2) == 't' && (i + 3 >= input.length() || !Character.isLetterOrDigit(input.charAt(i+3)))) {
	      result.add(new Token(TokenType.INT, "int"));
	      i++;
	      i++;
	      i++;
	      break;
	      }
      }
      if(Character.isWhitespace(input.charAt(i))) {
        i++;
      } else if(Character.isDigit(input.charAt(i))) {
        String atom = getNumber(input, i);
        i += atom.length();
        result.add(new Token(TokenType.NUMBER, atom));
      } else if(Character.isLetter(input.charAt(i))) {
        String atom = getAtom(input, i);
        i += atom.length();
        result.add(new Token(TokenType.ID, atom));
      } else {
	      System.err.println("ERROR: Foreign character " + input.charAt(i));
	      i++;
      }
      break;
   }
  }
  
   return result;
  }