on secretDecode key
  l = key.length
  if l mod 2 = 1 then
    l = l - 1
  end if
  table = char 1 to key.length / 2 of key
  key = char 1 + key.length / 2 to l of key
  put key.length && table.length
  checkSum = 0
  repeat with i = 1 to key.length
    c = char i of key
    a = offset(c, table) - 1
    if a mod 2 = 0 then
      a = a * 2
    end if
    if (i - 1) mod 3 = 0 then
      a = a * 3
    end if
    if a < 0 then
      a = key.length mod 2
    end if
    checkSum = checkSum + a
  end repeat
  return checkSum
end
