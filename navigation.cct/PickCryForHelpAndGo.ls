property context

on mouseUp me
  global CryHelp, CryCount, gPopUpContext2, gChosenFlatDoorMode, gFloorHost, gFloorPort, gChosenUnitIp, gChosenUnitPort, gUnits
  if voidp(CryHelp) then
    return 
  end if
  if CryCount < 1 or CryCount > CryHelp.count then
    CryCount = CryHelp.count
  end if
  if CryCount = 0 then
    return 
  end if
  if getaProp(CryHelp[CryCount], "CryPrivate").length > 20 and getaProp(CryHelp[CryCount], "Unit") contains "Private Room" then
    s = getaProp(CryHelp[CryCount], "CryPrivate")
    oldDelim = the itemDelimiter
    the itemDelimiter = "/"
    tRoomId = integer(s.item[1])
    gChosenFlatDoorMode = s.item[4]
    gFloorHost = s.item[8]
    gFloorPort = s.item[9]
    member(getmemnum("goingto_roomname")).text = s.item[2]
    member(getmemnum("room.info")).text = AddTextToField("Room") && s.item[2] & RETURN & AddTextToField("Owner") && s.item[3]
    sendEPFuseMsg("PICK_CRYFORHELP" && CryHelp.getaProp(CryHelp.getPropAt(CryCount)).getaProp("url"))
    context.close()
    if gPopUpContext2 = VOID then
      openNavigator()
    end if
    the itemDelimiter = oldDelim
    GoToFlatWithNavi(tRoomId)
  else
    if not (getaProp(CryHelp[CryCount], "Unit") contains "Private Room") then
      tUnitName = getaProp(CryHelp[CryCount], "Unit")
      tUnit = gUnits.getaProp(tUnitName)
      if listp(tUnit) then
        host = tUnit.getaProp("host")
        gChosenUnitIp = char offset("/", host) + 1 to host.length of host
        gChosenUnitPort = tUnit.getaProp("port")
        context.close()
        member("LoadPublicRoom").text = AddTextToField("LoadingPublicRoom") & RETURN & tUnitName
        sFrame = "loading_public"
        if gPopUpContext2 = VOID then
          openNavigator()
        end if
        goContext(sFrame, gPopUpContext2)
        updateStage()
        goUnit(tUnit["name"], getaProp(CryHelp[CryCount], "gDoor"))
        sendEPFuseMsg("PICK_CRYFORHELP" && CryHelp.getaProp(CryHelp.getPropAt(CryCount)).getaProp("url"))
      else
        beep(2)
      end if
    end if
  end if
end

on exitFrame me
  global CryHelp, CryCount
  if voidp(CryHelp) then
    return 
  end if
  if CryCount < 1 or CryCount > CryHelp.count then
    return 
  end if
  if getaProp(CryHelp[CryCount], "CryPrivate").length < 20 and getaProp(CryHelp[CryCount], "Unit") contains "Private Room" then
    sprite(me.spriteNum).blend = 30
  else
    sprite(me.spriteNum).blend = 100
  end if
end
