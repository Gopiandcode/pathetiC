import java.util.Hashtable;
import java.util.regex.*;  
import java.util.*;
public class Generator {
  NextUseAnalyzer analyzer;
  List<String> result = new ArrayList<String>();
  List<Quadruple> items;
  MIPSSynthesizer synthesizer = new MIPSSynthesizer();
  int translatedIndex = 0;


  public Generator(List<Quadruple> code) {
    analyzer = new NextUseAnalyzer(code); 
    items = code;
  }

  public String toString() {
    return synthesizer.toString();
  }

  public void generate() {
    TACType comparisonType = null;
    String comparisonA1 = null;
    String comparisonA2 = null;
    String comparisonResult = null;
    for (int i = 0; i < items.size(); i++) {
      Quadruple op = items.get(i);
      String a1 = op.a1;
      String a2 = op.a2;
      String result = op.result;
      java.util.function.Predicate numeric = Pattern.compile("[0-9]+").asPredicate();

      switch(op.type) {
      case ADD:
      case SUB:
      case MUL:
      case DIV:
      case LSHIFT:
      case RSHIFT:
      case LEQ:
      case LE:
      case GEQ:
      case GE:
      case EQ:
        if (!numeric.test(a1)) {
          a1 = "$" + analyzer.moveToRegister(a1, synthesizer).toString();
        }
        if (!numeric.test(a2)) {
          a2 = "$" + analyzer.moveToRegister(a2, synthesizer).toString();
        }
        result = "$" + analyzer.moveToRegister(result, synthesizer).toString();
        comparisonType = op.type;
        comparisonA1 = a1;
        comparisonA2 = a2;
        comparisonResult = result;
        break;
      case ASSIGN:
      case NEG:
        if (!numeric.test(a1)) {
          a1 = "$" + analyzer.moveToRegister(a1, synthesizer).toString();
        }
        result = "$" + analyzer.moveToRegister(result, synthesizer).toString();
        break;
      case FJUMP:
      case TJUMP:
        if (!numeric.test(a1)) {
          a1 = "$" + analyzer.moveToRegister(a1, synthesizer).toString();
        }

        break;
      case LABEL:
      case JUMP:
        break;
      }


      switch(op.type) {
      case ADD:
        synthesizer.add(result, a1, a2);
        break;
      case SUB:
        synthesizer.subtract(result, a1, a2);
        break;
      case MUL:
        synthesizer.multiply(result, a1, a2);
        break;
      case DIV:
        synthesizer.divide(result, a1, a2);
        break;
      case ASSIGN:
        synthesizer.assign(result, a1);
        break;
      case LSHIFT:
        synthesizer.shiftLeft(result, a1, a2);
        break;
      case RSHIFT:
        synthesizer.shiftRight(result, a1, a2);
        break;
      case LEQ:
      case LE:
      case GEQ:
      case GE:
        synthesizer.setonLessThan(result, a1, a2);
        break;
      case NEG:
        synthesizer.subtract(result, "0", a1);
        break;
      case EQ:
        break;
      case FJUMP:
        switch(comparisonType) {
        case LEQ:
          synthesizer.branchonEqual(comparisonResult, "0", result);
          break;
        case LE:
          synthesizer.branchonEqual(comparisonResult, "0", result);
          synthesizer.branchonEqual(comparisonA1, comparisonA2, result);
          break;
        case GEQ:
          synthesizer.branchonEqual(comparisonResult, "1", result);
          break;
        case GE:
          synthesizer.branchonEqual(comparisonResult, "1", result);
          synthesizer.branchonEqual(comparisonA1, comparisonA2, result);
          break;
        case EQ:
          synthesizer.branchonNotEqual(comparisonA1, comparisonA2, result);
          break;
        default:
          System.err.println("Non boolean operand to conditional. Ignoring statement.");
          break;
        }
        break;
      case TJUMP:
        switch(comparisonType) {
        case LEQ:
          synthesizer.branchonEqual(comparisonResult, "1", result);
          synthesizer.branchonEqual(comparisonA1, comparisonA2, result);
          break;
        case LE:
          synthesizer.branchonEqual(comparisonResult, "1", result);
          break;
        case GEQ:
          synthesizer.branchonEqual(comparisonResult, "0", result);
          synthesizer.branchonEqual(comparisonA1, comparisonA2, result);
          break;
        case GE:
          synthesizer.branchonEqual(comparisonResult, "0", result);
          break;
        case EQ:
          synthesizer.branchonEqual(comparisonA1, comparisonA2, result);
          break;
        default:
          System.err.println("Non boolean operand to conditional. Ignoring statement.");
          break;
        }

        break;
      case LABEL:
        synthesizer.label(a1);
        break;
      case JUMP:
        synthesizer.jump(result);
        break;
      }
      analyzer.moveToNextLine();
    }
  }
}


public class NextUseAnalyzer {
  // iterate through quadruples, 
  // collate all identifiers
  Hashtable<String, List<Boolean>> nextuse = new Hashtable<String, List<Boolean>>(); 

  Hashtable<String, Register> identifierMap = new Hashtable<String, Register>();  // maps identifiers to registers
  Hashtable<Register, String> registerMap = new Hashtable<Register, String>();  // maps registers to code

  Queue<Register> lastUsedRegister = new ArrayDeque<Register>(); // last used registers

  Queue<Register> unusedRegisters = new ArrayDeque<Register>();
  List<String> memoryMap = new ArrayList<String>();  // maps identifiers to stack order
  int currentLine = 0;
  int codeLength;

  // when moving objects, we need to 
  // update identifiermap to store the new location of the variable
  // update registermap, to update the values stored in the register
  // update lastusedregister to record the last used register
  // update unusedregisters to refer to any unused registers
  // update memory map to reflect variables in memory

  // finds a free register, moving variables to memory if necassary
  public Register findFreeRegister(MIPSSynthesizer synthesizer) {
    // if we have an unused register, return it
    if (unusedRegisters.size() != 0) 
      return unusedRegisters.poll();

    // no free registers, so move an old variable to memory
    Register lastRegister = lastUsedRegister.poll(); // get the last used register
    String variable = registerMap.get(lastRegister);  // get the variable stored in the last used register
    int index = 0;
    for (String s : memoryMap) {
      if (s.isEmpty()) {
        break;
      }
      index++;
    }


    // when moving objects, we need to 
    // update identifiermap to store the new location of the variable
    // sp means that the variable is stored in memory rather than a register
    identifierMap.put(variable, Register.SP);

    // remove the corresponding entry for the register map, as we have just moved the entry out of it
    registerMap.remove(lastRegister);

    // update lastusedregister to specify this register as the last register
    lastUsedRegister.add(lastRegister);

    // update unusedregisters to refer to any unused registers
    // nothing to do, as this only runs if there are no unused registers

    if (index >= memoryMap.size()) {
      // update memory map to reflect variables in memory 
      memoryMap.add(variable);
    } else {
      memoryMap.set(index, variable);
      // when moving objects, we need to 
      // update identifiermap to store the new location of the variable
      // update registermap, to update the values stored in the register
      // update lastusedregister to record the last used register
      // update unusedregisters to refer to any unused registers
      // update memory map to reflect variables in memory
    }

    // store the  register to memory location
    synthesizer.storeWord(lastRegister.toString(), Register.SP.toString(), "" + (index * 4));
    // return the register,
    return lastRegister;
  }

  // moves a variable to a register
  public Register moveToRegister(String id, MIPSSynthesizer synthesizer) { //<>//
    Register r = identifierMap.get(id); //<>//
    if (r == null) {
      r = findFreeRegister(synthesizer);

      // when moving objects, we need to 
      // update identifiermap to store the new location of the variable
      identifierMap.put(id, r);
      // update registermap, to update the values stored in the register
      registerMap.put(r, id);
      // update lastusedregister to record the last used register
      lastUsedRegister.add(r);
      // update unusedregisters to refer to any unused registers
      // update memory map to reflect variables in memory
      return r;
    } else {
      if (r != Register.SP)
        return r;
      else {
        // variable exists, but stored in memory
        // needs to be retrieved
        
        // find the offset at which it is stored from sp
        int index = 0;
        for (String s : memoryMap) {
          if (s.equals(id)) {
            break;
          }
          index++;
        }
        
        // find a free register
      r = findFreeRegister(synthesizer);

      // when moving objects, we need to 
      // update identifiermap to store the new location of the variable
      identifierMap.put(id, r);
      // update registermap, to update the values stored in the register
      registerMap.put(r, id);
      // update lastusedregister to record the last used register
      lastUsedRegister.add(r);
      
      
      // clear the old memory location, and flag for potential reuse
      memoryMap.set(index, "");
        // generate a move operation to the new location
        synthesizer.loadWord("$" + r, "$" + Register.SP, "" + (index * 4));
        return r;
      }
      
    }
  }

  public void moveToNextLine() {
    // moves current instruction to next line, free all unused registers
    currentLine++;
    if (currentLine < codeLength) {

      for (String id : new ArrayList<String>(identifierMap.keySet())) {
        if (nextuse.get(id) != null && nextuse.get(id).size() > currentLine && !nextuse.get(id).get(currentLine)) {
          // if a variable is dead remove it

          // update identifiermap to store the new location of the variable
          Register r = identifierMap.get(id);
          identifierMap.remove(id);
          // update registermap, to update the values stored in the register
          registerMap.remove(r);
          // update lastusedregister to record the last used register
          // update unusedregisters to refer to any unused registers
          unusedRegisters.add(r);
          // update memory map to reflect variables in memory
        }
      }
    }
  }


  void populateInitialFreeRegisters() {
    unusedRegisters.add(Register.T0);
    unusedRegisters.add(Register.T1);
    unusedRegisters.add(Register.T2);
    unusedRegisters.add(Register.T3);
    unusedRegisters.add(Register.T4);
    unusedRegisters.add(Register.T5);
    unusedRegisters.add(Register.T6);
    unusedRegisters.add(Register.T7);
    unusedRegisters.add(Register.T8);
    unusedRegisters.add(Register.T9);
  }
  public NextUseAnalyzer(List<Quadruple> code) {
    populateInitialFreeRegisters();
    // generates the next use info
    int instructions = 0;
    codeLength = code.size();
    for (int i = code.size()-1; i >= 0; i--) {
      Quadruple tuple = code.get(i);
      switch(tuple.type) {
      case FJUMP: 
      case TJUMP:
      case LABEL:
      case JUMP:
        instructions++;
        continue;
      default:
        break;
      }

      java.util.function.Predicate numeric = Pattern.compile("[0-9]+").asPredicate();
      List<String> values = Arrays.asList(tuple.a1, tuple.a2, tuple.result);
      for (String value : values) {
        if (value != null && !value.isEmpty()) {
          if (!numeric.test(value)) {
            List<Boolean> nextUseInfo = nextuse.get(value);
            if (nextUseInfo == null) {
              nextUseInfo = new ArrayList<Boolean>();
            }
            boolean lastvalue = false;
            if (nextUseInfo.size() != 0) {
              lastvalue = nextUseInfo.get(nextUseInfo.size() - 1);
            }
            for (int k = nextUseInfo.size(); k < instructions; k++) {
              nextUseInfo.add(lastvalue);
            }
            nextUseInfo.add(true);
            nextuse.put(value, nextUseInfo);
          }
        }
      }


      instructions++;
    }
    for (String id : nextuse.keySet()) {
      Collections.reverse(nextuse.get(id));
    }
  }
}