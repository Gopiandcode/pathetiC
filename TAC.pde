
static enum TACType {
  ADD, 
    SUB, 
    MUL, 
    DIV, 
    ASSIGN, 
    LSHIFT, 
    RSHIFT, 
    LEQ, 
    LE, 
    GEQ,
    NEG,
    GE, 
    EQ, 
    FJUMP, 
    TJUMP, 
    LABEL, 
    JUMP
}

public class Quadruple {
  TACType type;
  String a1;
  String a2;
  String result;

  public Quadruple(String result, TACType type, String a1, String a2) {
    this.result = result;
    this.type = type;
    this.a1 = a1;
    this.a2 = a2;
  }

  public String toString() {
    switch(type) {
        case NEG:
            return result + " = NEG " + a1;
    case ASSIGN:
      return result + " = " + a1;
    case FJUMP:
      return "FJUMP " + a1 + " " + result;
    case TJUMP:
      return "TJUMP " + a1 + " " + result;
    case LABEL:
      return "LABEL " + a1 + ":";
    case JUMP:
      return "JUMP " + result;
    }
    return result + " = " + a1  + " " + type + " " + a2;
  }
}

public class ConverterState {
   List<Quadruple> converted =  new ArrayList<Quadruple>();
   int labelID = 0;
   int temporaryID = 0;
   int conditionalID = 0;
   int conditionalEndID = 0;

   String getNewLabel() {
      return "flag" + labelID++; 
   }
   String getNewConditionalLabel() { return "iftest" + conditionalID++; }
    String getNewConditionalEndLabel() { return "ifend" + conditionalEndID++; }

   String getNewTemporary() {
      return "t" + temporaryID++; 
   }

   String getCurrentLabel() {
    return "flag" + (labelID - 1); 
   }
   String getCurrentConditionalLabel() { return "iftest" + (conditionalID-1); }
    String getCurrentConditionalEndLabel() { return "ifend" + (conditionalEndID-1); }

   void addInstruction(Quadruple instruction) {
      converted.add(instruction); 
   }
   
   
   List<Quadruple> getConverted() {
      return converted; 
   }

   ConverterState copy() {
       ConverterState state = new ConverterState();
       state.labelID = labelID;
       state.temporaryID = temporaryID;
       return state;
   }
   
   public String toString() {
     StringBuilder b = new StringBuilder();
      for(Quadruple quad : converted) {
        b.append(quad.toString());
        b.append("\n");
      }
      return b.toString();
   }
}

public class GeneratorResult {
    String temporaryName;
    public GeneratorResult(String temporaryName) {this.temporaryName = temporaryName;}
}

public class TACGenerator implements Visitor {
    private ConverterState state = new ConverterState();

    ConverterState getState() { return state; }
    public GeneratorResult visit(Program o) {
        for(Statement s : o.statements) {
            s.accept(this);
        }
        return new GeneratorResult("");
    }
    
    public GeneratorResult visit(Object o) {
       println("EMPTY CALLED " + o);
       return new GeneratorResult("");
    }
    public GeneratorResult visit(Statement s) {
      
       println("Statement CALLED " + s);
       return (GeneratorResult) s.accept(this); 
    }
    public GeneratorResult visit(DeclStatement o) {
        GeneratorResult result = (GeneratorResult) o.e.accept(this);
        state.addInstruction(new Quadruple(o.id,TACType.ASSIGN, result.temporaryName,""));
        return new GeneratorResult(o.id);
    }
    public GeneratorResult visit(ExprStatement o) {
        return (GeneratorResult) o.e.accept(this);
    }
    public GeneratorResult visit(ForStatement o) {
       o.initializer.accept(this);
       String test = state.getNewLabel();
       String end = state.getNewLabel();
       state.addInstruction(new Quadruple("", TACType.LABEL, test, ""));
       GeneratorResult res = (GeneratorResult) o.condExpr.accept(this);
       state.addInstruction(new Quadruple(end, TACType.FJUMP, res.temporaryName, ""));
       for(Statement s : o.body) {
           s.accept(this);
       }
       o.increment.accept(this);
       state.addInstruction(new Quadruple(test, TACType.JUMP, "", ""));
       state.addInstruction(new Quadruple("", TACType.LABEL, end, ""));
       return new GeneratorResult("");
    }
    public GeneratorResult visit(WhileStatement o) {
       String test = state.getNewLabel();
       String end = state.getNewLabel();
       state.addInstruction(new Quadruple("", TACType.LABEL, test, ""));
       GeneratorResult res = (GeneratorResult) o.condExpr.accept(this);
       state.addInstruction(new Quadruple(end, TACType.FJUMP, res.temporaryName, ""));
       for(Statement s : o.body) {
           s.accept(this);
       }
       state.addInstruction(new Quadruple(test, TACType.JUMP, "", ""));
       state.addInstruction(new Quadruple("", TACType.LABEL, end, ""));
       return new GeneratorResult("");

    }
    java.util.Stack<String> ifEndStack = new java.util.Stack<String>();
    java.util.Stack<String> ifTestStack = new java.util.Stack<String>();
    public GeneratorResult visit(IfStatement o) {
        GeneratorResult res = (GeneratorResult)o.condExpr.accept(this);
        String end = state.getNewConditionalLabel();
        String nextTest;
        if(o.control != null) {
            nextTest = state.getNewConditionalLabel();
            ifEndStack.push(end);
            ifTestStack.push(nextTest);
            state.addInstruction(new Quadruple(nextTest, TACType.FJUMP, res.temporaryName, ""));
        }
        else {
            state.addInstruction(new Quadruple(end, TACType.FJUMP, res.temporaryName, ""));
        }
        // t1 = a LE b
        // fjump t1 test2
        // ....
        // ....
        // jump end
        // label test2:
        // t2 = a LE b
        // ...
        // ...
        // label end:
        //
        for(Statement s : o.body) {
            s.accept(this);
        }
        if(o.control == null) {
            state.addInstruction(new Quadruple("", TACType.LABEL, end, ""));
            return new GeneratorResult("");
        } else {
            state.addInstruction(new Quadruple(end, TACType.JUMP, "", ""));
            GeneratorResult res2 = (GeneratorResult) o.control.accept(this);
            state.addInstruction(new Quadruple("", TACType.LABEL, end, ""));
            ifEndStack.pop();
            ifTestStack.pop();
            return res2;
        }
    }

    public GeneratorResult visit(BreakStatement o) {
        String end = state.getCurrentLabel();
        state.addInstruction(new Quadruple(end, TACType.JUMP, "", ""));
        return new GeneratorResult("");
    }

    public GeneratorResult visit(ElseControl o) {

        for(Statement s : o.body) {
            s.accept(this);
        }

        return new GeneratorResult("");
    }
    public GeneratorResult visit(ConditionalElseControl o) {

        String test = ifTestStack.peek();
        String end = ifEndStack.peek();
        state.addInstruction(new Quadruple("", TACType.LABEL, test, ""));
       
        GeneratorResult res = (GeneratorResult)o.cond.accept(this);
        String nextTest;
        if(o.control != null) {
            nextTest = state.getNewConditionalLabel();
            ifTestStack.push(nextTest);
            state.addInstruction(new Quadruple(nextTest, TACType.FJUMP, res.temporaryName, ""));
        } else {
            state.addInstruction(new Quadruple(end, TACType.FJUMP, res.temporaryName, ""));
        }
        // t1 = a LE b
        // fjump t1 test2
        // ....
        // ....
        // jump end
        // label test2:
        // t2 = a LE b
        // ...
        // ...
        // label end:
        //
        for(Statement s : o.body) {
            s.accept(this);
        }

        if(o.control == null) {
            state.addInstruction(new Quadruple("", TACType.LABEL, end, ""));
            return new GeneratorResult("");
        } else {
            state.addInstruction(new Quadruple(end, TACType.JUMP, "", ""));
            GeneratorResult res2 = (GeneratorResult) o.control.accept(this);
            ifTestStack.pop();
            return res2;
        }
    }
    public GeneratorResult visit(IdentifierExpression o) {
        return new GeneratorResult(o.id);
    }
    public GeneratorResult visit(NumberExpression o) {
        return new GeneratorResult(o.number);
    }
    public GeneratorResult visit(IncrExpression o) {
        if(o.isPre) {
            String res = o.id;
            state.addInstruction(new Quadruple(res, TACType.ADD, res, "1"));
            return new GeneratorResult(res);
        }
        else {
            String temp = state.getNewTemporary();
            state.addInstruction(new Quadruple(temp, TACType.ASSIGN, o.id, ""));
            state.addInstruction(new Quadruple(o.id, TACType.ADD, o.id, "1"));
            return new GeneratorResult(temp);
        }
    }
    public GeneratorResult visit(DecrExpression o) {
         if(o.isPre) {
            String res = o.id;
            state.addInstruction(new Quadruple(res, TACType.SUB, res, "1"));
            return new GeneratorResult(res);
        }
        else {
            String temp = state.getNewTemporary();
            state.addInstruction(new Quadruple(temp, TACType.ASSIGN, o.id, ""));
            state.addInstruction(new Quadruple(o.id, TACType.SUB, o.id, "1"));
            return new GeneratorResult(temp);
        }
    }
    public GeneratorResult visit(AssignExpression o) {
        TACType type;
       switch(o.assignType) {
           case "+=":
               type = TACType.ADD;
               break;
           case "-=":
               type = TACType.SUB;
               break;
           case "*=":
               type = TACType.MUL;
               break;
           case "/=":
               type = TACType.DIV;
               break;
           case "=":
               GeneratorResult res = (GeneratorResult) o.e.accept(this);
               state.addInstruction(new Quadruple(o.id, TACType.ASSIGN, res.temporaryName, ""));
               return new GeneratorResult(o.id);
           default:
               return new GeneratorResult(o.id);
       }
        GeneratorResult res = (GeneratorResult) o.e.accept(this);
        state.addInstruction(new Quadruple(o.id, type, o.id, res.temporaryName));
        return new GeneratorResult(o.id);
    }
    public GeneratorResult visit(NegExpression o) {
        String temp = state.getNewTemporary();
        GeneratorResult res = (GeneratorResult) o.e.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.NEG, res.temporaryName, ""));
        return new GeneratorResult(temp);
    }
    public GeneratorResult visit(TimesExpression o) {
        String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.MUL, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(DivideExpression o) {
         String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.DIV, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(AddExpression o) {
          String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.ADD, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(SubExpression o) {
           String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.SUB, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(LShiftExpression o) {
            String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.LSHIFT, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(RShiftExpression o) {
        String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.RSHIFT, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(AndExpression o) {
        String temp = state.getNewTemporary();
        String andEnd = state.getNewConditionalEndLabel();

        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.ASSIGN, res1.temporaryName, ""));

        state.addInstruction(new Quadruple(andEnd, TACType.FJUMP, temp, ""));

        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.ASSIGN, res2.temporaryName, ""));

        state.addInstruction(new Quadruple("", TACType.LABEL, andEnd, ""));

        return new GeneratorResult(temp);
    }
    public GeneratorResult visit(OrExpression o) {
         String temp = state.getNewTemporary();
        String andEnd = state.getNewConditionalEndLabel();

        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.ASSIGN, res1.temporaryName, ""));

        state.addInstruction(new Quadruple(andEnd, TACType.TJUMP, temp, ""));

        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.ASSIGN, res2.temporaryName, ""));

        state.addInstruction(new Quadruple("", TACType.LABEL, andEnd, ""));

        return new GeneratorResult(temp);
    }
    public GeneratorResult visit(LEComparisonExpression o) {
        String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.LE, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(LEQComparisonExpression o) {
         String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.LEQ, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(GEComparisonExpression o) {
         String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.GE, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(GEQComparisonExpression o) {
         String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.GEQ, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
    public GeneratorResult visit(EQComparisonExpression o) {
         String temp = state.getNewTemporary();
        GeneratorResult res1 = (GeneratorResult) o.e1.accept(this);
        GeneratorResult res2 = (GeneratorResult) o.e2.accept(this);
        state.addInstruction(new Quadruple(temp, TACType.EQ, res1.temporaryName, res2.temporaryName));
        return new GeneratorResult(temp);

    }
}