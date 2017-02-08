grammar edu:umn:cs:melt:ableC:abstractsyntax;

{- 
Expressions that want to specify declartions to lift to a global scope
do so by forwarding to the host production `injectGlobalDecls` (or one
of the corresponding ones for Type or BaseTypeExpr.)  

After extracting the `host` tree, there are no extension constructs,
but declarations need to be lifted to the proper place. 

A pair of synthesized attributes can be used for this.
- `globalDecls`: the list of declarations to lift up
- `lifted`: the lifted tree.
An invariant here is that all Decl nodes in the `host` tree appear in
either `globalDecls` or in `lifted`.
- On `Decls` nonterminals at the global level, `globalDecls` is empty
  and all the `Decl` trees to be lifted (were in `globalDecls`) are now
  put into `lifted`.
- On all other nonterminals, `globalDecls` need not be empty.

Another invariant is that declarations in globalDecls with the same name
refer to an identical declaration, so that any duplicates can be safely
removed.  This is left up to the extension writer for now, but there may
a better solution.  

It would be nice to move all of this to its own grammar, but aspecting
everything for lifted and globalDecls would be kind of a pain
-}

synthesized attribute lifted<a>::a;

-- String is name of decl, could be used to remove duplicates
synthesized attribute globalDecls::[Pair<String Decl>] with ++;

-- List of names of global decls that have already been inserted, to avoid lifting and inserting
-- the same decl at different locations
inherited attribute globalDeclEnv::[String];

abstract production injectGlobalDecls
top::Expr ::= globalDecls::[Pair<String Decl>] lifted::Expr
{
  top.pp = pp"injectGlobalDecls {${ppImplode(pp"\n", decls.pps)}} (${lifted.pp})";
  top.host = injectGlobalDecls(zipWith(pair, names, unfoldDecl(decls.host)), lifted.host, location=top.location);
 
  local decls::Decls = foldDecl(map(snd, globalDecls));
  local names::[String] = map(fst, globalDecls);

  decls.globalDeclEnv = error("Demanded globalDeclEnv by consDecl");
  decls.env = globalEnv(top.env);
  decls.isTopLevel = true;
  decls.returnType = top.returnType;

  top.errors <- decls.errors;

 -- Note that the invariant over `globalDecls` and `lifted` is maintained.
  top.globalDecls :=
    decls.globalDecls ++ 
    zipWith(pair, names, unfoldDecl(decls.lifted)) ++
    lifted.globalDecls;
  -- It should hold that names and unfoldDecl(decls.lifted) are the same length and
  -- correctly correspond to one another.
  top.lifted = lifted.lifted;
 
  lifted.env = addEnv(decls.defs, top.env);
 
  -- TODO: We are adding the new env elements to the current scope, when they should really be global
  -- Shouldn't be a problem unless there are name conflicts, doing this the right way would be less
  -- efficent.  
  forwards to lifted
  with {env = lifted.env;};
}

-- Same as injectGlobalDecls, but on BaseTypeExpr
abstract production injectGlobalDeclsTypeExpr
top::BaseTypeExpr ::= globalDecls::[Pair<String Decl>] lifted::BaseTypeExpr
{
  top.pp = pp"injectGlobalDeclsTypeExpr {${ppImplode(pp"\n", decls.pps)}} (${lifted.pp})";
  top.host = injectGlobalDeclsTypeExpr(zipWith(pair, names, unfoldDecl(decls.host)), lifted.host);
 
  local decls::Decls = foldDecl(map(snd, globalDecls));
  local names::[String] = map(fst, globalDecls);

  decls.globalDeclEnv = error("Demanded globalDeclEnv by consDecl");
  decls.env = globalEnv(top.env);
  decls.isTopLevel = true;
  decls.returnType = top.returnType;

  top.errors <- decls.errors;

 -- Note that the invariant over `globalDecls` and `lifted` is maintained.
  top.globalDecls :=
    decls.globalDecls ++ 
    zipWith(pair, names, unfoldDecl(decls.lifted)) ++
    lifted.globalDecls;
  -- It should hold that names and unfoldDecl(decls.lifted) are the same length and
  -- correctly correspond to one another.
  top.lifted = lifted.lifted;
 
  lifted.env = addEnv(decls.defs, top.env);
 
  -- TODO: We are adding the new env elements to the current scope, when they should really be global
  -- Shouldn't be a problem unless there are name conflicts, doing this the right way would be less
  -- efficent.  
  forwards to lifted
  with {env = lifted.env;};
}

{- Lifting mechanism for types
 - Note that the invariant must be changed here, since we don't have access to an environment.  
 - Instead, we simply lift everything to the top of the type, where the decls are then decorated
 - within directTypeExpr
 -}
abstract production injectGlobalDeclsType
top::NoncanonicalType ::= globalDecls::[Pair<String Decl>] lifted::Type
{
  top.canonicalType = lifted;
  top.lpp = pp"injectGlobalDeclsTypeExpr {<not shown>} (${lifted.lpp})";
  top.rpp = lifted.rpp;
  top.host = injectGlobalDeclsType(globalDecls, lifted.host);
  top.lifted = liftedType(lifted.lifted);
  top.globalDecls := globalDecls;
}

-- A noncanonical type that is really just a normal type, after the lifting transformation has happened
abstract production liftedType
top::NoncanonicalType ::= lifted::Type
{
  propagate host, lifted;
  top.canonicalType = lifted;
  top.lpp = lifted.lpp;
  top.rpp = lifted.rpp;
  top.globalDecls := lifted.globalDecls;
}

-- directTypeExpr now functions similarly to injectGlobalDecls, except that the decls to be lifted
-- are provided only via result.globalDecls
aspect production directTypeExpr
top::BaseTypeExpr ::= result::Type
{
  top.lifted = freshenDirectTypeExpr(result.lifted);
  
  local decls::Decls = foldDecl(map(snd, result.globalDecls));
  local names::[String] = map(fst, result.globalDecls);

  decls.globalDeclEnv = error("Demanded globalDeclEnv by consDecl");
  decls.env = globalEnv(top.env);
  decls.isTopLevel = true;
  decls.returnType = top.returnType;
  
  top.errors <- decls.errors;

  -- Note that the invariant over `globalDecls` and `lifted` is maintained.
  top.globalDecls :=
    decls.globalDecls ++ 
    zipWith(pair, names, unfoldDecl(decls.lifted));
}

-- Inserted globalDecls before h. Should only ever get used by top-level 
-- foldGlobalDecl in concrete syntax.
abstract production consGlobalDecl
top::Decls ::= h::Decl  t::Decls
{
  propagate host;
 
  local newGlobalDeclPairs::[Pair<String Decl>] =
    removeDuplicateGlobalDeclPairs(h.globalDecls, top.globalDeclEnv);
  local newDecls::Decls = foldDecl(map(snd, newGlobalDeclPairs));

  top.globalDecls := [];
  top.lifted =
    if !null(t.globalDecls)
    then error("consGlobalDecl tail has global decls!")
    else consDecl( 
           decls(newDecls),
           consDecl(
             h.lifted,
             t.lifted));
  
  t.globalDeclEnv = top.globalDeclEnv ++ map(fst, newGlobalDeclPairs);
  t.env = addEnv(h.defs, top.env);
  
  -- define pp, env, defs, etc.
  forwards to consDecl(h, t);
}

-- removes duplicate global decls before inserting them
-- sofar is the list of names that have already been inserted, passed in to globalDecls via globalDeclEnv
function removeDuplicateGlobalDeclPairs
[Pair<String Decl>] ::= ds::[Pair<String Decl>]  sofar::[String]
{
  return
    case ds of
      [] -> []
    | pair(n, d) :: t ->
        if containsBy(stringEq, n, sofar)
        then removeDuplicateGlobalDeclPairs(t, sofar)
        else pair(n, d) :: removeDuplicateGlobalDeclPairs(t, n::sofar)
    end;
}