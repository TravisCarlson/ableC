grammar edu:umn:cs:melt:ableC:abstractsyntax:overload;

abstract production unaryOpExpr
top::Expr ::= op::UnaryOp  e::Expr
{
  top.pp = if op.preExpr
           then parens( cat( op.pp, e.pp ) )
           else parens( cat( e.pp, op.pp ) );
  
  top.typerep = addQualifiers(op.collectedTypeQualifiers, forward.typerep);
  op.op = e;
  
  forwards to
    case op.unaryProd of
      just(prod) -> prod(e, top.location)
    | nothing()  -> unaryOpExprDefault(op, e, location=top.location)
    end;
}
abstract production dereferenceExpr
top::Expr ::= e::Expr
{
  top.pp = parens(cat(text("*"), e.pp));

  local baseExpr :: Expr =
    case getDereferenceOverload(e.typerep, top.env) of
      just(prod) -> prod(e, top.location)
    | nothing()  -> dereferenceExprDefault(e, location=top.location)
    end;
  baseExpr.env = top.env;
  baseExpr.returnType = top.returnType;

  forwards to baseExpr;
}
abstract production explicitCastExpr
top::Expr ::= ty::TypeName  e::Expr
{
  top.pp = parens( ppConcat([parens(ty.pp), e.pp]) );

  local baseExpr :: Expr = explicitCastExprDefault(ty, e, location=top.location);
  baseExpr.env = top.env;
  baseExpr.returnType = top.returnType;

  forwards to baseExpr;
}
abstract production arraySubscriptExpr
top::Expr ::= lhs::Expr  rhs::Expr
{
  top.pp = parens( ppConcat([ lhs.pp, brackets( rhs.pp )]) );

  forwards to
    case getArraySubscriptOverload(lhs.typerep, top.env) of
      just(prod) -> prod(lhs, rhs, top.location)
    | nothing()  -> arraySubscriptExprDefault(lhs, rhs, location=top.location)
    end;
}
abstract production callExpr
top::Expr ::= f::Expr  a::Exprs
{
  top.pp = parens( ppConcat([ f.pp, parens( ppImplode( cat( comma(), space() ), a.pps ))]) );
  
  a.env = addEnv(f.defs, f.env);
  -- Option 1: Apply a member to arguments (e.g. a.foo(b))
  local option1::Maybe<Expr> = 
    case f of
      memberExpr(l, d, r) ->
        applyMaybe5(getMemberCallOverload(l.typerep, top.env), l, d, r, a, top.location)
    | _ -> nothing()
    end;
  -- Option 2: Normal overloaded application
  local option2::Maybe<Expr> = applyMaybe3(getCallOverload(f.typerep, top.env), f, a, top.location);
  
  forwards to
    if      option1.isJust then option1.fromJust
    else if option2.isJust then option2.fromJust
    else callExprDefault(f, a, location=top.location);
}
abstract production memberExpr
top::Expr ::= lhs::Expr  deref::Boolean  rhs::Name
{
  top.pp = parens(ppConcat([lhs.pp, text(if deref then "->" else "."), rhs.pp]));

  -- get overload function from under pointer if dereferencing
  local ty :: Type =
    if deref
    then case lhs.typerep.withoutAttributes of
           pointerType(_, sub) -> sub
         | _                   -> lhs.typerep
         end
    else lhs.typerep;

  local baseExpr :: Expr =
    case getMemberOverload(ty, top.env) of
      just(prod) -> prod(lhs, deref, rhs, top.location)
    | nothing()  -> memberExprDefault(lhs, deref, rhs, location=top.location)
    end;
  baseExpr.env = top.env;
  baseExpr.returnType = top.returnType;

  forwards to baseExpr;
}
abstract production addExpr
top::Expr ::= lhs::Expr  rhs::Expr
{
  production attribute lhsRuntimeConversions :: [(Expr ::= Expr)] with ++;
  lhsRuntimeConversions := [];

  production attribute rhsRuntimeConversions :: [(Expr ::= Expr)] with ++;
  rhsRuntimeConversions := [];

  top.pp = parens( ppConcat([lhs.pp, space(), text("+"), space(), rhs.pp]) );

  top.collectedTypeQualifiers := [];
  top.typerep = addQualifiers(top.collectedTypeQualifiers, forward.typerep);

  local convertedLhs :: Expr =
    foldr(\f::(Expr ::= Expr)  e::Expr -> f(e), lhs, lhsRuntimeConversions);
  convertedLhs.env = top.env;
  convertedLhs.returnType = top.returnType;

  local convertedRhs :: Expr =
    foldr(\f::(Expr ::= Expr)  e::Expr -> f(e), rhs, rhsRuntimeConversions);
  convertedRhs.env = addEnv(convertedLhs.defs, convertedLhs.env);
  convertedRhs.returnType = top.returnType;

  local baseExpr :: Expr =
    case getAddOverload(convertedLhs.typerep, convertedRhs.typerep, top.env) of
      just(prod) -> prod(convertedLhs, convertedRhs, top.location)
    | nothing()  -> addExprDefault(convertedLhs, convertedRhs, location=top.location)
    end;
  baseExpr.env = top.env;
  baseExpr.returnType = top.returnType;

  forwards to baseExpr;
}
abstract production subtractExpr
top::Expr ::= lhs::Expr  rhs::Expr
{
  production attribute lhsRuntimeConversions :: [(Expr ::= Expr)] with ++;
  lhsRuntimeConversions := [];

  production attribute rhsRuntimeConversions :: [(Expr ::= Expr)] with ++;
  rhsRuntimeConversions := [];

  top.pp = parens( ppConcat([lhs.pp, space(), text("-"), space(), rhs.pp]) );

  top.collectedTypeQualifiers := [];
  top.typerep = addQualifiers(top.collectedTypeQualifiers, forward.typerep);

  local convertedLhs :: Expr =
    foldr(\f::(Expr ::= Expr)  e::Expr -> f(e), lhs, lhsRuntimeConversions);
  convertedLhs.env = top.env;
  convertedLhs.returnType = top.returnType;

  local convertedRhs :: Expr =
    foldr(\f::(Expr ::= Expr)  e::Expr -> f(e), rhs, rhsRuntimeConversions);
  convertedRhs.env = addEnv(convertedLhs.defs, convertedLhs.env);
  convertedRhs.returnType = top.returnType;

  local baseExpr :: Expr =
    case getSubOverload(convertedLhs.typerep, convertedRhs.typerep, top.env) of
      just(prod) -> prod(convertedLhs, convertedRhs, top.location)
    | nothing()  -> subtractExprDefault(convertedLhs, convertedRhs, location=top.location)
    end;
  baseExpr.env = top.env;
  baseExpr.returnType = top.returnType;

  forwards to baseExpr;
}
abstract production binaryOpExpr
top::Expr ::= lhs::Expr  op::BinOp  rhs::Expr
{
  -- case op here is a potential problem, since that emits a dep on op->forward, which eventually should probably include env
  -- Find a way to do this that doesn't cause problems if an op forwards.
  top.pp = parens( ppConcat([ 
    {-case op, lhs.pp of
    | assignOp(eqOp()), cat(cat(text("("), lhsNoParens), text(")")) -> lhsNoParens
    | _, _ -> lhs.pp
    end-} lhs.pp, space(), op.pp, space(), rhs.pp ]) );

  top.typerep = addQualifiers(op.collectedTypeQualifiers, forward.typerep);

  local lhsWithRuntimeInsertions :: Expr =
    mkRuntimeInsertions(op.lhsRuntimeInsertions, lhs, lhs.typerep);
  local rhsWithRuntimeInsertions :: Expr =
    mkRuntimeInsertions(op.rhsRuntimeInsertions, rhs, rhs.typerep);
  lhsWithRuntimeInsertions.env = top.env;
  lhsWithRuntimeInsertions.returnType = top.returnType;

  rhs.env = addEnv(lhs.defs, lhs.env);
  op.lop = lhs;
  op.rop = rhs;
  
  -- Option 1: Assign to a member or subscript (e.g. a.foo = b, a[i] = b)
  local option1::Maybe<Expr> =
    case lhsWithRuntimeInsertions, op of
      arraySubscriptExpr(l, r), assignOp(aOp) ->
        applyMaybe5(getSubscriptAssignOverload(l.typerep, top.env), l, r, aOp, rhsWithRuntimeInsertions, top.location)
    | memberExpr(l, d, r), assignOp(aOp) ->
        applyMaybe6(getMemberAssignOverload(l.typerep, top.env), l, d, r, aOp, rhsWithRuntimeInsertions, top.location)
    | _, _ -> nothing()
    end;
  -- Option 2: Normal overloaded binary operators
  local option2::Maybe<Expr> = applyMaybe3(op.binaryProd, lhsWithRuntimeInsertions, rhsWithRuntimeInsertions, top.location);
  
  forwards to
    if      option1.isJust then option1.fromJust
    else if option2.isJust then option2.fromJust
    else binaryOpExprDefault(lhsWithRuntimeInsertions, op, rhsWithRuntimeInsertions, location=top.location);
}

function mkRuntimeInsertions
Expr ::= insertions::[(Expr ::= Expr)]  e::Expr  eTyperep::Type
{
  local tmpName :: Name = name("__runtime_tmp" ++ toString(genInt()), location=bogusLoc());
  local refTmp :: Expr = declRefExpr(tmpName, location=bogusLoc());

  return
    if null(insertions)
    then e
    else
      stmtExpr(
        foldStmt(
          [
          declStmt(variableDecls(
            [], nilAttribute(), eTyperep.baseTypeExpr,
            foldDeclarator([
              declarator(
                tmpName, eTyperep.typeModifierExpr,
                nilAttribute(), justInitializer(exprInitializer(e))
              )
            ])
          ))
          ] ++
          map(
            \i::(Expr ::= Expr) -> exprStmt(i(refTmp)),
            insertions
          )
        ),
        refTmp,
        location=bogusLoc()
      );
}

