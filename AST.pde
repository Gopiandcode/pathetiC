import java.util.List;

interface Visitor {
	Object visit(Object o);
	Object visit(Program v);
	Object visit(DeclStatement v);
	Object visit(ExprStatement v);
	Object visit(ForStatement v);
	Object visit(WhileStatement v);
	Object visit(IfStatement v);
	Object visit(BreakStatement v);
	Object visit(ElseControl v);
	Object visit(ConditionalElseControl v);
	Object visit(IdentifierExpression v);
	Object visit(NumberExpression v);
	Object visit(IncrExpression v);
	Object visit(DecrExpression v);
	Object visit(AssignExpression v);
	Object visit(NegExpression v);
	Object visit(TimesExpression v);
	Object visit(DivideExpression v);
	Object visit(AddExpression v);
	Object visit(SubExpression v);
	Object visit(LShiftExpression v);
	Object visit(RShiftExpression v);
	Object visit(AndExpression v);
	Object visit(OrExpression v);
	Object visit(LEComparisonExpression v);
	Object visit(LEQComparisonExpression v);
	Object visit(GEComparisonExpression v);
	Object visit(GEQComparisonExpression v);
	Object visit(EQComparisonExpression v);
}
abstract class Node {
	public abstract Object accept(Visitor v);	
}

//  Simple Language
//  program ::= statementlist $
class Program extends Node {
	List<Statement> statements;

	public Program(List<Statement> statements) { this.statements = statements; }

	public Object accept(Visitor v) {
		return v.visit(this);
	}

  public String toString() {
     StringBuilder builder = new StringBuilder();
     for(Statement statement : statements) {
        builder.append(statement.toString());
        builder.append("\n");
     }
     return builder.toString();
  }
}
//  statementlist ::= statement statementlist | ^
abstract class Statement extends Node {}

class DeclStatement extends Statement {
	String id;
	String type;
	Expression e;

	public DeclStatement(String id, String type, Expression e) { this.id = id; this.type = type; this.e = e; }

	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "DeclStatement{" +
				"id='" + id + '\'' +
				", type='" + type + '\'' +
				", e=" + e +
				'}';
	}
}


class ExprStatement extends Statement {
	Expression e;
	public ExprStatement(Expression e) { this.e = e; }
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "ExprStatement{" +
				"e=" + e +
				'}';
	}
}
class ForStatement extends Statement {
	DeclStatement initializer;
	Expression condExpr;
	Expression increment;
	List<Statement> body;
	public ForStatement(DeclStatement initializer, Expression condExpr, Expression increment, List<Statement> body) {
		this.initializer = initializer;
		this.condExpr = condExpr;
		this.increment = increment;
		this.body = body;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "ForStatement{" +
				"initializer=" + initializer +
				", condExpr=" + condExpr +
				", increment=" + increment +
				", body=" + body +
				'}';
	}
}
class WhileStatement extends Statement {
	Expression condExpr;
	List<Statement> body;
	public WhileStatement(Expression condExpr, List<Statement> body) {
		this.condExpr = condExpr;
		this.body = body;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "WhileStatement{" +
				"condExpr=" + condExpr +
				", body=" + body +
				'}';
	}
}

class IfStatement extends Statement {
	Expression condExpr;
	List<Statement> body;
	ConditionalControl control;
	public IfStatement(Expression condExpr, List<Statement> body, ConditionalControl control) {
		this.condExpr = condExpr;
		this.body = body;
		this.control = control;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "IfStatement{" +
				"condExpr=" + condExpr +
				", body=" + body +
				", control=" + control +
				'}';
	}
}

class BreakStatement extends Statement {
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "BreakStatement{}";
	}
}


abstract class ConditionalControl extends Node { }

class ElseControl extends ConditionalControl {
	List<Statement> body;

	public ElseControl(List<Statement> body) {
		this.body = body;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "ElseControl{" +
				"body=" + body +
				'}';
	}
}

class ConditionalElseControl extends ConditionalControl {
	Expression cond;
	List<Statement> body;
	ConditionalControl control;

	public ConditionalElseControl(Expression cond, List<Statement> body, ConditionalControl control) {
		this.cond = cond;
		this.body = body;
		this.control = control;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "ConditionalElseControl{" +
				"cond=" + cond +
				", body=" + body +
				", control=" + control +
				'}';
	}
}


abstract class Expression extends Node { }
class IdentifierExpression extends Expression {
	String id;	
	public IdentifierExpression(String id) {
		this.id = id;
	}

  public Object accept(Visitor v) {
    return v.visit(this);
  }

	@java.lang.Override
	public java.lang.String toString() {
		return "IdentifierExpression{" +
				"id='" + id + '\'' +
				'}';
	}
}
class NumberExpression extends Expression {
	String number;
	public NumberExpression(String number) {
		this.number = number;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "NumberExpression{" +
				"number='" + number + '\'' +
				'}';
	}
}
class IncrExpression extends Expression {
	boolean isPre;
	String id;
	public IncrExpression(String id, boolean isPre) {
		this.id = id;
		this.isPre = isPre;
	}

	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "IncrExpression{" +
				"isPre=" + isPre +
				", id='" + id + '\'' +
				'}';
	}
}
class DecrExpression extends Expression {
	boolean isPre;
	String id;

	public DecrExpression(String id, boolean isPre) {
		this.id = id;
		this.isPre = isPre;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "DecrExpression{" +
				"isPre=" + isPre +
				", id='" + id + '\'' +
				'}';
	}
}

class AssignExpression extends Expression {
	String id;
	Expression e;
	String assignType;

	public AssignExpression(String id, Expression e, String assignType) {
		this.id = id;
		this.e = e;
		this.assignType = assignType;	
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "AssignExpression{" +
				"id='" + id + '\'' +
				", e=" + e +
				", assignType='" + assignType + '\'' +
				'}';
	}
}

class NegExpression extends Expression {
	Expression e;
	public NegExpression(Expression e) {
		this.e = e;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "NegExpression{" +
				"e=" + e +
				'}';
	}
}

abstract class OperatorExpression extends Expression { Expression e1; Expression e2; }
class TimesExpression extends OperatorExpression {
	@java.lang.Override
	public java.lang.String toString() {
		return "TimesExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}

	public TimesExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

}
class DivideExpression extends OperatorExpression {
	public DivideExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "DivideExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}
class AddExpression extends OperatorExpression {
	public AddExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "AddExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

class SubExpression extends OperatorExpression {
	public SubExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "SubExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

class LShiftExpression extends OperatorExpression {
	public LShiftExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "LShiftExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

class RShiftExpression extends OperatorExpression {
	public RShiftExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "RShiftExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

class AndExpression extends OperatorExpression {
	public AndExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "AndExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

class OrExpression extends OperatorExpression {
	public OrExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "OrExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

abstract class ComparisonExpression extends OperatorExpression {}
class LEComparisonExpression extends OperatorExpression {
	public LEComparisonExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "LEComparisonExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}
class LEQComparisonExpression extends OperatorExpression {
	public LEQComparisonExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "LEQComparisonExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}
class GEComparisonExpression extends OperatorExpression {
	public GEComparisonExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "GEComparisonExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}
class GEQComparisonExpression extends OperatorExpression {
	public GEQComparisonExpression(Expression e1, Expression e2) {
		super.e1 = e1;
		super.e2 = e2;
	}
	public Object accept(Visitor v) {
		return v.visit(this);
	}

	@java.lang.Override
	public java.lang.String toString() {
		return "GEQComparisonExpression{" +
				"e1=" + e1 +
				", e2=" + e2 +
				'}';
	}
}

class EQComparisonExpression extends OperatorExpression {
  public EQComparisonExpression(Expression e1, Expression e2) {
    super.e1 = e1;
    super.e2 = e2;
  }
  public Object accept(Visitor v) {
    return v.visit(this);
  }

  @java.lang.Override
  public java.lang.String toString() {
    return "EQComparisonExpression{" +
        "e1=" + e1 +
        ", e2=" + e2 +
        '}';
  }
}