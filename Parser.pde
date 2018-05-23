class ParserState {
	int position;
	List<Token> tokenstream;

	public ParserState(List<Token> tokenstream) {
		this.position = 0;
		this.tokenstream = tokenstream;
	}

	TokenType lookahead() {
		if(position < tokenstream.size())
			return tokenstream.get(position).t;
		else
			return TokenType.EOF;
	}
	Token getToken() {
		if(position < tokenstream.size())
			return tokenstream.get(position);
		else
			return null;
	}

	void consume() {
		position += 1;
	}
}
List<Statement> parseStatementList(ParserState st, TokenType endToken) {
	List<Statement> statements = new ArrayList<Statement>();
	while(st.lookahead() != endToken) {
		Statement statement = parseStatement(st);
		if(statement == null)
			return statements;
		statements.add(statement);
	}
	return statements;
}

Program parseProgram(ParserState st) {
	return new Program(parseStatementList(st, TokenType.EOF));
}

//  statement ::= INT ID = expression ;
//              | expression ;
//              | FOR ( INT ID = expression ; condExpr ; expression ) body
//              | WHILE ( condExpr ) body
//              | IF ( condExpr ) body conditionalControl
//              | Break
//  conditionalControl ::= ^
//                       | ELSE body
//                       | ELIF ( condExpr ) body conditionalControl
//
//  body ::= { statementlist }
Statement parseStatement(ParserState st) {
	if(st.lookahead() == TokenType.INT) {
		return parseDeclStatement(st);
	} else if(st.lookahead() == TokenType.FOR)
		return parseForStatement(st);
	else if(st.lookahead() == TokenType.IF)
		return parseIfStatement(st);
	else if(st.lookahead() == TokenType.BREAK)
		return parseBreakStatement(st);
	else if(st.lookahead() == TokenType.WHILE)
		return parseWhileStatement(st);
	else
		return parseExpressionStatement(st);
}

Statement parseBreakStatement(ParserState st) {
//    println("Attempting to parse parseBreakStatement w. lookahead: " + st.lookahead());
	if(st.lookahead() != TokenType.BREAK)
		return null;
	st.consume();
	if(st.lookahead() != TokenType.SEMI)
		return null;
	st.consume();
	
	return new BreakStatement();
}

Statement parseIfStatement(ParserState st) {
//	println("Attempting to parse parseIfStatement w. lookahead: " + st.lookahead());
// IF ( condExpr ) body conditionalControl
	if(st.lookahead() != TokenType.IF)
		return null;
	st.consume();

	if(st.lookahead() != TokenType.LPAREN)
		return null;
	st.consume();

	Expression cond = parseExpression(st, TokenType.RPAREN);
	if(cond == null) 
		return null;

	if(st.lookahead() != TokenType.RPAREN)
		return null;
	st.consume();

	if(st.lookahead() != TokenType.LBRACE)
		return null;
	st.consume();

	List<Statement> body = parseStatementList(st, TokenType.RBRACE);
	if(body == null) 
		return null;

	
	if(st.lookahead() != TokenType.RBRACE) return null;
	st.consume();

	ConditionalControl control = null;
	if(st.lookahead() == TokenType.ELSE || st.lookahead() == TokenType.ELIF) {
		control = parseIfControl(st);
	}

	return new IfStatement(cond, body, control);
}

ConditionalControl parseIfControl(ParserState st) {
//	println("Attempting to parse parseIfControl w. lookahead: " + st.lookahead());
//  conditionalControl ::= ^
//                       | ELSE body
//                       | ELIF ( condExpr ) body conditionalControl
List<Statement> body;	
switch(st.lookahead()) {
		case ELSE:
			st.consume();
		if(st.lookahead() != TokenType.LBRACE)
			return null;
		st.consume();

		body = parseStatementList(st, TokenType.RBRACE);
		if(body == null) 
			return null;

		
		if(st.lookahead() != TokenType.RBRACE) return null;
		st.consume();
		return new ElseControl(body);

		case ELIF:
		st.consume();

		if(st.lookahead() != TokenType.LPAREN)
			return null;
		st.consume();

		Expression cond = parseExpression(st, TokenType.RPAREN);
		if(cond == null) 
			return null;

		if(st.lookahead() != TokenType.RPAREN)
			return null;
		st.consume();



		if(st.lookahead() != TokenType.LBRACE)
			return null;
		st.consume();

		 body = parseStatementList(st, TokenType.RBRACE);
		if(body == null) 
			return null;

		
		if(st.lookahead() != TokenType.RBRACE) return null;
		st.consume();
		ConditionalControl control = null;
		if(st.lookahead() == TokenType.ELSE || st.lookahead() == TokenType.ELIF) {
				control = parseIfControl(st);
		}

		return new ConditionalElseControl(cond, body, control);

		default:
			return null;
	}
}

Statement parseWhileStatement(ParserState st) {
//	println("Attempting to parse parseWhileStatement w. lookahead: " + st.lookahead());
// WHILE ( condExpr ) body
	if(st.lookahead() != TokenType.WHILE)
		return null;
	st.consume();

	if(st.lookahead() != TokenType.LPAREN)
		return null;
	st.consume();
	Expression cond = parseExpression(st, TokenType.RPAREN);
	if(cond == null) 
		return null;

	if(st.lookahead() != TokenType.RPAREN)
		return null;
	st.consume();

	if(st.lookahead() != TokenType.LBRACE)
		return null;
	st.consume();

	List<Statement> body = parseStatementList(st, TokenType.RBRACE);
	if(body == null) 
		return null;

	if(st.lookahead() != TokenType.RBRACE) return null;
	st.consume();

	return new WhileStatement(cond, body);
}

Statement parseForStatement(ParserState st) {
//	println("Attempting to parse parseForStatement w. lookahead: " + st.lookahead());
// FOR ( INT ID = expression ; condExpr ; expression ) body
//
	if(st.lookahead() != TokenType.FOR)
		return null;
	st.consume();

	if(st.lookahead() != TokenType.LPAREN)
		return null;
	st.consume();

	DeclStatement decl = (DeclStatement) parseDeclStatement(st);
	if(decl == null)
		return null;

	Expression cond = parseExpression(st, TokenType.SEMI);
	if(cond == null)
		return null;

	if(st.lookahead() != TokenType.SEMI)
		return null;
	st.consume();


	Expression incr = parseExpression(st, TokenType.RPAREN);
	if(incr == null) 
		return null;

	if(st.lookahead() != TokenType.RPAREN)
		return null;
	st.consume();

	if(st.lookahead() != TokenType.LBRACE)
		return null;
	st.consume();

	List<Statement> body = parseStatementList(st, TokenType.RBRACE);
	if(body == null) 
		return null;

	if(st.lookahead() != TokenType.RBRACE) return null;
	st.consume();

	return new ForStatement(decl, cond, incr, body);
}

Statement parseDeclStatement(ParserState st) {
//	println("Attempting to parse parseDeclStatement w. lookahead: " + st.lookahead());
	// INT ID = expression ;
	Token type = st.getToken();
  if(type == null) return null;
	if(type.t != TokenType.INT)
		return null;
	st.consume();

	Token id = st.getToken();
if(id == null) return null;
	if(id.t != TokenType.ID)
		return null;
	st.consume();

	Token assign = st.getToken();
  if(assign == null) return null;
	if(assign.t != TokenType.ASSIGN)
		return null;
	st.consume();

	Expression e = parseExpression(st, TokenType.SEMI);

	Token semi = st.getToken();
if(semi == null) return null;
	if(semi.t != TokenType.SEMI)
		return null;
	st.consume();
	return new DeclStatement(id.c, type.c, e);
}


Statement parseExpressionStatement(ParserState st) {
//	println("Attempting to parse parseExpressionStatement w. lookahead: " + st.lookahead());
	Expression e = parseExpression(st, TokenType.SEMI);
	if(st.lookahead() != TokenType.SEMI)
		return null;
	st.consume();
	return new ExprStatement(e);
}

Expression parseHighExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseHighExpression w. lookahead: " + st.lookahead());
	Expression e = null;
	if(st.lookahead() == TokenType.ID)
		e = parseAssignExpression(st, tk);
	else if(st.lookahead() == TokenType.NUMBER)
		e = parseNumericExpression(st, tk);
	else if(st.lookahead() == TokenType.LPAREN)
		e = parseExpression(st, TokenType.RPAREN);
	else if(st.lookahead() == TokenType.MINUS)
		e = parseNegExpression(st, tk);
	else if(st.lookahead() == TokenType.DECR)
		e = parseDecrExpression(st, tk);
	else if(st.lookahead() == TokenType.INCR)
		e = parseIncrExpression(st, tk);
	else return null;
	
	if(e == null)
		return null;

	while(st.lookahead() != tk) {
		switch(st.lookahead()) {
			case MUL:
				st.consume();
				e = new TimesExpression(e, parseHighExpression(st, tk));
break;
			case DIV:
				st.consume();
				e = new DivideExpression(e, parseHighExpression(st, tk));
break;
			case PLUS:
			case MINUS:
			case LSHIFT:
			case RSHIFT:
			case AND:
			case OR:
			case LE:
			case LEQ:
			case GE:
			case GEQ:
				return e;
			default:
				return e;
		}
	}
return e;
}

Expression parseAssignExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseAssignExpression w. lookahead: " + st.lookahead());
	if(st.lookahead() != TokenType.ID)
		return null;
	Token token = st.getToken();
	st.consume();
	if(st.lookahead()  == TokenType.INCR){
		Expression res = new IncrExpression(token.c, false);
		st.consume();
		return res;
	} else if(st.lookahead() ==TokenType.DECR) {
		Expression res = new DecrExpression(token.c, false);
		st.consume();
		return res;
	}

	Token type = st.getToken();
if(type == null) return null;
	if(type.t != TokenType.ASSIGN_ADD
			&& type.t != TokenType.ASSIGN_MULT
			&& type.t != TokenType.ASSIGN_DIV
			&& type.t != TokenType.ASSIGN_SUB && type.t != TokenType.ASSIGN)
		return new IdentifierExpression(token.c);
	st.consume();
	Expression expr = parseExpression(st,tk);
	return new AssignExpression(token.c, expr, type.c);
}

Expression parseNumericExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseNumericExpression w. lookahead: " + st.lookahead());
	if(st.lookahead() != TokenType.NUMBER)
		return null;
	Token tok = st.getToken();
	st.consume();	
	return new NumberExpression(tok.c);	
}

Expression parseNegExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseNegExpression w. lookahead: " + st.lookahead());
	if(st.lookahead() != TokenType.MINUS)
		return null;
	
	Expression expr = parseLittleExpression(st, tk);
	if(expr == null) return null;
	return new NegExpression(expr);
}

Expression parseDecrExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseDecrExpression w. lookahead: " + st.lookahead());
	if(st.lookahead() != TokenType.DECR)
		return null;
	st.consume();

  Token id = st.getToken();
    if(id == null)
    return null;
  if(id.t != TokenType.ID)
    return null;
  st.consume();
	return new DecrExpression(id.c, true);
}
Expression parseIncrExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseIncrExpression w. lookahead: " + st.lookahead());
	if(st.lookahead() != TokenType.INCR)
		return null;
	st.consume();

  Token id = st.getToken();
  if(id == null)
    return null;
  if(id.t != TokenType.ID)
    return null;
  st.consume();
  
	return new IncrExpression(id.c, true);
}

Expression parseLittleExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseLittleExpression w. lookahead: " + st.lookahead());
	Expression e = null;
	if(st.lookahead() == TokenType.ID)
		e = parseAssignExpression(st, tk);
	else if(st.lookahead() == TokenType.NUMBER)
		e = parseNumericExpression(st, tk);
	else if(st.lookahead() == TokenType.LPAREN)
		e = parseExpression(st, TokenType.RPAREN);
	else if(st.lookahead() == TokenType.MINUS)
		e = parseNegExpression(st, tk);
	else if(st.lookahead() == TokenType.DECR)
		e = parseDecrExpression(st, tk);
	else if(st.lookahead() == TokenType.INCR)
		e = parseIncrExpression(st, tk);
	else return null;
  return e;
}
	

Expression parseExpression(ParserState st, TokenType tk) {
//	println("Attempting to parse parseExpression w. lookahead: " + st.lookahead());
	Expression e = null;
	if(st.lookahead() == TokenType.ID)
		e = parseAssignExpression(st, tk);
	else if(st.lookahead() == TokenType.NUMBER)
		e = parseNumericExpression(st, tk);
	else if(st.lookahead() == TokenType.LPAREN) {
  st.consume();
		e = parseExpression(st, TokenType.RPAREN);
if(st.lookahead() != TokenType.RPAREN) return null;
st.consume();
}
	else if(st.lookahead() == TokenType.MINUS)
		e = parseNegExpression(st, tk);
	else if(st.lookahead() == TokenType.DECR)
		e = parseDecrExpression(st, tk);
	else if(st.lookahead() == TokenType.INCR)
		e = parseIncrExpression(st, tk);
	else return null;
	if(e == null)
		return null;
//  println("Parsed expression base with " + e);
	boolean shouldExit = false;
	while(st.lookahead() != tk) {
		switch(st.lookahead()) {
			case MUL:
				st.consume();
				e = new TimesExpression(e, parseHighExpression(st, tk));
break;
			case DIV:
				st.consume();
				e = new DivideExpression(e, parseHighExpression(st, tk));
break;
			case PLUS:
				st.consume();
				e = new AddExpression(e, parseExpression(st, tk));
break;
			case MINUS:
				st.consume();
				e = new SubExpression(e, parseExpression(st, tk));
break;
			case LSHIFT:
				st.consume();
				e = new LShiftExpression(e, parseExpression(st, tk));
break;
			case RSHIFT:
				st.consume();
				e = new RShiftExpression(e, parseExpression(st, tk));
break;
			case AND:
				st.consume();
				e = new AndExpression(e, parseExpression(st, tk));
break;

			case OR:
				st.consume();
				e = new OrExpression(e, parseExpression(st, tk));
break;
			case LE:
				st.consume();
				e = new LEComparisonExpression(e, parseExpression(st, tk));
break;

			case LEQ:
				st.consume();
				e = new LEQComparisonExpression(e, parseExpression(st, tk));
break;

			case GE:
				st.consume();
				e = new GEComparisonExpression(e, parseExpression(st, tk));
break;

			case GEQ:
				st.consume();
				e = new GEQComparisonExpression(e, parseExpression(st, tk));

break;
      case EQ:
        st.consume();
        e = new EQComparisonExpression(e, parseExpression(st, tk));

break;
			default:
shouldExit = true;
				break;
		}
if(shouldExit) break;
	}
//println("Finished parsing expression with " + e);
return e;
}


//  inplaceAssign ::= += | *= | -= | = 
//  baseValue ::= ID baseValueEnd | NUMBER baseValueEnd | ( expression ) baseValueEnd | - baseValue baseValueEnd | -- baseValue | ++ baseValue
//  baseValueEnd = inplaceAssign baseValue baseValueEnd
//      | ++
//      | --
//      | 
//  factor ::= baseValue factorEnd
//  factorEnd ::= * baseValue factorEnd
//              | / baseValue factorEnd
//              | ^
//  term ::= factor termEnd
//  termEnd ::= + factor termEnd
//            | - factor termEnd
//            | << factor termEnd
//            | >> factor termEnd
//            | ^
//  condExpr ::= term condExprEnd
//  condExprEnd ::= && term condExprEnd
//                | || term condExprEnd
//                | < term condExprEnd
//                | > term condExprEnd
//                | >= term condExprEnd
//                | <= term condExprEnd
//                | ^
//   expression ::= condExpr
// 