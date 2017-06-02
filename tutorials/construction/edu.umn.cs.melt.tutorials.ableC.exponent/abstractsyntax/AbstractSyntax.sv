grammar edu:umn:cs:melt:tutorials:ableC:exponent:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:substitution;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction:parsing;

imports silver:langutil;
imports silver:langutil:pp;

abstract production exponentExpr
top::Expr ::= l::Expr r::Expr
{
  top.pp = pp"(${l.pp} ** ${r.pp})";

  local localErrors::[Message] =
    (if !l.typerep.isArithmeticType
     then [err(l.location, s"Exponent base must have aritimetic type (got ${showType(l.typerep)})")]
     else []) ++
    (if !r.typerep.isIntegerType
     then [err(l.location, s"Exponent power must have integer type (got ${showType(r.typerep)})")]
     else []);

  local lTempName::String = "_l_" ++ toString(genInt());
  local rTempName::String = "_r_" ++ toString(genInt());
  local counterName::String = "_i_" ++ toString(genInt());
  local resName::String = "_res_" ++ toString(genInt());
  local fwrd::Expr =
    subExpr(
      [typedefSubstitution("__l_type__", directTypeExpr(l.typerep)),
       typedefSubstitution("__r_type__", directTypeExpr(r.typerep)),
       declRefSubstitution("__l__", l),
       declRefSubstitution("__r__", r)],
      parseExpr(s"""
({proto_typedef __l_type__, __r_type__;
  __l_type__ ${lTempName} = __l__;
  __r_type__ ${rTempName} = __r__;
  __l_type__ ${resName} = 1;
  for (__r_type__ ${counterName} = 0; ${counterName} < ${rTempName}; ${counterName}++) {
    ${resName} *= ${lTempName};
  }
  ${resName};})
"""));
  
  forwards to mkErrorCheck(localErrors, fwrd);
}

global builtin::Location = builtinLoc("exponent");