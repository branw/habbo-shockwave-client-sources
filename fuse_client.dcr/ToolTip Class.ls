on new me
  return me
end

on mouseEnter me
  return me.rollover(1)
end

on mouseLeave me
  return me.rollover(0)
end

on rollover me, tBool
  if tBool then
    return createToolTip(me.pButtonText)
  else
    return removeToolTip()
  end if
end
