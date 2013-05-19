#############################################################################
##
#W  inverse.gi
#Y  Copyright (C) 2011-12                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Notes: everything here uses LambdaSomething, so don't use RhoAnything

# the first three main functions should be updated!

## Methods for inverse acting semigroups consisting of acting elements with a
## ^-1 operator. 

# change f so that its rho value is in the first position of its scc. 

InstallGlobalFunction(RectifyInverseRho,
function(s, o, f)
  local l, m;

  if not IsClosed(o) then     
    Enumerate(o, infinity);
  fi;

  l:=Position(o, RhoFunc(s)(f));
  m:=OrbSCCLookup(o)[l];

  if l<>OrbSCC(o)[m][1] then
    f:=LambdaOrbMult(o, m, l)[1]*f;
  fi;
  return f;
end);

# Usage: s = semigroup;  m = lambda orb scc index; o = lambda orb;  
# rep = L-class rep; nc = IsGreensClassNC. 
# NC indicates that RhoFunc(s)(rep) is in the first place of the scc of the
# lambda orb. 

InstallGlobalFunction(CreateInverseOpLClassNC,
function(s, m, o, rep, nc)
  local l;

  l:=Objectify(LClassType(s), rec());
  SetParent(l, s);
  SetRepresentative(l, rep);
  SetLambdaOrb(l, o);
  SetLambdaOrbSCCIndex(l, m);
  SetEquivalenceClassRelation(l, GreensLRelation(s));
  SetIsGreensClassNC(l, nc);
  return l;
end);

# use the NC version for already rectified reps.
# only use this when <m> is known!

InstallGlobalFunction(CreateInverseOpLClass,
function(s, m, o, rep, nc)
  return CreateInverseOpLClassNC(s, m, o, RectifyInverseRho(s, o, rep), nc);
end);

#

InstallMethod(IsInverseOpClass, "for a Green's class",
[IsActingSemigroupGreensClass], ReturnFalse);

#

InstallOtherMethod(DClassType, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsInverseOpClass and IsGreensDClass
         and IsActingSemigroupGreensClass);
end);

#

InstallOtherMethod(HClassType, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsInverseOpClass and IsGreensHClass
         and IsActingSemigroupGreensClass);
end);

#

InstallOtherMethod(LClassType, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsInverseOpClass and IsGreensLClass
         and IsActingSemigroupGreensClass);
end);

#

InstallOtherMethod(RClassType, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsInverseOpClass and IsGreensRClass
         and IsActingSemigroupGreensClass);
end);

#

InstallMethod(\in, 
"for inverse acting elt and acting semigroup with inversion",
[IsAssociativeElement, IsActingSemigroupWithInverseOp],
function(f, s)
  local dom, o, lambda, lambda_l, rho, rho_l, lookingfor, m, schutz, scc, g,
  rep, n;
  
  if not ElementsFamily(FamilyObj(s))=FamilyObj(f) then 
    Error("the element and semigroup are not of the same type,");
    return;
  fi;

  #if HasAsSSortedList(s) then 
  #  return f in AsSSortedList(s); 
  #fi;

  if ActionDegree(s)=0 then 
    return ActionDegree(f)=0;
  fi;

  o:=LambdaOrb(s);
  lambda:=LambdaFunc(s)(f);
  lambda_l:=EnumeratePosition(o, lambda, false);
  
  if lambda_l=fail then
    return false;
  fi;
  
  rho:=RhoFunc(s)(f);
  rho_l:=EnumeratePosition(o, rho, false);
  
  if rho_l=fail then
    return false;
  fi;

  # must use LambdaOrb(s) and not a graded lambda orb as LambdaOrbRep(o, m) when
  # o is graded, is just f and hence \in will always return true!!
  m:=OrbSCCLookup(o)[lambda_l];

  if OrbSCCLookup(o)[rho_l]<>m then
    return false;
  fi;

  schutz:=LambdaOrbStabChain(o, m);

  if schutz=true then
    return true;
  fi;

  scc:=OrbSCC(o)[m]; g:=f;

  if lambda_l<>scc[1] then 
    g:=g*LambdaOrbMult(o, m, lambda_l)[2];
  fi;

  if rho_l<>scc[1] then 
    g:=LambdaOrbMult(o, m, rho_l)[1]*g;
  fi;

  if IsIdempotent(g) then 
    return true;
  elif schutz=false then
    return false;
  fi;
  
  # the D-class rep corresponding to lambda_o and scc.
  rep:=RectifyInverseRho(s, o, LambdaOrbRep(o, m));
  return SiftedPermutation(schutz, LambdaPerm(s)(rep, g))=(); 
end);

#

InstallMethod(\in, "for inverse op D-class",
[IsAssociativeElementWithUniqueSemigroupInverse, 
IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(f, d)
  local rep, s, o, m, lookup, rho_l, lambda_l, schutz, scc, g;
  
  rep:=Representative(d);
  s:=Parent(d);

  if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) 
    or ActionRank(f) <> ActionRank(rep) 
    or ActionDegree(f)<>ActionDegree(rep) then
    return false;
  fi;

  o:=LambdaOrb(d);
  m:=LambdaOrbSCCIndex(d);
  lookup:=OrbSCCLookup(o);

  rho_l:=Position(o, RhoFunc(s)(f)); 
  lambda_l:=Position(o, LambdaFunc(s)(f));
  
  if rho_l=fail or lambda_l=fail or lookup[rho_l]<>m or lookup[lambda_l]<>m
   then 
    return false;
  fi;

  schutz:=LambdaOrbStabChain(o, m); 

  if schutz=true then 
    return true;
  fi;

  scc:=OrbSCC(o)[m];
  g:=f;

  if rho_l<>scc[1] then 
    g:=LambdaOrbMult(o, m, rho_l)[1]*g;
  fi;
  
  if lambda_l<>scc[1] then 
    g:=g*LambdaOrbMult(o, m, lambda_l)[2];
  fi; 

  if g=rep then 
    return true;
  elif schutz=false then 
    return false;
  fi;

  return SiftedPermutation(schutz, LambdaPerm(s)(rep, g))=(); 
end);

#

InstallMethod(\in, "for acting elt and inverse op L-class of acting semigp.",
[IsAssociativeElement, IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass],
function(f, l)
  local rep, s, m, o, i, schutz, g, p;

  rep:=Representative(l);
  s:=Parent(l);

  if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) 
    or ActionDegree(f) <> ActionDegree(rep)  
    or ActionRank(f) <> ActionRank(rep) 
    or LambdaFunc(s)(f) <> LambdaFunc(s)(rep) then
    Info(InfoSemigroups, 1, "degree, rank, or lambda value not equal to",
     " those of  any of the L-class elements,");
    return false;
  fi;

  m:=LambdaOrbSCCIndex(l);
  o:=LambdaOrb(l);
  #o is closed since we know LambdaOrbSCCIndex

  i:=Position(o, RhoFunc(s)(f));
  if i = fail or OrbSCCLookup(o)[i]<>m then
    return false;
  fi;

  schutz:=LambdaOrbStabChain(o, m);

  if schutz=true then
    Info(InfoSemigroups, 3, "Schutz. group of L-class is symmetric group");
    return true;
  fi;

  if i<>OrbSCC(o)[m][1] then  
    g:=LambdaOrbMult(o, m, i)[1]*f;
  else
    g:=f;
  fi;

  if g=rep then
    Info(InfoSemigroups, 3, "element with rectified rho value equals ",
    "L-class representative");
    return true;
  elif schutz=false then
    Info(InfoSemigroups, 3, "Schutz. group of L-class is trivial");
    return false;
  fi;

  #return SiftGroupElement(schutz, LambdaPerm(s)(rep, g)).isone;
  return SiftedPermutation(schutz,  LambdaPerm(s)(rep, g))=();
end);

#

InstallMethod(\in, "for acting elt and inverse op R-class of acting semigp.",
[IsAssociativeElement, IsInverseOpClass and IsGreensRClass and IsActingSemigroupGreensClass],
function(f, r)
  local rep, s, m, o, i, schutz, g, p;

  rep:=Representative(r);
  s:=Parent(r);

  if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) or 
   ActionDegree(f) <> ActionDegree(rep) or 
   ActionRank(f) <> ActionRank(rep) or 
   RhoFunc(s)(f) <> RhoFunc(s)(rep) then
    Info(InfoSemigroups, 1, 
    "degree, rank, or lambda value not equal to those of",
    " any of the L-class elements,");
    return false;
  fi;

  m:=LambdaOrbSCCIndex(r);
  o:=LambdaOrb(r);
  #o is closed since we know LambdaOrbSCCIndex

  i:=Position(o, LambdaFunc(s)(f));

  if i = fail or OrbSCCLookup(o)[i]<>m then
    return false;
  fi;

  schutz:=LambdaOrbStabChain(o, m);

  if schutz=true then
    Info(InfoSemigroups, 3, "Schutz. group of R-class is symmetric group");
    return true;
  fi;

  if i<>OrbSCC(o)[m][1] then  
    g:=f*LambdaOrbMult(o, m, i)[2];
  else
    g:=f;
  fi;

  if g=rep then
    Info(InfoSemigroups, 3, "element with rectified lambda value equals ",
    "R-class representative");
    return true;
  elif schutz=false then
    Info(InfoSemigroups, 3, "Schutz. group of R-class is trivial");
    return false;
  fi;

  #return SiftGroupElement(schutz, LambdaPerm(s)(rep, g)).isone;
  return SiftedPermutation(schutz,  LambdaPerm(s)(rep, g))=();
end);

#



#

InstallOtherMethod(DClassOfRClass, "for inverse op R-class", 
[IsInverseOpClass and IsGreensRClass and IsActingSemigroupGreensClass],
function(r)
  local s, o, m, f;

  s:=Parent(r);
  o:=LambdaOrb(r); 
  m:=LambdaOrbSCCIndex(r);
  f:=RectifyLambda(s, o, Representative(r), fail, m).rep;
  return CreateDClassNC(s, m, o, fail, fail, f, IsGreensClassNC(r));
end);

#

InstallOtherMethod(DClassOfHClass, "for inverse op H-class", 
[IsInverseOpClass and IsGreensHClass and IsActingSemigroupGreensClass],
function(h)
  local s, o, m, f;

  s:=Parent(h);
  o:=LambdaOrb(h); 
  m:=LambdaOrbSCCIndex(h);
  f:=RectifyLambda(s, o, Representative(h), fail, m).rep;
  return CreateDClassNC(s, m, o, fail, fail, f, IsGreensClassNC(h));
end);

#

InstallMethod(LClassOfHClass, "for an inverse op H-class",
[IsInverseOpClass and IsGreensHClass and IsActingSemigroupGreensClass],
# use non-NC so that rho value of f is rectified
h-> CreateInverseOpLClass(Parent(h), LambdaOrbSCCIndex(h),
LambdaOrb(h), Representative(h), IsGreensClassNC(h)));

#

InstallOtherMethod(DClassReps, "for an acting semigroup with inversion",
[IsActingSemigroupWithInverseOp],
function(s)            
  local o, r, out, f, m;
  
  o:=RhoOrb(s);
  r:=Length(OrbSCC(o));
  out:=EmptyPlist(r);
  
  for m in [2..r] do 
    f:=RhoOrbRep(o, m);
# JDM method for RightOne of inverse acting element required.
    out[m-1]:=RightOne(f);
  od;
  return out;
end);

# JDM why is IsGreensClassOfPartPermSemigroup still used here!?

InstallMethod(Enumerator, "for D-class of part perm inv semigroup",
[IsGreensDClass and IsGreensClassOfInverseSemigroup and
IsGreensClassOfPartPermSemigroup],
function(d)

  return EnumeratorByFunctions(d, rec(

    schutz:=Enumerator(SchutzenbergerGroup(d)),

    #########################################################################

    ElementNumber:=function(enum, pos)
      local scc, n, m, r, q, q2, mults;
      if pos>Length(enum) then 
        return fail;
      fi;

      if pos<=Length(enum!.schutz) then 
        return enum!.schutz[pos]*Representative(d);
      fi;

      scc:=LambdaOrbSCC(d);
      mults:=LambdaOrbMults(LambdaOrb(d), LambdaOrbSCCIndex(d));

      n:=pos-1; m:=Length(enum!.schutz); r:=Length(scc);
      q:=QuoInt(n, m); q2:=QuoInt(q, r);
      pos:=[ n-q*m, q2, q  - q2 * r ]+1;
      return mults[scc[pos[2]]]*enum[pos[1]]/mults[scc[pos[3]]];
    end,

    #########################################################################
    
    NumberElement:=function(enum, f)
      local rep, o, m, lookup, s, i, j, scc, g, k;

      rep:=Representative(d);
      
      if ActionRank(f)<>ActionRank(rep) or ActionDegree(f)<>ActionDegree(rep) then 
        return fail;
      fi;
      
      if f=rep then 
        return 1;
      fi;

      o:=LambdaOrb(d); m:=LambdaOrbSCCIndex(d);
      lookup:=OrbSCCLookup(o);
      s:=Parent(d);

      i:=Position(o, RhoFunc(s)(f)); 
      if i=fail or not lookup[i]<>m then 
        return fail;
      fi;

      j:=Position(o, LambdaFunc(s)(f));
      if j=fail or not lookup[j]<>m then 
        return fail;
      fi;

      scc:=OrbSCC(o)[m]; g:=f;
      
      if i<>scc[1] then 
        g:=LambdaOrbMult(o, m, i)[1]*g;
      fi;
      
      if j<>scc[1] then 
        g:=g*LambdaOrbMult(o, m, j)[2];
      fi;

      k:=Position(enum!.schutz, LambdaPerm(s)(rep, g));
      if j=fail then 
        return fail;
      fi;

      return Length(enum!.schutz)*((Position(scc, i)-1)*Length(scc)
      +(Position(scc, j)-1))+k;
    end,

    #########################################################################

    Membership:=function(elm, enum)
      return elm in d;
    end,

    Length:=enum-> Size(d),

    PrintObj:=function(enum)
      Print("<enumerator of D-class>");
      return;
    end));
end);


#

InstallMethod(Enumerator, "for L-class of an acting semigroup",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, mults, scc;

  o:=LambdaOrb(l); 
  m:=LambdaOrbSCCIndex(l);
  mults:=LambdaOrbMults(o, m);
  scc:=OrbSCC(o)[m];

  return EnumeratorByFunctions(l, rec(

    schutz:=Enumerator(SchutzenbergerGroup(l)),

    len:=Size(SchutzenbergerGroup(l)),

    #########################################################################

    ElementNumber:=function(enum, pos)
      local n, m, q;

      if pos>Length(enum) then 
        return fail;
      fi;

      if pos<=Length(enum!.schutz) then 
        return Representative(l)*enum!.schutz[pos];
      fi;

      n:=pos-1; m:=enum!.len;
      
      q:=QuoInt(n, m); 
      pos:=[ q, n - q * m]+1;
     
     return mults[scc[pos[1]]][2]*enum[pos[2]];
    end,

    #########################################################################
    
    NumberElement:=function(enum, f)
      local s, rep, o, m, i, g, j;

      s:=Parent(l);
      rep:=Representative(l);
      
      if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) or 
       ActionDegree(f) <> ActionDegree(rep) or ActionRank(f) <> ActionRank(rep)
       or LambdaFunc(s)(f) <> LambdaFunc(s)(rep) then 
        return fail;
      fi;
      
      if f=rep then 
        return 1;
      fi;

      o:=RhoOrb(l); m:=RhoOrbSCCIndex(l);
      i:=Position(o, RhoFunc(s)(f));

      if i = fail or OrbSCCLookup(o)[i]<>m then 
        return fail;
      fi;
     
      j:=Position(enum!.schutz, LambdaPerm(s)(rep, mults[i][1]*f));

      if j=fail then 
        return fail;
      fi;
      return enum!.len*(Position(scc, i)-1)+j;
    end,

    #########################################################################

    Membership:=function(elm, enum)
      return elm in l;
    end,

    Length:=enum-> Size(l),

    PrintObj:=function(enum)
      Print("<enumerator of L-class>");
      return;
    end));
end);

#

InstallOtherMethod(GreensDClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc, out, i, f, m;

  o:=LambdaOrb(s); 
  scc:=OrbSCC(o); 
  out:=EmptyPlist(Length(scc)); 

  i:=0;
  for m in [2..Length(scc)] do 
    i:=i+1;
    f:=RightOne(LambdaOrbRep(o, m));
    out[i]:=CreateDClassNC(s, m, o, fail, fail, f, false);
  od;
  return out;
end);


#

InstallOtherMethod(GreensHClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc, len, out, n, mults, g, f, m, j, k;
  
  o:=LambdaOrb(s);
  scc:=OrbSCC(o);
  len:=Length(scc);
  
  out:=EmptyPlist(NrHClasses(s));
  n:=0; 
    
  for m in [2..len] do
    mults:=LambdaOrbMults(o, m);
    g:=RightOne(LambdaOrbRep(o, m));
    for j in scc[m] do
      f:=g*mults[j][1];
      for k in scc[m] do
        n:=n+1;
        out[n]:=CreateHClass(s, m, o, fail, fail, mults[k][2]*f, false);
      od;
    od;
  od;
  return out;
end);

#

InstallOtherMethod(GreensHClasses, "for inverse op D-class",
[IsActingSemigroupGreensClass and IsGreensDClass and IsInverseOpClass],
function(d)
  local s, o, m, f, scc, mults, out, n, g, j, k;
 
  s:=Parent(d);
  o:=LambdaOrb(d);
  m:=LambdaOrbSCCIndex(d); 
  f:=Representative(d);
  
  scc:=OrbSCC(o);
  mults:=LambdaOrbMults(o, m);
  out:=EmptyPlist(NrHClasses(d));
  n:=0; 
    
  for j in scc[m] do
    g:=f*mults[j][1];
    for k in scc[m] do
      n:=n+1;
      out[n]:=CreateHClass(s, m, o, fail, fail, mults[k][2]*g, false);
      SetDClassOfHClass(out[n], d);
    od;
  od;
  return out;
end);

#

InstallOtherMethod(GreensHClasses, "for inverse op L-class of acting semigroup",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, scc, mults, f, nc, s, out, k, j;
  
  o:=LambdaOrb(l);
  m:=LambdaOrbSCCIndex(l);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  
  f:=Representative(l);
  nc:=IsGreensClassNC(l);
  s:=Parent(l);
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for j in scc do
    k:=k+1;
    out[k]:=CreateHClass(s, m, o, fail, fail, mults[j][2]*f, nc);
    SetLClassOfHClass(out[k], l);
  od;
  
  return out;
end);

#

InstallOtherMethod(GreensHClasses, "for inverse op R-class of acting semigroup",
[IsInverseOpClass and IsGreensRClass and IsActingSemigroupGreensClass],
function(r)
  local o, m, scc, mults, f, nc, s, out, k, j;
  
  o:=LambdaOrb(r);
  m:=LambdaOrbSCCIndex(r);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  
  f:=Representative(r);
  nc:=IsGreensClassNC(r);
  s:=Parent(r);
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for j in scc do
    k:=k+1;
    out[k]:=CreateHClass(s, m, o, fail, fail, f*mults[j][1], nc);
    SetRClassOfHClass(out[k], r);
  od;
  
  return out;
end);

#
    
InstallOtherMethod(GreensLClasses, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc, len, out, n, f, mults, m, j;
  
  o:=LambdaOrb(s);
  scc:=OrbSCC(o);
  len:=Length(scc);
  out:=EmptyPlist(NrLClasses(s));
  n:=0;

  for m in [2..len] do
    f:=RightOne(LambdaOrbRep(o, m));
    mults:=LambdaOrbMults(o, m);
    for j in scc[m] do
      n:=n+1;
      out[n]:=CreateInverseOpLClassNC(s, m, o, f*mults[j][1], false);
    od;
  od;
  return out;
end);

#

InstallOtherMethod(GreensLClasses, "for inverse op D-class of acting semigroup",
[IsActingSemigroupGreensClass and IsInverseOpClass and IsGreensDClass],
function(d)
  local s, m, o, f, nc, out, k, mults, scc, i;
  
  s:=Parent(d);
  m:=LambdaOrbSCCIndex(d);
  o:=LambdaOrb(d);
  f:=Representative(d);
  nc:=IsGreensClassNC(d);
  scc:=OrbSCC(o)[m];
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  mults:=LambdaOrbMults(LambdaOrb(d), LambdaOrbSCCIndex(d));
  scc:=LambdaOrbSCC(d);
  
  for i in scc do
    k:=k+1;
    #use NC since f has rho value in first place of scc
    out[k]:=CreateInverseOpLClassNC(s, m, o, f*mults[i][1], nc);
    SetDClassOfLClass(out[k], d);
  od;

  return out;
end);

#

InstallOtherMethod(GreensDClassOfElement, 
"for acting semi with inv op and elt",
[IsActingSemigroupWithInverseOp, IsAssociativeElement],
function(s, f)
  local o, i, m, rep;

  if not f in s then 
    Error("the element does not belong to the semigroup,");
    return;
  fi;

  if HasLambdaOrb(s) and IsClosed(LambdaOrb(s)) then 
    o:=LambdaOrb(s);
    i:=Position(o, RhoFunc(s)(f)); #DomPP easier to find :)
  else
    o:=GradedLambdaOrb(s, f, true);
    i:=LambdaPos(o);
  fi;
  
  m:=OrbSCCLookup(o)[i];
  rep:=RightOne(LambdaOrbRep(o, m));

  return CreateDClassNC(s, m, o, fail, fail, rep, false); 
end);

#

InstallOtherMethod(GreensDClassOfElementNC, 
"for an acting semigp with inverse op and elt",
[IsActingSemigroupWithInverseOp, IsAssociativeElement],
function(s, f)
  return CreateDClassNC(s, 1, GradedLambdaOrb(s, f, false), 
   fail, fail, RightOne(f), true);
end);

#

InstallOtherMethod(GreensHClassOfElement, 
"for an acting semigp with inverse op and elt",
[IsActingSemigroupWithInverseOp, IsAssociativeElement],
function(s, f)
  local o, m;

  if not f in s then
    Error("the element does not belong to the semigroup,");
    return;
  fi;

  o:=LambdaOrb(s);
  m:=OrbSCCLookup(o)[Position(o, LambdaFunc(s)(f))];

  return CreateHClass(s, m, o, fail, fail, f, false);
end);

#

InstallOtherMethod(GreensHClassOfElementNC, "for an acting semigp and elt",
[IsActingSemigroupWithInverseOp, IsAssociativeElement],
function(s, f)
  return CreateHClass(s, 1, GradedLambdaOrb(s, f, false),
   fail, fail, f, true);
end);

#

InstallOtherMethod(GreensHClassOfElement, "for inverse op class and elt",
[IsActingSemigroupGreensClass and IsInverseOpClass, IsAssociativeElement],
function(x, f)
  local h;
  
  if not f in x then
    Error("the element does not belong to the Green's class,");
    return;
  fi;
  
  h:=CreateHClass(Parent(x), LambdaOrbSCCIndex(x), LambdaOrb(x), fail,
   fail, f, IsGreensClassNC(x));
  
  if IsGreensLClass(x) then 
    SetLClassOfHClass(h, x);
  elif IsGreensRClass(x) then 
    SetRClassOfHClass(h, x);
  elif IsGreensDClass(x) then 
    SetDClassOfHClass(h, x);
  fi;
  
  return h;
end);

#

InstallOtherMethod(GreensHClassOfElementNC, "for inverse op class and elt",
[IsActingSemigroupGreensClass and IsInverseOpClass and IsGreensLClass, IsAssociativeElement],
function(x, f)
  local h;
  
  h:=CreateHClass(Parent(x), LambdaOrbSCCIndex(x), LambdaOrb(x), fail,
   fail, f, true);

  if IsGreensLClass(x) then 
    SetLClassOfHClass(h, x);
  elif IsGreensRClass(x) then 
    SetRClassOfHClass(h, x);
  elif IsGreensDClass(x) then 
    SetDClassOfHClass(h, x);
  fi;
  
  return h;
end);

#

InstallOtherMethod(GreensLClassOfElement, 
"for acting semigp with inverse op and elt",
[IsActingSemigroupWithInverseOp, IsAssociativeElement],
function(s, f)
  local o, l, m;

  if not f in s then
    Error("the element does not belong to the semigroup,");
    return;
  fi;

  if HasLambdaOrb(s) and IsClosed(LambdaOrb(s)) then
    o:=LambdaOrb(s);
  else
    o:=GradedLambdaOrb(s, f, true);
  fi;

  l:=Position(o, RhoFunc(s)(f));
  m:=OrbSCCLookup(o)[l];
  
  if l<>OrbSCC(o)[m][1] then 
    f:=LambdaOrbMult(o, m, l)[1]*f;
  fi;

  return CreateInverseOpLClassNC(s, m, o, f, false);
end);

#

InstallOtherMethod(GreensLClassOfElementNC, "for an acting semigp and elt",
[IsActingSemigroupWithInverseOp, IsAssociativeElement],
function(s, f)
  # lambda value of f has to be in first place of GradedLambdaOrb
  # with false as final arg, use non-NC version since rho value of f should be
  # in first place. 
  return CreateInverseOpLClass(s, 1, GradedLambdaOrb(s, f, false), f, true);
end);

#

InstallOtherMethod(GreensLClassOfElement, "for inverse op D-class and elt",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass, IsAssociativeElement],
function(d, f)
  local l;

  if not f in d then
    Error("the element does not belong to the D-class,");
    return;
  fi;

  # use non-NC so that rho value of f is rectified
  l:=CreateInverseOpLClass(Parent(d), LambdaOrbSCCIndex(d),
   LambdaOrb(d), f, IsGreensClassNC(d));

  SetDClassOfLClass(l, d);
  return l;
end);

#

InstallOtherMethod(GreensLClassOfElementNC, "for D-class and acting elt",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass, IsAssociativeElement],
function(d, f)
  local l;

  # use non-NC so taht rho value of f is rectified
  l:=CreateInverseOpLClass(Parent(d), LambdaOrbSCCIndex(d), LambdaOrb(d), 
   f, true);
  SetDClassOfLClass(l, d);
  return l;
end);

#
                    
InstallOtherMethod(GreensRClasses, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)         
  local o, scc, len, out, i, f, mults, m, j;
                    
  o:=LambdaOrb(s);
  scc:=OrbSCC(o);   
  len:=Length(scc);
  out:=EmptyPlist(Length(o));

  i:=0;             
                    
  for m in [2..len] do
    f:=RightOne(LambdaOrbRep(o, m));
    mults:=LambdaOrbMults(o, m);
    for j in scc[m] do
      i:=i+1;    
      out[i]:=CreateRClassNC(s, m, o, mults[j][2]*f, false);
    od;             
  od;

  return out;
end);

#
                    
InstallOtherMethod(GreensRClasses, "for inverse op D-class",
[IsActingSemigroupGreensClass and IsInverseOpClass and IsGreensDClass],
function(d)         
  local s, o, m, f, scc, mults, out, i, j;
  
  s:=Parent(d);
  o:=LambdaOrb(d);
  m:=LambdaOrbSCCIndex(d);
  f:=Representative(d);
  
  scc:=OrbSCC(o)[m];   
  mults:=LambdaOrbMults(o, LambdaOrbSCCIndex(d));
  out:=EmptyPlist(Length(o));
  i:=0;             
  
  for j in scc do
    i:=i+1;    
    out[i]:=CreateRClassNC(s, m, o, mults[j][2]*f, false);
  od;             

  return out;
end);

#

InstallOtherMethod(GroupHClass, "for an inverse op D-class",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass], 
function(d)
  local h;
  h:=CreateHClass(Parent(d), LambdaOrbSCCIndex(d), LambdaOrb(d), fail, 
    fail, Representative(d), IsGreensClassNC(d));
  SetIsGroupHClass(h, true);
  return h;
end);

#

InstallOtherMethod(Idempotents, "for an inverse op D-class",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass], 
function(d)
  local creator, o;

  creator:=IdempotentCreator(Parent(d));
  o:=LambdaOrb(d);
  return List(LambdaOrbSCC(d), x-> creator(o[x], o[x]));
end);

#

InstallOtherMethod(Idempotents, "for an inverse op L-class",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass], 
l-> [RightOne(Representative(l))]);

#

InstallOtherMethod(Idempotents, "for an inverse op R-class",
[IsInverseOpClass and IsGreensRClass and IsActingSemigroupGreensClass], 
r-> [LeftOne(Representative(r))]);

#

InstallOtherMethod(Idempotents, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], 
function(s)
  local o, creator, r, out, i;

  o:=LambdaOrb(s);
  if not IsClosed(o) then      
    Enumerate(o, infinity);
  fi;

  creator:=IdempotentCreator(s);
  r:=Length(o);
  out:=EmptyPlist(r-1);

  for i in [2..r] do
    out[i-1]:=creator(o[i], o[i]);
  od;
  return out;
end);

#could do better if LambdaOrb is unknown JDM

InstallOtherMethod(Idempotents, 
"for acting semigroup with inverse op and non-negative integer",
[IsActingSemigroupWithInverseOp, IsInt], 
function(s, n)
  local o, creator, r, out, rank, len, i;

  if n<0 then 
    Error("usage: <n> must be a non-negative integer,");
    return;
  fi;

  if HasIdempotents(s) then 
    return Filtered(Idempotents(s), x-> ActionRank(x)=n);
  fi;

  o:=LambdaOrb(s);
  if not IsClosed(o) then      
    Enumerate(o, infinity);
  fi;

  creator:=IdempotentCreator(s);
  r:=Length(o);
  out:=EmptyPlist(r-1);
  rank:=LambdaRank(s);
  len:=0;

  for i in [2..r] do
    if rank(o[i])=n then 
      len:=len+1;
      out[len]:=creator(o[i], o[i]);
    fi;
  od;
  return out;
end);

#

InstallOtherMethod(RClassReps, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], s-> List(LClassReps(s), x-> x^-1));

#

InstallOtherMethod(RClassReps, "for a D-class of an acting semigroup",
[IsActingSemigroupGreensClass and IsInverseOpClass and IsGreensDClass],
d-> List(LClassReps(d), x-> x^-1));

# can't use LambdaOrb and LambdaOrbMult(s) here since if l=scc[m][1], then 
# LambdaOrbMult(o, m, l)[1] or [2]=One(o!.gens) which is not necessarily in the
# semigroup

InstallMethod(Random, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local gens, i, w;
    
  gens:=GeneratorsOfSemigroup(s);    
  i:=Random([1..Int(Length(gens)/2)]);
  w:=List([1..i], x-> Random([1..Length(gens)]));
  return EvaluateWord(gens, w);
end);

#

InstallOtherMethod(SchutzenbergerGroup, "for an inverse op L-class",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass],
l-> LambdaOrbSchutzGp(LambdaOrb(l), LambdaOrbSCCIndex(l))); 

#

InstallOtherMethod(Size, "for an acting semigroup with inversion",
[IsActingSemigroupWithInverseOp], 10, 
function(s)
  local o, scc, r, nr, m;

  o:=LambdaOrb(s);   
  scc:=OrbSCC(o);
  r:=Length(scc); 
  nr:=0;

  for m in [2..r] do 
    nr:=nr+Length(scc[m])^2*Size(LambdaOrbSchutzGp(o, m));
  od;
  return nr;
end);

#

InstallOtherMethod(Size, "for an inverse op D-class",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass],
d-> Size(SchutzenbergerGroup(d))*Length(LambdaOrbSCC(d))^2);

#

InstallOtherMethod(Size, "for an inverse op L-class",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass],
l-> Size(SchutzenbergerGroup(l))*Length(LambdaOrbSCC(l)));

#

InstallOtherMethod(HClassReps, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc, len, out, n, mults, f, m, j, k;
  
  o:=LambdaOrb(s);
  if not IsClosed(o) then 
    Enumerate(o, infinity);
  fi;
  scc:=OrbSCC(o);
  len:=Length(scc);
  
  out:=EmptyPlist(NrHClasses(s));
  n:=0; 
    
  for m in [2..len] do
    mults:=LambdaOrbMults(o, m);
    f:=RightOne(LambdaOrbRep(o, m));
    for j in scc[m] do
      f:=f*mults[j][1];
      for k in scc[m] do
        n:=n+1;
        out[n]:=mults[k][1]*f;
      od;
    od;
  od;
  return out;
end);

#

InstallOtherMethod(HClassReps, "for a inverse op D-class of acting semigroup",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
  local o, m, scc, mults, f, out, k, g, i, j;
  
  o:=LambdaOrb(d); 
  m:=LambdaOrbSCCIndex(d);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  
  f:=Representative(d);
  
  out:=EmptyPlist(Length(scc)^2);
  k:=0;
  
  for i in scc do
    g:=f*mults[i][1];
    for j in scc do
      k:=k+1;
      out[k]:=mults[j][1]*g;
    od;
  od;
  return out;
end);

#

InstallOtherMethod(HClassReps, "for an inverse op L-class",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, scc, mults, f, out, k, i;
  
  o:=LambdaOrb(l); 
  m:=LambdaOrbSCCIndex(l);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  f:=Representative(l);
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for i in scc do
    k:=k+1;
    out[k]:=mults[i][2]*f;
  od;
  return out;
end);

#

InstallMethod(IteratorOfDClassData, "for inverse acting semigroup", 
[IsActingSemigroupWithInverseOp and IsRegularSemigroup], 
function(s) 
  local record, o, scc, func, iter, f; 
 
  if not IsClosed(LambdaOrb(s)) then  
    record:=rec(m:=fail, graded:=IteratorOfGradedLambdaOrbs(s)); 
    record.NextIterator:=function(iter) 
      local l, rep, m;  
       
      m:=iter!.m;  
      if m=fail or m=Length(OrbSCC(iter!.o)) then  
        m:=1; l:=1; 
        iter!.o:=NextIterator(iter!.graded); 
        if iter!.o=fail then  
          return fail; 
        fi; 
      else 
        m:=m+1; l:=OrbSCC(iter!.o)[m][1]; 
      fi; 
      iter!.m:=m; 
         
      # rep has rectified lambda val and rho val. 
      rep:=LambdaOrbRep(iter!.o, m)*LambdaOrbMult(iter!.o, m, l)[2];  
      rep:=LambdaOrbMult(iter!.o, m, Position(iter!.o, RhoFunc(s)(rep)))[1]*rep;

      return [s, m, iter!.o, fail, fail, rep, false]; 
    end; 
 
    record.ShallowCopy:=iter-> rec(m:=fail,  
      graded:=IteratorOfGradedLambdaOrbs(s)); 
    return IteratorByNextIterator(record); 
  else 
    o:=LambdaOrb(s); 
    scc:=OrbSCC(o); 
 
    func:=function(iter, m) 
      local rep; 
      # rep has rectified lambda val and rho val. 
      rep:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, scc[m][1]));  
      rep:=LambdaOrbMult(o, m, Position(o, RhoFunc(s)(rep)))[1]*rep;
      return [s, m, o, fail, fail, rep, false]; 
    end; 
     
    return IteratorByIterator(IteratorList([2..Length(scc)]), func); 
  fi; 
end); 

#

InstallMethod(IteratorOfRClassData, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], 
function(s)
  local o, func, iter, lookup;
  
  o:=LambdaOrb(s); 
  if not IsClosed(o) then 
    func:=function(iter, i) 
      local rep;
      rep:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, i))^-1;
      # <rep> has rho val corresponding to <i> and lambda val in position 1 of
      # GradedLambdaOrb(s, rep, false), if we use <true> as the last arg, then
      # this is no longer the case, and this is would be more complicated.
      
      return [s, 1, GradedLambdaOrb(s, rep, false), rep, true]; 
    end;
    iter:=IteratorByOrbFunc(o, func, 2);
  else 
    lookup:=OrbSCCLookup(o);
    
    func:=function(iter, i)
      local rep; 
      
      # <rep> has rho val corresponding to <i> 
      rep:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, i))^-1;
     
      # rectify the lambda value of <rep>
      rep:=rep*LambdaOrbMult(o, lookup[i], Position(o, LambdaFunc(s)(rep)))[2];
      
      return [s, lookup[i], o, rep, false];     
    end;
    
    iter:=IteratorByIterator(IteratorList([2..Length(o)]), func);
  fi;
  
  return iter;
end);

#

InstallMethod(IteratorOfLClassReps, "for acting semigp with inverse op",
[IsActingSemigroupWithInverseOp],
s-> IteratorByIterator(IteratorOfRClassData(s), x-> x[4]^-1,
[IsIteratorOfLClassReps]));

#

InstallMethod(IteratorOfLClasses, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
s-> IteratorByIterator(IteratorOfRClassData(s), 
function(x)
  x[4]:=x[4]^-1;
  return CallFuncList(CreateInverseOpLClass, x);
end, [IsIteratorOfLClasses]));

#

InstallOtherMethod(NrIdempotents, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], 
s-> Length(Enumerate(LambdaOrb(s), infinity))-1);     

#

InstallOtherMethod(NrIdempotents, "for an inverse op D-class",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass], NrLClasses);   

#

InstallOtherMethod(NrIdempotents, "for an inverse op L-class",
[IsInverseOpClass and IsGreensLClass and IsActingSemigroupGreensClass], l-> 1);   

#

InstallOtherMethod(NrIdempotents, "for an inverse op R-class",
[IsInverseOpClass and IsGreensRClass and IsActingSemigroupGreensClass], r-> 1);   

#

InstallOtherMethod(NrRClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], NrLClasses);

#

InstallOtherMethod(NrRClasses, "for inverse op D-class",
[IsInverseOpClass and IsGreensDClass and IsActingSemigroupGreensClass], NrLClasses);

#

InstallOtherMethod(NrHClasses, "for an inverse op D-class of acting semigroup",
[IsActingSemigroupGreensClass and IsInverseOpClass and IsGreensDClass],
l-> Length(LambdaOrbSCC(l))^2);

#

InstallOtherMethod(NrHClasses, "for an inverse op L-class of acting semigroup",
[IsActingSemigroupGreensClass and IsInverseOpClass and IsGreensLClass],
l-> Length(LambdaOrbSCC(l)));

#

InstallOtherMethod(NrHClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc;
  o:=Enumerate(LambdaOrb(s), infinity);
  scc:=OrbSCC(o);

  return Sum(List(scc, m-> Length(m)^2))-1;
end);

#
 
InstallMethod(PartialOrderOfDClasses, "for acting semigp with inverse op",
[IsActingSemigroupWithInverseOp],      
function(s)            
  local d, n, out, o, gens, lookup, l, lambdafunc, i, x, f;
                       
  d:=GreensDClasses(s);
  n:=Length(d);
  out:=List([1..n], x-> EmptyPlist(n)); 
  o:=LambdaOrb(s);        
  gens:=o!.gens;
  lookup:=OrbSCCLookup(o);
  lambdafunc:=LambdaFunc(s);
 
  for i in [1..n] do  
    for x in gens do  
      for f in RClassReps(d[i]) do
        AddSet(out[i], lookup[Position(o, lambdafunc(x*f))]-1);      
        AddSet(out[i], lookup[Position(o, lambdafunc(f^-1*x))]-1);     
      od; 
    od;
  od; 
 
  Perform(out, ShrinkAllocationPlist);
  return out; 
end);

