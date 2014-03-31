#############################################################################
##
#W  ideals-properties.gi
#Y  Copyright (C) 2013-14                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##


InstallMethod(IsCommutativeSemigroup, "for a semigroup ideal",
[IsSemigroupIdeal],
function(I)
  local x, y;
 
  if HasParent(I) and HasIsCommutativeSemigroup(Parent(I)) and
   IsCommutativeSemigroup(Parent(I)) then 
    return true;
  fi;

  for x in GeneratorsOfSemigroupIdeal(I) do
    for y in GeneratorsOfSemigroup(SupersemigroupOfIdeal(I)) do 
      if not x*y=y*x then 
        return false;
      fi;
    od;
  od;

  return true;
end);

#

InstallMethod(IsTrivial, "for a semigroup ideal",
[IsSemigroupIdeal],
function(I)
  local gens;
  
  if HasIsTrivial(Parent(I)) and IsTrivial(Parent(I)) then 
    return true;
  fi;

  gens := GeneratorsOfSemigroupIdeal(I);
  return MultiplicativeZero(I) = gens[1] and ForAll(gens, x -> gens[1] = x);
end);

#

InstallMethod(IsFactorisableSemigroup, "for an inverse semigroup ideal",
[IsSemigroupIdeal and IsInverseSemigroup],
function(I)

  if I=SupersemigroupOfIdeal(I) then 
    return IsFactorisableSemigroup(SupersemigroupOfIdeal(I));
  fi;
  return false;
end);

# this is here so that for regular ideals this method has higher rank than the
# method for IsSemigroup.

InstallMethod(IsGroupAsSemigroup, "for a semigroup ideal",
[IsSemigroupIdeal], S-> NrRClasses(S)=1 and NrLClasses(S)=1);
