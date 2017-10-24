grammar edu:umn:cs:melt:ableC:abstractsyntax:env;

imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports silver:util:raw:treemap as tm;

{--
 - The environment values that get passed around and used to look up names.
 -}
nonterminal Env with labels, tags, values, refIds, misc;

{--
 - A list of definitions, only used in contributing new names to the environment.
 -}
nonterminal Defs 
  with labelContribs, tagContribs, valueContribs, refIdContribs, miscContribs, globalDefs;

{--
 - An individual definition of a name.
 -}
closed nonterminal Def 
  with labelContribs, tagContribs, valueContribs, refIdContribs, miscContribs, globalDefs;


{--
 - An attribute on abstract syntax trees that represents the definitions
 - that escape the scope of the corresponding subtree.
 - There may be cases where an extension writer may wish to add additional defs for a new namespace to a host production,
 - for example, putting a unique identifier for every name that is declared in the environment. For this to be possible, we
 - make defs a collection attribute so that extensions can aspect host productions and add new defs. To avoid interference,
 - we have the invariant that any new defs added must only contain Defs that affect the namespace being defined - that is,
 - we can only make use of this 'shortcut' of adding new defs to the environment when the same thing could be implemented
 - in a more complex way by mirroring defs and env with another pair of synthesized and inherited attributes.
 -}
synthesized attribute defs :: [Def] with ++;
{--
 - For Function-Scope definitions (e.g. Labels in functions)
 - @see defs for normal definitions
 -}
synthesized attribute functiondefs :: [Def] with ++;
{--
 - For local-scope only definitions (e.g. struct and union fields)
 - Used in conjunction with 'tagEnv'.
 - Distinct from 'defs' because nested structs should all have their names
 - visible at outer scope, so we still need a mechanism to propagate those.
 - e.g. struct x { struct y { .. } .. } should result in both x and y in the env.
 -
 - @see defs for normal definitions
 -}
synthesized attribute localdefs :: [Def] with ++;
{--
 - The environment, on which all lookups are performed.
 -}
autocopy attribute env :: Decorated Env;
{--
 - The local environment for a struct or enum. Could be a different type, I suppose. TODO
 -}
synthesized attribute tagEnv :: Decorated Env;


-- Environment manipulation functions

function emptyEnv
Decorated Env ::=
{
  return decorate emptyEnv_i() with {};
}
function addEnv
Decorated Env ::= d::[Def]  e::Decorated Env
{
  return if null(d) then e else addEnvDefs(foldr(consDefs, nilDefs(), d), e);
}
function addEnvDefs
Decorated Env ::= d::Defs  e::Decorated Env
{
  return decorate addEnv_i(d, e) with {};
}
function openScope
Decorated Env ::= e::Decorated Env
{
  return decorate openScope_i(e) with {};
}
function globalEnv
Decorated Env ::= e::Decorated Env
{
  return decorate globalEnv_i(e) with {};
}

-- Environment lookup functions

function lookupValue
[ValueItem] ::= n::String  e::Decorated Env
{
  return readScope_i(n, e.values);
}
function lookupTag
[TagItem] ::= n::String  e::Decorated Env
{
  return readScope_i(n, e.tags);
}
function lookupLabel
[LabelItem] ::= n::String  e::Decorated Env
{
  return readScope_i(n, e.labels);
}
function lookupRefId 
[RefIdItem] ::= n::String  e::Decorated Env
{
  return readScope_i(n, e.refIds);
}

function lookupMisc 
[MiscItem] ::= n::String  e::Decorated Env
{
  return readScope_i(n, e.misc);
}


function lookupValueInLocalScope
[ValueItem] ::= n::String  e::Decorated Env
{
  return tm:lookup(n, head(e.values));
}
function lookupTagInLocalScope
[TagItem] ::= n::String  e::Decorated Env
{
  return tm:lookup(n, head(e.tags));
}
function lookupLabelInLocalScope
[LabelItem] ::= n::String  e::Decorated Env
{
  return tm:lookup(n, head(e.labels));
}

function lookupMiscInLocalScope
[MiscItem] ::= n::String  e::Decorated Env
{
  return tm:lookup(n, head(e.misc));
}

