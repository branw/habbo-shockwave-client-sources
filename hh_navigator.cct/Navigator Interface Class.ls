property pWindowTitle, pOpenWindow, pFlatPasswords, pUnitList, pFlatList, pVisibleFlatCount, pPrivateDropMode, pCurrentFlatData, pLastClickedUnitId, pLastFlatSearch, pFlatsPerView, pFlatInfoAction, pUnitDrawObjs, pCachedFlatImg, pBufferDepth, pListItemHeight, pPublicListWidth, pPublicListHeight, pPublicUnitsImg, pPrivateListImg, PHotelEntryImg, pPublicDotLineImg, pFlatGoTextImg, pResourcesReady, pWriterPrivPlain, pWriterPrivUnder, pWriterPlainNormLeft, pWriterPlainBoldLeft, pWriterPlainBoldCent, pWriterUnderNormLeft, pWriterPlainNormWrap

on construct me
  pWindowTitle = getText("navigator", "Hotel Navigator")
  pFlatPasswords = [:]
  pUnitDrawObjs = [:]
  pUnitList = [:]
  pFlatList = [:]
  pVisibleFlatCount = 0
  pPublicListWidth = 251
  pPublicListHeight = 1
  pListItemHeight = 10
  pOpenWindow = #nothing
  pLastFlatSearch = EMPTY
  pPrivateDropMode = "nav_rooms_popular"
  pCachedFlatImg = 0
  pBufferDepth = 32
  pFlatInfoAction = 0
  pFlatsPerView = getIntVariable("navigator.private.count", 40)
  pResourcesReady = 0
  return me.createImgResources()
end

on deconstruct me
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  if timeoutExists(#login_blinker) then
    removeTimeout(#login_blinker)
  end if
  me.removeImgResources()
  removeObject(#navigator_login)
  return 1
end

on getLogin me
  tid = #navigator_login
  if not objectExists(tid) then
    createObject(tid, "Login Dialogs Class")
  end if
  return getObject(tid)
end

on showNavigator me
  if windowExists(pWindowTitle) then
    getWindow(pWindowTitle).show()
  else
    if me.ChangeWindowView("nav_public_start.window") then
      pPrivateDropMode = "nav_rooms_popular"
      me.delay(2, #renderUnitList)
      return 1
    end if
  end if
  return 0
end

on hideNavigator me, tHideOrRemove
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  if windowExists(pWindowTitle) then
    if tHideOrRemove = #remove then
      removeWindow(pWindowTitle)
    else
      getWindow(pWindowTitle).hide()
    end if
  end if
  return 1
end

on showhidenavigator me, tHideOrRemove
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  if windowExists(pWindowTitle) then
    if getWindow(pWindowTitle).getProperty(#visible) then
      me.hideNavigator(tHideOrRemove)
    else
      getWindow(pWindowTitle).show()
    end if
  else
    pPrivateDropMode = "nav_rooms_popular"
    me.getComponent().getUnitUpdates()
    if not voidp(pLastClickedUnitId) then
      me.ChangeWindowView("nav_public_info.window")
      me.CreatepublicRoomInfo(pLastClickedUnitId)
    else
      me.ChangeWindowView("nav_public_start.window")
    end if
  end if
end

on showDisconnectionDialog me
  me.hideNavigator()
  createWindow(#error, "error.window", 0, 0, #modal)
  tWndObj = getWindow(#error)
  tWndObj.getElement("error_title").setText(getText("Alert_ConnectionFailure"))
  tWndObj.getElement("error_text").setText(getText("Alert_ConnectionDisconnected"))
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDisconnect, me.getID(), #mouseUp)
  the keyboardFocusSprite = 0
end

on saveFlatInfo me, tFlatData
  pCurrentFlatData = tFlatData
  case pFlatInfoAction of
    #enterflat:
      tFlatPort = pCurrentFlatData[#port]
      pCurrentFlatData[#ip] = me.getComponent().getFlatIp(tFlatPort)
      if pCurrentFlatData[#owner] = getObject(#session).get("user_name") then
        tDoor = "open"
      else
        tDoor = pCurrentFlatData[#door]
        pFlatPasswords = [:]
      end if
      case tDoor of
        "open", "closed":
          if voidp(pCurrentFlatData) then
            return error(me, "Can't enter flat, no room is selected!!!", #saveFlatInfo)
          end if
          me.getComponent().updateState("enterFlat", pCurrentFlatData[#id])
        "password":
          me.ChangeWindowView("nav_private_password.window")
          getWindow(pWindowTitle).getElement("nav_roomname_text").setText(pCurrentFlatData[#name])
          me.CreatePrivateRoomInfo(pCurrentFlatData)
      end case
      pFlatInfoAction = 0
    #flatInfo:
      me.ChangeWindowView("nav_private_info.window")
      me.CreatePrivateRoomInfo(pCurrentFlatData)
      pFlatInfoAction = 0
    #modifyInfo:
      me.modifyPrivateRoom(pCurrentFlatData)
      pFlatInfoAction = 0
    otherwise:
      error(me, "Unknown action:" && pFlatInfoAction, #saveFlatInfo)
  end case
end

on createImgResources me
  if pResourcesReady then
    return 0
  end if
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  pListItemHeight = tPlain.getaProp(#lineHeight) + 4
  createWriter("nav_plain_norm_left", tPlain)
  pWriterPlainNormLeft = getWriter("nav_plain_norm_left")
  createWriter("nav_plain_bold_left", tBold)
  pWriterPlainBoldLeft = getWriter("nav_plain_bold_left")
  createWriter("nav_under_norm_left", tLink)
  pWriterUnderNormLeft = getWriter("nav_under_norm_left")
  createWriter("nav_plain_bold_cent", tBold)
  pWriterPlainBoldCent = getWriter("nav_plain_bold_cent")
  pWriterPlainBoldCent.define([#alignment: #center])
  createWriter("nav_plain_norm_wrap", tPlain)
  pWriterPlainNormWrap = getWriter("nav_plain_norm_wrap")
  pWriterPlainNormWrap.define([#wordWrap: 1])
  createWriter("nav_private_plain", tPlain)
  pWriterPrivPlain = getWriter("nav_private_plain")
  pWriterPrivPlain.define([#boxType: #adjust, #wordWrap: 1, #fixedLineSpace: pListItemHeight])
  createWriter("nav_private_under", tLink)
  pWriterPrivUnder = getWriter("nav_private_under")
  pWriterPrivUnder.define([#boxType: #adjust, #wordWrap: 0, #fixedLineSpace: pListItemHeight])
  pPublicDotLineImg = image(pPublicListWidth, 1, pBufferDepth)
  repeat with tXPoint = 0 to pPublicListWidth / 2
    pPublicDotLineImg.setPixel(tXPoint * 2, 0, rgb(0, 0, 0))
  end repeat
  pFlatGoTextImg = pWriterUnderNormLeft.render(getText("nav_gobutton")).duplicate()
  tTempImg = pWriterUnderNormLeft.render(getText("nav_hotelview"))
  PHotelEntryImg = image(pPublicListWidth, tTempImg.height, pBufferDepth)
  x1 = 5
  x2 = x1 + tTempImg.width
  y1 = 0
  y2 = tTempImg.height
  tdestrect = rect(x1, y1, x2, y2)
  PHotelEntryImg.copyPixels(tTempImg, tdestrect, tTempImg.rect)
  x1 = x2
  y1 = PHotelEntryImg.height - 1
  x2 = PHotelEntryImg.width - 5
  y2 = y1 + 1
  tdestrect = rect(x1, y1, x2, y2)
  tSourceRect = rect(0, 0, x2 - x1, 1)
  PHotelEntryImg.copyPixels(pPublicDotLineImg, tdestrect, tSourceRect)
  x1 = PHotelEntryImg.width - pFlatGoTextImg.width + 2
  y1 = 0
  x2 = x1 + pFlatGoTextImg.width
  y2 = y1 + pFlatGoTextImg.height
  tdestrect = rect(x1, y1, x2, y2)
  PHotelEntryImg.copyPixels(pFlatGoTextImg, tdestrect, pFlatGoTextImg.rect)
  pResourcesReady = 1
  return 1
end

on removeImgResources me
  if not pResourcesReady then
    return 0
  end if
  removeWriter(pWriterPlainNormLeft.getID())
  pWriterPlainNormLeft = VOID
  removeWriter(pWriterPlainBoldLeft.getID())
  pWriterPlainBoldLeft = VOID
  removeWriter(pWriterUnderNormLeft.getID())
  pWriterUnderNormLeft = VOID
  removeWriter(pWriterPlainBoldCent.getID())
  pWriterPlainBoldCent = VOID
  removeWriter(pWriterPlainNormWrap.getID())
  pWriterPlainNormWrap = VOID
  removeWriter(pWriterPrivPlain.getID())
  pWriterPrivPlain = VOID
  removeWriter(pWriterPrivUnder.getID())
  pWriterPrivUnder = VOID
  pResourcesReady = 0
  return 1
end

on createUnitlist me, tUnitlist
  pUnitList = [:]
  repeat with f = 1 to tUnitlist.count()
    me.UpdateListOfUnits(tUnitlist.getPropAt(f), tUnitlist[tUnitlist.getPropAt(f)], #closed)
  end repeat
  repeat with f = 1 to pUnitList.count
    tUnitid = pUnitList.getPropAt(f)
    tUnitName = pUnitList[pUnitList.getPropAt(f)][#name]
    if voidp(pUnitDrawObjs[tUnitid]) then
      tProps = [:]
      tProps[#id] = tUnitid
      tProps[#name] = tUnitName
      tProps[#height] = pListItemHeight
      tProps[#dotline] = pPublicDotLineImg
      tProps[#number] = 666
      tObject = createObject(#temp, "Draw Unit Class")
      tObject.define(tProps)
      pUnitDrawObjs.addProp(tUnitid, tObject)
    end if
    if pUnitList[f][#visible] = 1 then
      pVisibleFlatCount = pVisibleFlatCount + 1
    end if
  end repeat
  me.renderUnitList()
end

on UpdateUnitList me, tUnitlist
  repeat with f = 1 to tUnitlist.count()
    me.UpdateListOfUnits(tUnitlist.getPropAt(f), tUnitlist[tUnitlist.getPropAt(f)], VOID)
  end repeat
  me.renderUnitList()
end

on UpdateListOfUnits me, tUnitid, tUnitData, tstate
  tUnit = tUnitData
  if voidp(tstate) then
    if not voidp(pUnitList[tUnitid][#multiroomOpen]) then
      tstate = pUnitList[tUnitid][#multiroomOpen]
    else
      tstate = #closed
    end if
  end if
  if tUnitData[#subunitcount] = 0 then
    tUnit[#type] = #subUnit
    if not voidp(tUnit[#mymainunitid]) then
      tMyMainId = tUnit[#mymainunitid]
    else
      return 0
    end if
    if not voidp(pUnitList[tMyMainId]) then
      if pUnitList[tMyMainId][#multiroomOpen] = #open then
        tUnit[#visible] = 1
      else
        tUnit[#visible] = 0
      end if
    else
      tUnit[#visible] = 0
    end if
  else
    if tUnitData[#subunitcount] = 1 then
      tUnit[#type] = #mainUnit
      tUnit[#visible] = 1
    else
      if tUnitData[#subunitcount] > 1 then
        tUnit[#type] = #MultiUnit
        tUnit[#visible] = 1
        tUnit[#multiroomOpen] = tstate
      end if
    end if
  end if
  pUnitList[tUnitid] = tUnit
end

on renderUnitList me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElement = tWndObj.getElement("nav_public_rooms_list")
  if tElement = 0 then
    return 0
  end if
  pVisibleFlatCount = 0
  repeat with f = 1 to pUnitList.count()
    tUnitid = pUnitList.getPropAt(f)
    if pUnitList[tUnitid][#visible] = 1 then
      pVisibleFlatCount = pVisibleFlatCount + 1
      pUnitDrawObjs[tUnitid].pPropList[#number] = pVisibleFlatCount
    end if
  end repeat
  if pPublicListHeight <> (pVisibleFlatCount + 1) * pListItemHeight then
    pPublicListHeight = (pVisibleFlatCount + 1) * pListItemHeight
    pPublicUnitsImg = image(pPublicListWidth, pPublicListHeight, pBufferDepth)
  end if
  pPublicUnitsImg.copyPixels(PHotelEntryImg, PHotelEntryImg.rect, PHotelEntryImg.rect)
  call(#render, pUnitDrawObjs, pPublicUnitsImg)
  tElement.feedImage(pPublicUnitsImg)
end

on getUnitData me, tUnitName
  return pUnitList[tUnitName]
end

on ChangeWindowView me, tWindowName
  tWndObj = getWindow(pWindowTitle)
  tScrollOffset = 0
  if tWndObj <> 0 then
    if tWindowName contains "public" and tWndObj.elementExists("scroll_public") then
      tScrollOffset = tWndObj.getElement("scroll_public").getScrollOffset()
    end if
    tWndObj.unmerge()
  else
    if not createWindow(pWindowTitle, "habbo_basic.window", 382, 73) then
      return error(me, "Failed to create window for Navigator!", #ChangeWindowView)
    end if
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
  end if
  tWndObj.merge(tWindowName)
  pOpenWindow = tWindowName
  if tWindowName contains "public" then
    tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseDown)
    tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #keyDown)
    if not voidp(pPublicUnitsImg) and tWndObj.elementExists("nav_public_rooms_list") then
      tWndObj.getElement("nav_public_rooms_list").feedImage(pPublicUnitsImg)
      if tScrollOffset > 0 and tWndObj.elementExists("scroll_public") then
        tWndObj.getElement("scroll_public").setScrollOffset(tScrollOffset)
      end if
    end if
  else
    if tWindowName contains "private" then
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #keyDown)
      if pPrivateDropMode <> "nav_rooms_search" then
        me.searchPrivateRooms(0)
      end if
      if tWndObj.elementExists("nav_private_dropdown") then
        tWndObj.getElement("nav_private_dropdown").setSelection(pPrivateDropMode)
      end if
    else
      return error(me, "Couldn't solve Navigator's state:" && tWindowName, #ChangeWindowView)
    end if
  end if
  return 1
end

on renderLoadingText me, tTempElementId
  if voidp(tTempElementId) then
    return 0
  end if
  tElem = getWindow(pWindowTitle).getElement(tTempElementId)
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, pBufferDepth)
  tTextImg = pWriterPlainBoldCent.render(getText("loading"))
  tOffX = (tWidth - tTextImg.width) / 2
  tOffY = (tHeight - tTextImg.height) / 2
  tDstRect = tTextImg.rect + rect(tOffX, tOffY, tOffX, tOffY)
  tTempImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  tElem.feedImage(tTempImg)
  return 1
end

on updateUnitUsers me, tUsersStr
  if pOpenWindow = "nav_public_people.window" then
    tWndObj = getWindow(pWindowTitle)
    if tWndObj.elementExists("nav_people_list") then
      tElem = tWndObj.getElement("nav_people_list")
      tWidth = tElem.getProperty(#width)
      tHeight = tElem.getProperty(#height)
      pWriterPlainNormWrap.define([#rect: rect(0, 0, tWidth, 0)])
      tImage = pWriterPlainNormWrap.render(tUsersStr).duplicate()
      if tWndObj.elementExists("scroll_people_list") then
        if tHeight > tImage.height then
          tWndObj.getElement("scroll_people_list").hide()
        else
          tWndObj.getElement("scroll_people_list").show()
        end if
      end if
      tElem.feedImage(tImage)
    end if
  end if
end

on GetUnitUsers me, tUnitid
  if not voidp(tUnitid) then
    if pOpenWindow <> "nav_public_people.window" then
      me.ChangeWindowView("nav_public_people.window")
    end if
    if pUnitList[tUnitid][#type] = #subUnit then
      tMainUnitID = pUnitList[tUnitid][#mymainunitid]
      tMainUnitName = pUnitList[tMainUnitID][#name]
      me.getComponent().GetUnitUsers(tMainUnitName, pUnitList[tUnitid][#name])
    else
      me.getComponent().GetUnitUsers(pUnitList[tUnitid][#name], VOID)
    end if
  end if
end

on CreatepublicRoomInfo me, tUnitid
  if voidp(tUnitid) then
    return error(me, "Cant create room info because unitID is VOID", #CreatepublicRoomInfo)
  end if
  if pOpenWindow <> "nav_public_info.window" then
    me.ChangeWindowView("nav_public_info.window")
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("nav_roominfo")
  if tElem = 0 then
    return 0
  end if
  tInfo = getText("nav_roominfo_" & tUnitid, EMPTY)
  tWidth = tElem.getProperty(#width)
  pWriterPlainNormWrap.define([#rect: rect(0, 0, tWidth, 0)])
  tImage = pWriterPlainNormWrap.render(tInfo).duplicate()
  tElem.feedImage(tImage)
  tIconName = getVariable("thumb." & tUnitid)
  if memberExists(tIconName) then
    tIconMemNum = getmemnum(tIconName)
    if tIconMemNum <> 0 then
      tWndObj.getElement("public_room_icon").feedImage(member(tIconMemNum).image)
    else
      tWndObj.getElement("public_room_icon").clearImage()
    end if
  end if
end

on saveFlatList me, tFlats, tMode
  pFlatList = tFlats
  if not (pOpenWindow contains "private") then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElement = tWndObj.getElement("nav_private_rooms_list")
  if tElement = 0 then
    return 0
  end if
  if tMode = #cached then
    if pCachedFlatImg <> 0 then
      pPrivateListImg = pCachedFlatImg
      tElement.feedImage(pPrivateListImg)
      return 1
    else
      tMode = #busy
    end if
  end if
  pBufferDepth = tElement.getProperty(#depth)
  tItemWidth = tElement.getProperty(#width)
  pPrivateListImg = image(tItemWidth, tFlats.count() * pListItemHeight, pBufferDepth)
  tUsersTxt = EMPTY
  tFlatstxt = EMPTY
  tLockMemImgA = member(getmemnum("lock1")).image
  tLockMemImgB = member(getmemnum("lock2")).image
  repeat with f = 1 to tFlats.count
    tFlat = tFlats[f]
    tUsersTxt = tUsersTxt & tFlat[#usercount] & RETURN
    tFlatstxt = tFlatstxt & tFlat[#name] & RETURN
    tSrcRect = rect(0, 0, tItemWidth - 30, 1)
    tCurrLocY = f * pListItemHeight
    tDstRect = tSrcRect + rect(20, tCurrLocY - 1, 20, tCurrLocY - 1)
    pPrivateListImg.copyPixels(pPublicDotLineImg, tDstRect, tSrcRect)
    tDstRect = pFlatGoTextImg.rect + rect(tItemWidth - pFlatGoTextImg.width, tCurrLocY - pFlatGoTextImg.height, tItemWidth - pFlatGoTextImg.width, tCurrLocY - pFlatGoTextImg.height)
    pPrivateListImg.copyPixels(pFlatGoTextImg, tDstRect, pFlatGoTextImg.rect)
    if tFlat[#door] <> "open" then
      case tFlat[#door] of
        "closed":
          tLockImg = tLockMemImgA
        "password":
          tLockImg = tLockMemImgB
        otherwise:
          tLockImg = 0
      end case
      if tLockImg <> 0 then
        tSrcRect = tLockImg.rect
        tDstRect = tSrcRect + rect(tItemWidth - pFlatGoTextImg.width - 20, tCurrLocY - tLockImg.height * 1.5, tItemWidth - pFlatGoTextImg.width - 20, tCurrLocY - tLockImg.height * 1.5)
        pPrivateListImg.copyPixels(tLockImg, tDstRect, tSrcRect)
      end if
    end if
  end repeat
  tUsersTxt = tUsersTxt.line[1..tUsersTxt.line.count - 1]
  tFlatstxt = tFlatstxt.line[1..tFlatstxt.line.count - 1]
  tTempRoomNamesImg = pWriterPrivUnder.render(tFlatstxt)
  tTempUserCountImg = pWriterPrivPlain.render(tUsersTxt)
  tDstRect = tTempUserCountImg.rect + rect(0, 0, 0, 0)
  pPrivateListImg.copyPixels(tTempUserCountImg, tDstRect, tTempUserCountImg.rect)
  tDstRect = tTempRoomNamesImg.rect + rect(20, 0, 20, 0)
  pPrivateListImg.copyPixels(tTempRoomNamesImg, tDstRect, tTempRoomNamesImg.rect)
  if tMode = #busy then
    pCachedFlatImg = pPrivateListImg
  end if
  tElement.feedImage(pPrivateListImg)
  return 1
end

on CreatePrivateRoomInfo me, tRoomData
  if listp(tRoomData) then
    pCurrentFlatData = tRoomData
  end if
  if voidp(pCurrentFlatData) then
    return error(me, "Can't create flat info, 'pCurrentFlatData' is VOID!", #CreatePrivateRoomInfo)
  end if
  if voidp(pPrivateDropMode) then
    return error(me, "Can't create flat info, 'pPrivateDropMode' is VOID!", #CreatePrivateRoomInfo)
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return error(me, "Window doesn't exist!", #CreatePrivateRoomInfo)
  end if
  if pPrivateDropMode = "nav_rooms_favourite" then
    me.ChangeWindowView("nav_private_removefavorite.window")
  end if
  if voidp(pPrivateListImg) then
    error(me, "Invalid image buffer:" && pPrivateListImg, #CreatePrivateRoomInfo)
  else
    if tWndObj.elementExists("nav_private_rooms_list") then
      tWndObj.getElement("nav_private_rooms_list").feedImage(pPrivateListImg)
    end if
  end if
  if voidp(pCurrentFlatData[#name]) then
    pCurrentFlatData[#name] = "-"
  end if
  if voidp(pCurrentFlatData[#usercount]) then
    pCurrentFlatData[#usercount] = "-"
  end if
  if voidp(pCurrentFlatData[#owner]) then
    pCurrentFlatData[#owner] = "-"
  end if
  if voidp(pCurrentFlatData[#description]) then
    pCurrentFlatData[#description] = "-"
  end if
  tRoomName = pCurrentFlatData[#name] && "(" & tRoomData[#usercount] & "/25)" & RETURN
  tRoomName = tRoomName & getText("nav_owner") & ":" && pCurrentFlatData[#owner]
  tRoomInfo = pCurrentFlatData[#description]
  tElem = tWndObj.getElement("nav_room_name_owner")
  if tElem <> 0 then
    tWidth = tElem.getProperty(#width)
    tImage = pWriterPlainBoldLeft.render(tRoomName)
    tElem.feedImage(tImage)
  end if
  tElem = tWndObj.getElement("nav_roominfo")
  if tElem <> 0 then
    tWidth = tElem.getProperty(#width)
    pWriterPlainNormWrap.define([#rect: rect(0, 0, tWidth, 0)])
    tImage = pWriterPlainNormWrap.render(tRoomInfo)
    tElem.feedImage(tImage)
  end if
  if tWndObj.elementExists("nav_door_icon") then
    if voidp(pCurrentFlatData[#door]) then
      return 0
    end if
    case pCurrentFlatData[#door] of
      "open":
        tLockmem = "door_open"
      "closed":
        tLockmem = "door_closed"
      "password":
        tLockmem = "door_password"
    end case
    return error(me, "Saved flat data is not valid!", #CreatePrivateRoomInfo)
    if memberExists(tLockmem) then
      tDoorImg = member(getmemnum(tLockmem)).image
      tWndObj.getElement("nav_door_icon").feedImage(tDoorImg)
    end if
  end if
  if tWndObj.elementExists("nav_modify_button") and not voidp(tRoomData[#owner]) then
    if tRoomData[#owner] = getObject(#session).get("user_name") then
      tWndObj.getElement("nav_modify_button").show()
    else
      tWndObj.getElement("nav_modify_button").hide()
    end if
  end if
end

on modifyPrivateRoom me
  pFlatPasswords = [:]
  if pCurrentFlatData[#owner] <> getObject(#session).get("user_name") then
    return 0
  end if
  me.ChangeWindowView("nav_private_modify.window")
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [#name: "nav_modify_roomnamefield", #description: "nav_modify_roomdescription_field"]
  repeat with f = 1 to tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tField = tTempProps[tProp]
    if tWndObj.elementExists(tField) then
      if not voidp(pCurrentFlatData[tProp]) then
        tWndObj.getElement(tField).setText(pCurrentFlatData[tProp])
      end if
    end if
  end repeat
  tCheckOnImg = member(getmemnum("button.checkbox.on")).image
  tCheckOffImg = member(getmemnum("button.checkbox.off")).image
  if pCurrentFlatData[#showownername] = 1 then
    me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
  else
    me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
  end if
  case pCurrentFlatData[#door] of
    "open":
      me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
    "closed":
      me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
    "password":
      me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
  end case
  me.updateCheckButton("nav_modify_furnituremove_check", #ableothersmovefurniture, VOID)
end

on checkPasswords me
  tElementId1 = "nav_modify_door_pw"
  tElementId2 = "nav_modify_door_pw2"
  if voidp(pFlatPasswords[tElementId1]) then
    tPw1 = []
  else
    tPw1 = pFlatPasswords[tElementId1]
  end if
  if voidp(pFlatPasswords[tElementId2]) then
    tPw2 = []
  else
    tPw2 = pFlatPasswords[tElementId2]
  end if
  if tPw1.count = 0 then
    executeMessage(#alert, [#msg: "Alert_ForgotSetPassword"])
    return 0
  end if
  if tPw1.count < 3 then
    executeMessage(#alert, [#msg: "Alert_YourPasswordIstooShort"])
    return 0
  end if
  if tPw1 <> tPw2 then
    executeMessage(#alert, [#msg: "Alert_WrongPassword"])
    return 0
  end if
  return 1
end

on getPassword me, tElementId
  tPw = EMPTY
  if voidp(pFlatPasswords[tElementId]) then
    return "null"
  end if
  repeat with f in pFlatPasswords[tElementId]
    tPw = tPw & f
  end repeat
  return tPw
end

on updateRadioButton me, tElement, tListOfOthersElements
  if voidp(pCurrentFlatData) then
    return error(me, "Can't update radio buttons!", #updateRadioButton)
  end if
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat with tRadioElement in tListOfOthersElements
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateCheckButton me, tElement, tProp, tChangeMode
  if voidp(pCurrentFlatData) then
    return error(me, "Can't update check buttons!", #updateCheckButton)
  end if
  tOnImg = member(getmemnum("button.checkbox.on")).image
  tOffImg = member(getmemnum("button.checkbox.off")).image
  tWndObj = getWindow(pWindowTitle)
  if voidp(pCurrentFlatData[tProp]) then
    pCurrentFlatData[tProp] = 1
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pCurrentFlatData[tProp] = 1 then
      pCurrentFlatData[tProp] = 0
    else
      pCurrentFlatData[tProp] = 1
    end if
  end if
  if pCurrentFlatData[tProp] = 1 then
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on searchPrivateRooms me, tMode
  if pOpenWindow contains "private" then
    tWndObj = getWindow(pWindowTitle)
    if not tWndObj.elementExists("nav_private_search_field") then
      return 0
    end if
    if tMode = 1 then
      pPrivateDropMode = "nav_rooms_search"
      tWndObj.getElement("nav_private_dropdown").setSelection("nav_rooms_search")
      tElement = tWndObj.getElement("nav_private_search_field")
      tElement.setText(EMPTY)
      tElement.setEdit(1)
      tElement.setProperty(#blend, 100)
      if tWndObj.elementExists("nav_private_button_search") then
        tWndObj.getElement("nav_private_button_search").Activate()
      end if
      if tWndObj.elementExists("nav_search_field_bg") then
        tWndObj.getElement("nav_search_field_bg").setProperty(#blend, 100)
      end if
    else
      pLastFlatSearch = EMPTY
      tElement = tWndObj.getElement("nav_private_search_field")
      tElement.setText(EMPTY)
      tElement.setEdit(0)
      tElement.setProperty(#blend, 30)
      if tWndObj.elementExists("nav_private_button_search") then
        tWndObj.getElement("nav_private_button_search").deactivate()
      end if
      if tWndObj.elementExists("nav_search_field_bg") then
        tWndObj.getElement("nav_search_field_bg").setProperty(#blend, 30)
      end if
    end if
  end if
end

on makePrivateRoomSearch me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists("nav_private_search_field") then
    tSearchQuery = tWndObj.getElement("nav_private_search_field").getText()
    if pLastFlatSearch <> tSearchQuery then
      pLastFlatSearch = tSearchQuery
      if tSearchQuery = EMPTY then
        return me.failedFlatSearch(getText("nav_prvrooms_notfound"))
      end if
      me.renderLoadingText("nav_private_rooms_list")
      me.getComponent().searchFlats(tSearchQuery)
    end if
  end if
end

on roomkioskGoingFlat me, tRoomId
  pFlatInfoAction = #enterflat
  me.getComponent().getFlatInfo(tRoomId)
end

on failedFlatSearch me, tText
  tElem = getWindow(pWindowTitle).getElement("nav_private_rooms_list")
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, 8)
  tTextImg = pWriterPlainNormLeft.render(tText)
  tTempImg.copyPixels(tTextImg, tTextImg.rect + rect(8, 5, 8, 5), tTextImg.rect)
  tElem.feedImage(tTempImg)
end

on getFlatPassword me
  if voidp(pCurrentFlatData) then
    return 0
  end if
  if pCurrentFlatData[#door] <> "password" then
    return 0
  end if
  if voidp(pCurrentFlatData[#password]) then
    return 0
  else
    return pCurrentFlatData[#password]
  end if
end

on flatPasswordIncorrect me
  me.ChangeWindowView("nav_private_pw_incorrect.window")
  getWindow(pWindowTitle).getElement("nav_roomname_text").setText(pCurrentFlatData[#name])
end

on roomlistupdate me
  if not voidp(pOpenWindow) and windowExists(pWindowTitle) then
    if pOpenWindow contains "public" then
      me.getComponent().getUnitUpdates()
    else
      if pOpenWindow contains "private" then
        case pPrivateDropMode of
          "nav_rooms_own":
            me.getComponent().getOwnFlats()
          "nav_rooms_popular":
            me.getComponent().searchBusyFlats(0, pFlatsPerView, #update)
          "nav_rooms_favourite":
            me.getComponent().getFavouriteFlats()
          "nav_rooms_search":
            me.searchPrivateRooms(1)
        end case
        return 0
      end if
    end if
  end if
end

on eventProcNavigatorPublic me, tEvent, tSprID, tParm
  if tEvent = #mouseDown then
    case tSprID of
      "nav_private_tab":
        me.ChangeWindowView("nav_private_start.window")
        pPrivateDropMode = "nav_rooms_popular"
        if not me.getComponent().searchBusyFlats(0, pFlatsPerView) then
          me.renderLoadingText("nav_private_rooms_list")
        end if
      "nav_public_rooms_list":
        if not ilk(tParm, #point) or pUnitList.count = 0 then
          return 
        end if
        if pOpenWindow = "nav_public_start.window" then
          me.ChangeWindowView("nav_public_info.window")
        end if
        tClickLine = integer(tParm.locV / pListItemHeight)
        if tClickLine < 1 then
          tGoLinkArea = pPublicListWidth - pFlatGoTextImg.width
          if tParm.locH > tGoLinkArea then
            getConnection(getVariable("connection.info.id")).send(#room, "QUIT")
            return me.getComponent().updateState("enterEntry")
          else
            return 1
          end if
        end if
        if tClickLine > pVisibleFlatCount then
          tClickLine = pVisibleFlatCount
        end if
        call(#getClickedUnitName, pUnitDrawObjs, tClickLine)
        tClickedUnit = the result
        if not stringp(tClickedUnit) then
          return error(me, "Navigator room list error", #eventProcNavigator)
        end if
        if voidp(pUnitList[tClickedUnit]) then
          return error(me, "Unit data not found:" && tClickedUnit, #eventProcNavigator)
        end if
        pLastClickedUnitId = tClickedUnit
        tGoLinkH = pPublicListWidth - pFlatGoTextImg.width
        if tParm.locH > tGoLinkH and pUnitList[tClickedUnit][#type] <> #MultiUnit then
          return me.getComponent().updateState("enterUnit", tClickedUnit)
        else
          if pOpenWindow = "nav_public_info.window" then
            me.CreatepublicRoomInfo(tClickedUnit)
          else
            me.GetUnitUsers(tClickedUnit)
          end if
          if pUnitList[tClickedUnit][#type] = #MultiUnit then
            if pUnitList[tClickedUnit][#multiroomOpen] = #open then
              tstate = #closed
            else
              tstate = #open
            end if
            pUnitList[tClickedUnit][#multiroomOpen] = tstate
            if not voidp(pUnitList.findPos(tClickedUnit)) then
              tMainPos = pUnitList.findPos(tClickedUnit)
            end if
            repeat with f = tMainPos + 1 to tMainPos + pUnitList[tClickedUnit][#subunitcount]
              if tstate = #open then
                pUnitList[pUnitList.getPropAt(f)][#visible] = 1
                next repeat
              end if
              pUnitList[pUnitList.getPropAt(f)][#visible] = 0
            end repeat
            me.renderUnitList()
          end if
        end if
      "nav_public_people_tab":
        me.GetUnitUsers(pLastClickedUnitId)
      "nav_public_info_tab":
        me.CreatepublicRoomInfo(pLastClickedUnitId)
      "create_room", "nav_public_helptext":
        return executeMessage(#open_roomkiosk)
    end case
  else
    if tEvent = #mouseUp then
      case tSprID of
        "close":
          me.hideNavigator(#hide)
        "nav_go_public_button":
          if not voidp(pLastClickedUnitId) then
            me.getComponent().updateState("enterUnit", pLastClickedUnitId)
          end if
      end case
    end if
  end if
end

on eventProcNavigatorPrivate me, tEvent, tSprID, tParm
  if tEvent = #mouseDown then
    case tSprID of
      "nav_public_tab":
        if not voidp(pLastClickedUnitId) then
          me.ChangeWindowView("nav_public_info.window")
          me.CreatepublicRoomInfo(pLastClickedUnitId)
        else
          me.ChangeWindowView("nav_public_start.window")
        end if
      "nav_private_rooms_list":
        if not ilk(tParm, #point) or pFlatList.count = 0 then
          return 0
        end if
        tClickLine = integer(tParm.locV / pListItemHeight) + 1
        if tClickLine > pFlatList.count then
          tClickLine = pFlatList.count
        end if
        if tClickLine > 0 then
          if not voidp(pFlatList[tClickLine]) then
            tRoomId = pFlatList[tClickLine][#id]
            if not voidp(tRoomId) then
              tGoLinkArea = pPrivateListImg.width - pFlatGoTextImg.width
              if tParm.locH > tGoLinkArea then
                if not getObject(#session).get("user_rights").getOne("can_enter_others_rooms") then
                  if pFlatList[tRoomId][#owner] <> getObject(#session).get(#userName) then
                    executeMessage(#alert, [#msg: "nav_norights"])
                    return 1
                  end if
                end if
                pFlatInfoAction = #enterflat
                me.getComponent().getFlatInfo(tRoomId)
                me.renderLoadingText("nav_private_rooms_list")
              else
                pFlatInfoAction = #flatInfo
                tWndObj = getWindow(pWindowTitle)
                tScroll = tWndObj.getElement("scroll_private").getScrollOffset()
                me.ChangeWindowView("nav_private_info.window")
                me.CreatePrivateRoomInfo(pFlatList[tRoomId])
                tWndObj.getElement("scroll_private").setScrollOffset(tScroll)
                pFlatInfoAction = 0
              end if
            end if
          end if
        end if
      "nav_private_search_field":
        me.searchPrivateRooms(1)
      "nav_modify_nameshow_yes_radio":
        pCurrentFlatData[#showownername] = "1"
        me.updateRadioButton("nav_modify_nameshow_yes_radio", ["nav_modify_nameshow_no_radio"])
      "nav_modify_nameshow_no_radio":
        pCurrentFlatData[#showownername] = "0"
        me.updateRadioButton("nav_modify_nameshow_no_radio", ["nav_modify_nameshow_yes_radio"])
      "nav_modify_door_open_radio":
        pCurrentFlatData[#door] = "open"
        me.updateRadioButton("nav_modify_door_open_radio", ["nav_modify_door_locked_radio", "nav_modify_door_pw_radio"])
      "nav_modify_door_locked_radio":
        pCurrentFlatData[#door] = "closed"
        me.updateRadioButton("nav_modify_door_locked_radio", ["nav_modify_door_open_radio", "nav_modify_door_pw_radio"])
      "nav_modify_door_pw_radio":
        pCurrentFlatData[#door] = "password"
        me.updateRadioButton("nav_modify_door_pw_radio", ["nav_modify_door_open_radio", "nav_modify_door_locked_radio"])
      "nav_modify_furnituremove_check":
        me.updateCheckButton("nav_modify_furnituremove_check", #ableothersmovefurniture, 1)
      "create_room", "nav_public_helptext":
        return executeMessage(#open_roomkiosk)
    end case
  else
    if tEvent = #mouseUp then
      case tSprID of
        "close":
          me.hideNavigator(#hide)
        "nav_go_private_button":
          if not getObject(#session).get("user_rights").getOne("can_enter_others_rooms") then
            if pCurrentFlatData[#owner] <> getObject(#session).get(#userName) then
              executeMessage(#alert, [#msg: "nav_norights"])
              return 1
            end if
          end if
          pFlatInfoAction = #enterflat
          me.getComponent().getFlatInfo(pCurrentFlatData[#id])
          me.renderLoadingText("nav_private_rooms_list")
        "nav_private_dropdown":
          if tParm.ilk <> #string or tParm = pPrivateDropMode then
            return 1
          end if
          pPrivateDropMode = tParm
          if pPrivateDropMode = "nav_rooms_search" then
            return me.searchPrivateRooms(1)
          else
            me.searchPrivateRooms(0)
          end if
          case pPrivateDropMode of
            "nav_rooms_own":
              me.getComponent().getOwnFlats()
            "nav_rooms_popular":
              return me.getComponent().searchBusyFlats(0, pFlatsPerView)
            "nav_rooms_search":
              me.makePrivateRoomSearch()
            "nav_rooms_favourite":
              me.getComponent().getFavouriteFlats()
          end case
          me.renderLoadingText("nav_private_rooms_list")
        "nav_private_button_search":
          me.makePrivateRoomSearch()
        "nav_modify_button":
          if not voidp(pCurrentFlatData[#id]) then
            pFlatInfoAction = #modifyInfo
            me.getComponent().getFlatInfo(pCurrentFlatData[#id])
            me.renderLoadingText("nav_private_rooms_list")
          end if
        "nav_modify_ok":
          if voidp(pCurrentFlatData) then
            return 0
          end if
          tWndObj = getWindow(pWindowTitle)
          if pCurrentFlatData[#door] = "password" then
            if not me.checkPasswords() then
              return 0
            end if
          end if
          pCurrentFlatData[#name] = tWndObj.getElement("nav_modify_roomnamefield").getText().line[1]
          pCurrentFlatData[#description] = tWndObj.getElement("nav_modify_roomdescription_field").getText()
          pCurrentFlatData[#password] = me.getPassword("nav_modify_door_pw")
          me.getComponent().sendupdateFlatInfo(pCurrentFlatData)
          me.getComponent().getOwnFlats()
          me.getComponent().getFlatInfo(pCurrentFlatData[#id])
          pFlatInfoAction = #flatInfo
          me.roomlistupdate()
          me.ChangeWindowView("nav_private_info.window")
          me.renderLoadingText("nav_private_rooms_list")
        "nav_modify_cancel":
          me.roomlistupdate()
          me.ChangeWindowView("nav_private_info.window")
          me.renderLoadingText("nav_private_rooms_list")
        "nav_modify_deleteroom":
          me.ChangeWindowView("nav_private_modify_delete1.window")
        "nav_addtofavourites_button":
          if voidp(pCurrentFlatData[#id]) then
            return 0
          end if
          me.getComponent().addToFavouriteFlats(pCurrentFlatData[#id])
        "nav_removefavourites_button":
          if voidp(pCurrentFlatData[#id]) then
            return 0
          end if
          me.getComponent().removeFavouriteFlats(pCurrentFlatData[#id])
          me.getComponent().getFavouriteFlats()
        "nav_ringbell_cancel_button", "nav_flatpassword_cancel_button", "nav_trypw_cancel_button":
          if tSprID <> "nav_flatpassword_cancel_button" then
            me.getComponent().updateState("enterEntry")
          end if
          me.ChangeWindowView("nav_private_start.window")
          if not me.getComponent().searchBusyFlats(0, pFlatsPerView) then
            me.renderLoadingText("nav_private_rooms_list")
          end if
        "nav_flatpassword_ok_button":
          tTemp = me.getPassword("nav_flatpassword_field")
          if length(tTemp) = 0 then
            return 
          end if
          pCurrentFlatData[#password] = tTemp
          me.ChangeWindowView("nav_private_try_pw.window")
          getWindow(pWindowTitle).getElement("nav_roomname_text").setText(pCurrentFlatData[#name])
          me.getComponent().updateState("enterFlat", pCurrentFlatData[#id])
        "nav_tryagain_ok_button":
          pFlatInfoAction = #enterflat
          me.getComponent().getFlatInfo(pCurrentFlatData[#id])
        "nav_noanswer_ok_button":
          me.getComponent().updateState("enterEntry")
          me.ChangeWindowView("nav_private_info.window")
          if not me.getComponent().searchBusyFlats(0, pFlatsPerView) then
            me.renderLoadingText("nav_private_rooms_list")
          end if
        otherwise:
          if tSprID contains "nav_delete_room_ok_" then
            if not voidp(pCurrentFlatData[#id]) then
              case tSprID.char[length(tSprID)] of
                1:
                  me.ChangeWindowView("nav_private_modify_delete2.window")
                2:
                  me.ChangeWindowView("nav_private_modify_delete3.window")
                3:
                  me.getComponent().deleteFlat(pCurrentFlatData[#id])
                  me.ChangeWindowView("nav_private_start.window")
                  pPrivateDropMode = "nav_rooms_own"
                  me.getComponent().getOwnFlats()
                  me.renderLoadingText("nav_private_rooms_list")
              end case
            end if
          else
            if tSprID contains "nav_delete_room_cancel_" then
              if voidp(pCurrentFlatData[#id]) then
                return 0
              end if
              me.getComponent().getFlatInfo(pCurrentFlatData[#id])
              pFlatInfoAction = #modifyInfo
            end if
          end if
      end case
    else
      if tEvent = #keyDown then
        case tSprID of
          "nav_private_search_field":
            if the key = RETURN then
              me.makePrivateRoomSearch()
            end if
          "nav_modify_door_pw", "nav_modify_door_pw2", "nav_flatpassword_field":
            if voidp(pFlatPasswords[tSprID]) then
              pFlatPasswords[tSprID] = []
            end if
            case the keyCode of
              48:
                return 0
              36, 76:
                if tSprID = "nav_flatpassword_field" then
                  return me.eventProcNavigatorPrivate(#mouseUp, "nav_flatpassword_ok_button", VOID)
                else
                  return 1
                end if
              51:
                if pFlatPasswords[tSprID].count > 0 then
                  pFlatPasswords[tSprID].deleteAt(pFlatPasswords[tSprID].count)
                end if
              117:
                pFlatPasswords[tSprID] = []
              otherwise:
                tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                tTheKey = the key
                tASCII = charToNum(tTheKey)
                if tASCII > 31 and tASCII < 128 then
                  if tValidKeys contains tTheKey or tValidKeys = EMPTY then
                    if pFlatPasswords[tSprID].count < 32 then
                      pFlatPasswords[tSprID].append(tTheKey)
                    end if
                  end if
                end if
            end case
            tStr = EMPTY
            repeat with i = 1 to pFlatPasswords[tSprID].count
              put "*" after tStr
            end repeat
            getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
            set the selStart to pFlatPasswords[tSprID].count
            set the selEnd to pFlatPasswords[tSprID].count
            return 1
        end case
      end if
    end if
  end if
end

on eventProcDisconnect me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    if tElemID = "error_close" then
      removeWindow(#error)
      resetClient()
    end if
  end if
end
