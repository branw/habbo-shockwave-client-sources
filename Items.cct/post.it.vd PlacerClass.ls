property ancestor
global gpopUpAdder, gpPostItNos, gPostitCounter

on new me, ttype, stripItemId, tPostItCount
  ancestor = new(script("post.it PlacerClass"), ttype, stripItemId, tPostItCount, "post.it.vd")
  if ancestor = VOID then
    return VOID
  end if
  return me
end
