on new me
  return me
end

on getCommands me
  tListMus = [:]
  tListMus["BINDATA_SAVED"] = #handle_bindata_saved
  tListMus["BINDATA_AUTHKEYERROR"] = #handle_bindata_authkeyerror
  tListMus["DISCONNECT"] = #handle_disconnect
  return [#mus_data_connection: tListMus]
end

on handle_bindata_saved me, tMsg
  getBinaryManager().binaryDataStored(tMsg[#id])
end

on handle_bindata_authkeyerror me, tMsg
  getBinaryManager().binaryDataAuthKeyError(tMsg[#id])
end

on handle_disconnect me, tMsg
  removeConnection(#mus_data_connection)
end
