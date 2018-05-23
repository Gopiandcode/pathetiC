# pathetiC
## It was all a MIPStake.

Just a simple little compiler for a "pathetic" subset of C (not even turing complete) - outputs MIPS assembly.

The language supports while, for ifs and and most basic operations. There is only one type - int. 

The language is almost turing complete, it's equivalent to a linear bounded automata, but lacks arrays so whoops.

Uses Three address code internally to represent the input source code.


## Example run
Consider the following program to calculate fibonnaci numbers:
```
int i = 0; 
int j = 0;
int k = 1;

while(i < 10) {
	int t = j + k;
	j = k;
	k = t;
}
```

Once parsed, produces the following three address code:
```
i = 0
j = 0
k = 1
label flag0:
	t0 = i LE 10
	fjump t0 flag1
	t1 = j ADD k
	t = t1
	j = k
	k = t
	jump flag0
label flag1:
```

Which is then converted into the following mips code:
```
li $t0, 0
li $t1, 0
li $t2, 1
flag0:
	slt $t3, $t0, 10
	beq $t3, 0, flag1
	beq $t0, 10, flag1
	add $t4, $t1, $t2
	li $t1, $t2
	li $t2, $t4
	j flag0
flag1:
```


## Uses

So what on earth could this be used for?
Nothing. It's a toy project. 
Jk, it should have at least some utility, right?.

 - Well, it does provide a nice small AST perfect for use in building code generation related machine learning experiments.
 - Potentially could provide a nice spring board for trying out super optimization.

But, at the moment, it's really buggy, so it's not that useful.


## AST

The AST for the program is as follows:
```
  program ::= statement program 
	|
  statement ::= INT ID = expression ;
              | expression ;
              | FOR ( INT ID = expression ; condExpr ; expression ) body
              | WHILE ( condExpr ) body
              | IF ( condExpr ) body conditionalControl
              | Break ;
  conditionalControl ::= ^
                       | ELSE body
                       | ELIF ( condExpr ) body conditionalControl

  body ::= { statementlist }
  inplaceAssign ::= += | *= | -= | = 
  baseValue ::= ID baseValueEnd | NUMBER baseValueEnd | ( expression ) baseValueEnd | - baseValue baseValueEnd | -- baseValue | ++ baseValue
  baseValueEnd = inplaceAssign baseValue baseValueEnd
      | ++
      | --
      | 
  factor ::= baseValue factorEnd
  factorEnd ::= * baseValue factorEnd
              | / baseValue factorEnd
              | ^
  term ::= factor termEnd
  termEnd ::= + factor termEnd
            | - factor termEnd
            | << factor termEnd
            | >> factor termEnd
            | ^
  condExpr ::= term condExprEnd
  condExprEnd ::= && term condExprEnd
                | || term condExprEnd
                | < term condExprEnd
                | > term condExprEnd
                | >= term condExprEnd
                | <= term condExprEnd
                | ^
   expression ::= condExpr
 
```



