public class MIPSSynthesizer {
  List<String> code = new ArrayList<String>();
  java.util.function.Predicate numeric = Pattern.compile("[0-9]+").asPredicate();

  public String toString() {
    StringBuilder sb = new StringBuilder();
    for(String s : code) {
      sb.append(s + "\n");
    }
    return sb.toString();
  }



  public void assign(String rd, String rs) {
      if(numeric.test(rs)) {
        code.add("li " + rd + ", " + rs);
      } else {
        code.add("move " + rd + ", " + rs);
      }
  }

  public void shiftLeft(String rt, String rs, String offset) {
    code.add("sra " + rt + ", " + rs + ", " + offset);
  }
  
  public void shiftRight(String rt, String rs, String offset) {
    code.add("sll " + rt + ", " + rs + ", " + offset);
  }
  public void loadByte(String rt, String rs, String offset) {
    code.add("lb " + rt + ", " + offset + "(" + rs + ")");
  }
  public void loadHalfword(String rt, String rs, String offset) {
    code.add("lh " + rt + ", " + offset + "(" + rs + ")");
  }

  public void loadWord(String rt, String rs, String offset) {
    code.add("lw " + rt + ", " + offset + "(" + rs + ")");
  }
  public void loadByteUnsigned(String rt, String rs, String offset) {
    code.add("lbu " + rt + ", " + offset + "(" + rs + ")");
  }
  public void loadHalfwordUnsigned(String rt, String rs, String offset) {
    code.add("lhu " + rt + ", " + offset + "(" + rs + ")");
  }
  public void loadWordRight(String rt, String rs, String offset) {
    code.add("lwr " + rt + ", " + offset + "(" + rs + ")");
  }
  public void storeByte(String rt, String rs, String offset) {
    code.add("sb " + rt + ", " + offset + "(" + rs + ")");
  }
  public void storeHalfword(String rt, String rs, String offset) {
    code.add("sh " + rt + ", " + offset + "(" + rs + ")");
  }
  public void storeWordLeft(String rt, String rs, String offset) {
    code.add("swl " + rt + ", " + offset + "(" + rs + ")");
  }
  public void storeWord(String rt, String rs, String offset) {
    code.add("sw " + rt + ", " + offset + "(" + rs + ")");
  }
  public void storeWordRight(String rt, String rs, String offset) {
    code.add("swr " + rt + ", " + offset + "(" + rs + ")");
  }

  public void add(String rd, String rs, String rt) {
    code.add("add " + rd + ", " + rs + ", " + rt);
  }
  public void addUnsigned(String rd, String rs, String rt) {
    code.add("addu " + rd + ", " + rs + ", +" + rt);
  }
  public void subtract(String rd, String rs, String rt) {
    code.add("sub " + rd + ", " + rs + ", +" + rt);
  }
  public void subtractUnsigned(String rd, String rs, String rt) {
    code.add("subu " + rd + ", " + rs + ", " + rt);
  }
  public void and(String rd, String rs, String rt) {
    code.add("and " + rd + ", " + rs + ", " + rt);
  }
  public void or(String rd, String rs, String rt) {
    code.add("or " + rd + ", " + rs + ", " + rt);
  }
  public void exclusiveOr(String rd, String rs, String rt) {
    code.add("xor " + rd + ", " + rs + ", " + rt);
  }
  public void nor(String rd, String rs, String rt) {
    code.add("nor " + rd + ", " + rs + ", " + rt);
  }
  public void setonLessThan(String rd, String rs, String rt) {
    code.add("slt " + rd + ", " + rs + ", " + rt);
  }
  public void setonLessThanUnsigned(String rd, String rs, String rt) {
    code.add("sltu " + rd + ", " + rs + ", " + rt);
  }
  public void addImmediate(String rd, String rs, String rt) {
    code.add("addi " + rd + ", " + rs + ", " + rt);
  }
  public void addImmediateUnsigned(String rd, String rs, String rt) {
    code.add("addiu " + rd + ", " + rs + ", " + rt);
  }
  public void setonLessThanImmediate(String rd, String rs, String rt) {
    code.add("slti " + rd + ", " + rs + ", " + rt);
  }
  public void setonLessThanImmediateUnsigned(String rd, String rs, String rt) {
    code.add("sltiu " + rd + ", " + rs + ", " + rt);
  }
  public void andImmediate(String rd, String rs, String rt) {
    code.add("andi " + rd + ", " + rs + ", " + rt);
  }
  public void orImmediate(String rd, String rs, String rt) {
    code.add("ori " + rd + ", " + rs + ", " + rt);
  }
  public void exclusiveOrImmediate(String rd, String rs, String rt) {
    code.add("xori " + rd + ", " + rs + ", " + rt);
  }
  public void loadUpperImmediate(String rd, String rs, String rt) {
    code.add("lui " + rd + ", " + rs + ", " + rt);
  }
  public void movefromHI(String rd) {
    code.add("mfhi " + rd);
  }
  public void movetoHI(String rd) {
    code.add("mthi " + rd);
  }
  public void movefromLO(String rd) {
    code.add("mflo " + rd);
  }
  public void movetoLO(String rd) {
    code.add("mtlo " + rd);
  }
  public void multiply(String rd, String rs, String rt) {
    code.add("mult " + rd + ", " + rs + ", " + rt);
  }
  public void multiplyUnsigned(String rd, String rs, String rt) {
    code.add("multu " + rd + ", " + rs + ", " + rt);
  }
  public void divide(String rd, String rs, String rt) {
    code.add("div " + rd + ", " + rs + ", " + rt);
  }
  public void divideUnsigned(String rd, String rs, String rt) {
    code.add("divu " + rd + ", " + rs + ", " + rt);
  }

  public void jumpRegister(String rd) {
    code.add("jr   " + rd);
  }
  public void jumpandLinkRegister(String rd) {
    code.add("jalr " + rd );
  }
  public void branchonLessThanZero(String rd, String rs) {
    code.add("bltz " + rd + ", " + rs );
  }
  public void branchonGreaterThanorEqualtoZero(String rd, String rs) {
    code.add("bgez " + rd + ", " + rs);
  }
  public void branchonLessThanZeroandLink(String rd, String rs) {
    code.add("bltzal " + rd + ", " + rs );
  }
  public void branchonGreaterThanorEqualtoZeroandLink(String rd, String rs) {
    code.add("bgezal " + rd + ", " + rs);
  }
  public void jump(String rd) {
    code.add("j   " + rd);
  }
  public void jumpandLink(String rd) {
    code.add("jal " + rd);
  }
  public void branchonEqual(String rd, String rs, String rt) {
    code.add("beq " + rd + ", " + rs + ", " + rt);
  }
  public void branchonNotEqual(String rd, String rs, String rt) {
    code.add("bne " + rd + ", " + rs + ", " + rt);
  }
  public void branchonLessThanorEqualtoZero(String rd, String rs) {
    code.add("blez " + rd + ", " + rs);
  }
  public void branchonGreaterThanZero(String rd, String rs) {
    code.add("bgtz " + rd + ", " + rs);
  }
  public void label(String label) {
    code.add(label + ":");
  }
}

public enum Register {
    T0("t0"),
    T1("t1"),
    T2("t2"),
    T3("t3"),
    T4("t4"),
    T5("t5"),
    T6("t6"),
    T7("t7"),
    T8("t8"),
    T9("t9"),
    SP("sp");
    String str;
    private Register(String str) {
      this.str = str;
    }
    public String toString() {
       return str; 
    }
}