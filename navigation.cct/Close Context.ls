property context

on mouseUp me
  if context <> VOID then
    context.close()
  end if
end
