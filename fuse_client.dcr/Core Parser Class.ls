on new me
  return me
end

on getCommands me
  tListMus = [:]
  tListMus["BINDATA_SAVED"] = #parse_bindata_saved
  tListMus["BINDATA_AUTHKEYERROR"] = #parse_bindata_authkeyerror
  tListMus["DISCONNECT"] = #parse_disconnect
  return [#mus_data_connection: tListMus]
end

on parse_bindata_saved me, tMsg
  return [#id: tMsg.line[2]]
end

on parse_bindata_authkeyerror me, tMsg
  return [#id: tMsg.line[2]]
end

on parse_disconnect me
  return [:]
end
