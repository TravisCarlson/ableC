grammar edu:umn:cs:melt:ableC:abstractsyntax;

synthesized attribute collectedTypeQualifiers :: [Qualifier] with ++;
flowtype collectedTypeQualifiers {} on -- TODO: Should this be allowed to depend on anything?
  UnaryOp,
  BinOp, AssignOp, BoolOp, BitOp, CompareOp, NumOp;

nonterminal Qualifiers with mangledName, qualifiers, pps, host<Qualifiers>;
flowtype Qualifiers = decorate {}, qualifiers {};

synthesized attribute qualifiers :: [Qualifier];

abstract production consQualifier
top::Qualifiers ::= h::Qualifier  t::Qualifiers
{
  top.host = if h.qualIsHost then consQualifier(h, t.host) else t.host;
  top.mangledName = h.mangledName ++ "_" ++ t.mangledName;
  top.qualifiers = cons(h, t.qualifiers);
  top.pps = cons(h.pp, t.pps);
}

abstract production nilQualifier
top::Qualifiers ::=
{
  propagate host;
  top.mangledName = "";
  top.qualifiers = [];
  top.pps = [];
}

{-- Type qualifiers (cv or cvr qualifiers) -}
closed nonterminal Qualifier with pp, qualIsPositive, qualIsNegative, qualAppliesWithinRef, qualCompat, qualIsHost, mangledName;
flowtype Qualifier = decorate {}, qualIsPositive {}, qualIsNegative {}, qualAppliesWithinRef {}, qualCompat {}, qualIsHost {};

synthesized attribute qualIsPositive :: Boolean;
synthesized attribute qualIsNegative :: Boolean;
-- Variables refer to memory locations and thus there is an implicit ref
--   wrapping stated types (given `int x;', the type of x is ref(int)) which is
--   implicitly dereferenced when used as an r-value. This attribute specifies
--   where the qualifier applies, e.g. `const int' should be `const ref(int)'
--   but `nonzero int' should be `ref(nonzero int)'.
synthesized attribute qualAppliesWithinRef :: Boolean;

synthesized attribute qualCompat :: (Boolean ::= Qualifier);

-- set to false to drop qualifier in generated code
synthesized attribute qualIsHost :: Boolean;

aspect default production
top::Qualifier ::=
{
  top.qualIsHost = false;
}

abstract production constQualifier
top::Qualifier ::=
{
  top.pp = text("const");
  top.mangledName = "const";
  top.qualIsPositive = true;
  top.qualIsNegative = false;
  top.qualAppliesWithinRef = false;
  top.qualCompat = \qualToCompare::Qualifier ->
    case qualToCompare of constQualifier() -> true | _ -> false end;
  top.qualIsHost = true;
}

abstract production volatileQualifier
top::Qualifier ::=
{
  top.pp = text("volatile");
  top.mangledName = "volatile";
  top.qualIsPositive = true;
  top.qualIsNegative = false;
  top.qualAppliesWithinRef = false;
  top.qualCompat = \qualToCompare::Qualifier ->
    case qualToCompare of volatileQualifier() -> true | _ -> false end;
  top.qualIsHost = true;
}

abstract production restrictQualifier
top::Qualifier ::=
{
  top.pp = text("restrict");
  top.mangledName = "restrict";
  top.qualIsPositive = false;
  top.qualIsNegative = false;
  top.qualAppliesWithinRef = false;
  top.qualCompat = \qualToCompare::Qualifier ->
    case qualToCompare of
      restrictQualifier()   -> true
    | uuRestrictQualifier() -> true
    | _                     -> false
    end;
  top.qualIsHost = true;
}

abstract production uuRestrictQualifier
top::Qualifier ::=
{
  top.pp = text("__restrict");
  top.mangledName = "__restrict";
  top.qualIsPositive = false;
  top.qualIsNegative = false;
  top.qualAppliesWithinRef = false;
  top.qualCompat = \qualToCompare::Qualifier ->
    case qualToCompare of
      restrictQualifier()   -> true
    | uuRestrictQualifier() -> true
    | _                     -> false
    end;
  top.qualIsHost = true;
}

{-- Specifiers that apply to specific types.
 - e.g. Function specifiers (inline, _Noreturn)
 -      Alignment specifiers (_Alignas)
 -}
nonterminal SpecialSpecifier with pp, host<SpecialSpecifier>, lifted<SpecialSpecifier>, env, returnType, errors, globalDecls, defs;
flowtype SpecialSpecifier = decorate {env, returnType};

abstract production inlineQualifier
top::SpecialSpecifier ::=
{
  propagate host, lifted;
  top.pp = text("inline");
  top.errors := [];
  top.globalDecls := [];
  top.defs := [];
}

-- C11
abstract production noreturnQualifier
top::SpecialSpecifier ::=
{
  propagate host, lifted;
  top.pp = text("_Noreturn");
  top.errors := [];
  top.globalDecls := [];
  top.defs := [];
}

-- C11
abstract production alignasSpecifier
top::SpecialSpecifier ::= e::Expr
{
  propagate host, lifted;
  top.pp = ppConcat([text("_Alignas"), parens(e.pp)]);
  top.errors := e.errors;
  top.globalDecls := e.globalDecls;
  top.defs := e.defs;
}

nonterminal SpecialSpecifiers with pps, host<SpecialSpecifiers>, lifted<SpecialSpecifiers>, env, returnType, errors, globalDecls, defs;
flowtype SpecialSpecifiers = decorate {env, returnType};

abstract production consSpecialSpecifier
top::SpecialSpecifiers ::= h::SpecialSpecifier t::SpecialSpecifiers
{
  propagate host, lifted;
  top.pps = h.pp :: t.pps;
  top.errors := h.errors ++ t.errors;
  top.globalDecls := h.globalDecls ++ t.globalDecls;
  top.defs := h.defs ++ t.defs;
}

abstract production nilSpecialSpecifier
top::SpecialSpecifiers ::=
{
  propagate host, lifted;
  top.pps = [];
  top.errors := [];
  top.globalDecls := [];
  top.defs := [];
}
	

function containsQualifier
Boolean ::= q::Qualifier t::Type
{
  return containsBy(qualifierCompat, q, t.qualifiers);
}

function qualifierCat
Qualifiers ::= q1::Qualifiers  q2::Qualifiers
{
  return foldQualifier(q1.qualifiers ++ q2.qualifiers);
}

