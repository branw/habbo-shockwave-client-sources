property ancestor

on new me, towner, tlocation, tid, tdata
  ancestor = new(script("post.it ItemClass"), towner, tlocation, tid, tdata, "post.it.vd")
  return me
end
