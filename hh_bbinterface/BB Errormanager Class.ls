on construct me
  return 1
end

on deconstruct me
  return 1
end

on refresh me, tTopic, tdata
  if tdata = 0 then
    return 0
  end if
  case tdata[#reasonstr] of
    "game_deleted":
      tAlertStr = "bb_error_game_deleted"
    "invalidparam":
      tAlertStr = "bb_error_invalid"
    "notickets":
      tAlertStr = "bb_error_notickets"
    "dailylimit":
      tAlertStr = "bb_error_dailylimit"
    "blockedip":
      tAlertStr = "bb_error_blockedip"
    otherwise:
      tAlertStr = "bb_error_" & tdata[#request] & "_" & tdata[#reasonstr]
  end case
  return executeMessage(#alert, [#id: "bb_error", #msg: tAlertStr])
end
