global gFieldLanguage

on AddTextToField TextID, mem
  if voidp(mem) then
    mem = "FieldTexts"
  end if
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = "="
  if voidp(gFieldLanguage) then
    gFieldLanguage = [:]
  end if
  if voidp(gFieldLanguage.getaProp(mem)) then
    p = [:]
    text = member(mem).text
    repeat with f = 1 to text.line.count
      p.addProp(text.line[f].item[1], value(text.line[f].item[2]))
    end repeat
    addProp(gFieldLanguage, mem, p)
  end if
  FieldMes = EMPTY
  p = getaProp(gFieldLanguage, mem)
  if getaProp(p, TextID & " ") <> VOID then
    FieldMes = getaProp(p, TextID & " ")
  else
    if getaProp(p, TextID) <> VOID then
      FieldMes = getaProp(p, TextID)
    end if
  end if
  the itemDelimiter = oldItemDelimiter
  if FieldMes <> EMPTY then
    return FieldMes
  else
    return TextID
  end if
end
