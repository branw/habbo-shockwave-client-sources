property pName, pClass, pCustom, pIDPrefix, pBuffer, pSprite, pMatteSpr, pMember, pShadowSpr, pShadowFix, pDefShadowMem, pPartList, pPartIndex, pFlipList, pUpdateRect, pDirection, pLocX, pLocY, pLocH, pLocFix, pXFactor, pYFactor, pHFactor, pScreenLoc, pStartLScreen, pDestLScreen, pRestingHeight, pAnimCounter, pMoveStart, pMoveTime, pEyesClosed, pSync, pChanges, pAlphaColor, pCanvasSize, pMainAction, pWaving, pMoving, pTalking, pSniffing, pGeometry, pInfoStruct, pCorrectLocZ, pPartClass, pOffsetList, pOffsetListSmall, pMemberNamePrefix

on construct me
  pName = EMPTY
  pIDPrefix = EMPTY
  pPartList = []
  pPartIndex = [:]
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pLocFix = point(0, -8)
  pUpdateRect = rect(0, 0, 0, 0)
  pScreenLoc = [0, 0, 0]
  pStartLScreen = [0, 0, 0]
  pDestLScreen = [0, 0, 0]
  pRestingHeight = 0.0
  pAnimCounter = 0
  pMoveStart = 0
  pMoveTime = 500
  pEyesClosed = 0
  pSync = 1
  pChanges = 1
  pMainAction = "std"
  pWaving = 0
  pMoving = 0
  pSniffing = 0
  pTalking = 0
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pDefShadowMem = member(0)
  pInfoStruct = [:]
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  pHFactor = pGeometry.pHFactor
  if pXFactor = 32 then
    pMemberNamePrefix = "s_p_"
    pCorrectLocZ = 0
  else
    pMemberNamePrefix = "p_"
    pCorrectLocZ = 1
  end if
  pPartClass = value(getThread(#room).getComponent().getClassContainer().get("petpart"))
  pOffsetList = me.getOffsetList()
  pOffsetListSmall = me.getOffsetList(#small)
  return 1
end

on deconstruct me
  pGeometry = VOID
  pPartList = []
  pInfoStruct = [:]
  if pSprite.ilk = #sprite then
    releaseSprite(pSprite.spriteNum)
  end if
  if pMatteSpr.ilk = #sprite then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if pShadowSpr.ilk = #sprite then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if memberExists(me.getCanvasName()) then
    removeMember(me.getCanvasName())
  end if
  pShadowSpr = VOID
  pMatteSpr = VOID
  pSprite = VOID
  return 1
end

on define me, tdata
  me.setup(tdata)
  if not memberExists(me.getCanvasName()) then
    createMember(me.getCanvasName(), #bitmap)
  end if
  pMember = member(getmemnum(me.getCanvasName()))
  pMember.image = image(pCanvasSize[1], pCanvasSize[2], pCanvasSize[3])
  pMember.regPoint = point(0, pMember.image.height + pCanvasSize[4])
  pBuffer = pMember.image.duplicate()
  pSprite = sprite(reserveSprite(me.getID()))
  pSprite.castNum = pMember.number
  pSprite.width = pMember.width
  pSprite.height = pMember.height
  pSprite.ink = 36
  pMatteSpr = sprite(reserveSprite(me.getID()))
  pMatteSpr.castNum = pMember.number
  pMatteSpr.ink = 8
  pMatteSpr.blend = 0
  pShadowSpr = sprite(reserveSprite(me.getID()))
  pShadowSpr.blend = 16
  pShadowSpr.ink = 8
  pShadowFix = 0
  pDefShadowMem = member(getmemnum(pMemberNamePrefix & "std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  setEventBroker(pShadowSpr.spriteNum, me.getID())
  pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  tDelim = the itemDelimiter
  the itemDelimiter = numToChar(4)
  pInfoStruct[#name] = item 2 of me.getID()
  the itemDelimiter = tDelim
  pInfoStruct[#name] = pName
  pInfoStruct[#class] = pClass
  pInfoStruct[#Custom] = pCustom
  pInfoStruct[#image] = me.getPicture()
  return 1
end

on setup me, tdata
  pName = tdata[#name]
  pClass = tdata[#class]
  pDirection = tdata[#direction][1]
  pLocX = tdata[#x]
  pLocY = tdata[#y]
  pLocH = tdata[#h]
  pCustom = getText("pet_race_" & tdata[#figure].word[1] & "_" & tdata[#figure].word[2], EMPTY)
  if pName contains numToChar(4) then
    pIDPrefix = pName.char[1..offset(numToChar(4), pName)]
    pName = pName.char[offset(numToChar(4), pName) + 1..length(pName)]
  end if
  pCanvasSize = [60, 62, 32, -18]
  if not me.setPartLists(tdata[#figure]) then
    return error(me, "Couldn't create part lists!", #setup)
  end if
  me.resetValues(pLocX, pLocY, pLocH, pDirection, pDirection)
  me.refresh(pLocX, pLocY, pLocH)
  pSync = 0
end

on update me
  pSync = not pSync
  if pSync then
    me.prepare()
  else
    me.render()
  end if
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody
  pWaving = 0
  pMoving = 0
  pTalking = 0
  pSniffing = 0
  call(#reset, pPartList)
  if pCorrectLocZ then
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH + pRestingHeight)
  else
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0.0
  call(#defineDir, pPartList, tDirBody)
  if tDirBody <> pFlipList[tDirBody + 1] then
    if tDirBody <> tDirHead then
      case tDirHead of
        4:
          tDirHead = 2
        5:
          tDirHead = 1
        6:
          tDirHead = 4
        7:
          tDirHead = 5
      end case
    end if
  end if
  pPartList[pPartIndex["hd"]].defineDir(tDirHead)
  pDirection = tDirBody
end

on refresh me, tX, tY, tH, tDirHead, tDirBody
  me.arrangeParts()
  pChanges = 1
end

on select me
  if the doubleClick then
    if connectionExists(getVariable("connection.info.id", #info)) then
      getConnection(getVariable("connection.info.id", #info)).send("GETPETSTAT", [#string: pIDPrefix & pName])
    end if
  end if
  return 1
end

on getClass me
  return "pet"
end

on getName me
  return pName
end

on setPartModel me, tPart, tmodel
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  pPartList[pPartIndex[tPart]].setModel(tmodel)
end

on setPartColor me, tPart, tColor
  if voidp(pPartIndex[tPart]) then
    return rgb(255, 199, 199)
  end if
  pPartList[pPartIndex[tPart]].setColor(tColor)
end

on getCustom me
  return pCustom
end

on getLocation me
  return [pLocX, pLocY, pLocH]
end

on getScrLocation me
  return pScreenLoc
end

on getTileCenter me
  return point(pScreenLoc[1] + pXFactor / 2, pScreenLoc[2])
end

on getPartLocation me, tPart
  return me.getTileCenter()
end

on getDirection me
  return pDirection
end

on getPartMember me, tPart
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  return pPartList[pPartIndex[tPart]].getCurrentMember()
end

on getPartColor me, tPart
  if voidp(pPartIndex[tPart]) then
    return rgb(255, 199, 199)
  end if
  return pPartList[pPartIndex[tPart]].getColor()
end

on getPicture me, tImg
  if voidp(tImg) then
    tCanvas = image(pCanvasSize[1], pCanvasSize[2], pCanvasSize[3])
  else
    tCanvas = tImg
  end if
  if voidp(pInfoStruct[#image]) then
    tPartDefinition = ["tl", "bd", "hd"]
    tTempPartList = []
    repeat with tPartSymbol in tPartDefinition
      if not voidp(pPartIndex[tPartSymbol]) then
        tTempPartList.append(pPartList[pPartIndex[tPartSymbol]])
      end if
    end repeat
    call(#copyPicture, tTempPartList, tCanvas)
  else
    tCanvas.copyPixels(pInfoStruct[#image], tCanvas.rect, tCanvas.rect)
  end if
  return me.flipImage(tCanvas)
end

on getInfo me
  return pInfoStruct
end

on getSprites me
  return [pSprite, pShadowSpr, pMatteSpr]
end

on closeEyes me
  pPartList[pPartIndex["hd"]].defineAct("eyb")
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me
  pPartList[pPartIndex["hd"]].defineAct("std")
  pEyesClosed = 0
  pChanges = 1
end

on show me
  pSprite.visible = 1
  pMatteSpr.visible = 1
  pShadowSpr.visible = 1
end

on hide me
  pSprite.visible = 0
  pMatteSpr.visible = 0
  pShadowSpr.visible = 0
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.image.draw(pMember.image.rect, [#shapeType: #rect, #color: tRGB])
end

on prepare me
  pAnimCounter = (pAnimCounter + 1) mod 4
  if pEyesClosed then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if pTalking and random(3) > 1 then
    pPartList[pPartIndex["hd"]].defineAct("spk")
    pChanges = 1
  end if
  if pWaving then
    pPartList[pPartIndex["tl"]].defineAct("wav")
    pChanges = 1
  end if
  if pSniffing then
    pPartList[pPartIndex["hd"]].defineAct("snf")
    pChanges = 1
  end if
  if pMainAction = "scr" then
    pPartList[pPartIndex["bd"]].defineAct("scr")
    pChanges = 1
  end if
  if pMainAction = "bnd" then
    pPartList[pPartIndex["bd"]].defineAct("bnd")
    pChanges = 1
  end if
  if pMainAction = "jmp" then
    pPartList[pPartIndex["bd"]].defineAct("jmp")
    pChanges = 1
  end if
  if pMainAction = "pla" then
    pPartList[pPartIndex["bd"]].defineAct("pla")
    pChanges = 1
  end if
  if pMoving then
    tFactor = float(the milliSeconds - pMoveStart) / pMoveTime
    if tFactor > 1.0 then
      tFactor = 1.0
    end if
    pScreenLoc = (pDestLScreen - pStartLScreen) * tFactor + pStartLScreen
    pChanges = 1
  end if
end

on render me
  if not pChanges then
    return 
  end if
  pChanges = 0
  if pShadowSpr.member <> pDefShadowMem then
    pShadowSpr.member = pDefShadowMem
  end if
  if pBuffer.width <> pCanvasSize[1] or pBuffer.height <> pCanvasSize[2] then
    pMember.image = image(pCanvasSize[1], pCanvasSize[2], pCanvasSize[3])
    pMember.regPoint = point(0, pCanvasSize[2] + pCanvasSize[4])
    pSprite.width = pCanvasSize[1]
    pSprite.height = pCanvasSize[2]
    pMatteSpr.width = pCanvasSize[1]
    pMatteSpr.height = pCanvasSize[2]
    pBuffer = image(pCanvasSize[1], pCanvasSize[2], pCanvasSize[3])
  end if
  tFlip = 0
  tFlip = tFlip or pFlipList[pDirection + 1] <> pDirection
  tFlip = tFlip or pDirection = 3 and pPartList[pPartIndex["hd"]].pDirection = 4
  tFlip = tFlip or pDirection = 7 and pPartList[pPartIndex["hd"]].pDirection = 6
  if tFlip then
    pMember.regPoint = point(pMember.image.width, pMember.regPoint[2])
    pShadowFix = pXFactor
    if not pSprite.flipH then
      pSprite.flipH = 1
      pMatteSpr.flipH = 1
      pShadowSpr.flipH = 1
    end if
  else
    pMember.regPoint = point(0, pMember.regPoint[2])
    pShadowFix = 0
    if pSprite.flipH then
      pSprite.flipH = 0
      pMatteSpr.flipH = 0
      pShadowSpr.flipH = 0
    end if
  end if
  if pCorrectLocZ then
    tOffZ = (pLocH + pRestingHeight) * 1000 + 2
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc[1]
  pSprite.locV = pScreenLoc[2]
  pSprite.locZ = pScreenLoc[3] + tOffZ
  pMatteSpr.loc = pSprite.loc
  pMatteSpr.locZ = pSprite.locZ + 1
  pShadowSpr.loc = pSprite.loc + [pShadowFix, 0]
  pShadowSpr.locZ = pSprite.locZ - 3
  pUpdateRect = rect(0, 0, 0, 0)
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#update, pPartList)
  pMember.image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
end

on reDraw me
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on setPartLists me, tFigure
  tAction = pMainAction
  pPartList = []
  tPartDefinition = ["tl", "bd", "hd"]
  if tFigure.word.count < 3 then
    tFigure = "0 4 AA98EF"
  end if
  tRaceNum = tFigure.word[1]
  tPalette = tFigure.word[2]
  if tPalette.length < 3 then
    tPalette = "0" & tPalette
  end if
  if tPalette.length < 3 then
    tPalette = "0" & tPalette
  end if
  tPalette = "Pets Palette" && tPalette
  tColor = rgb(tFigure.word[3])
  repeat with i = 1 to tPartDefinition.count
    tPartSymbol = tPartDefinition[i]
    tPartObj = createObject(#temp, pPartClass)
    if tPartSymbol = "bd" then
      tmodel = "000"
    else
      tmodel = "00" & tRaceNum
    end if
    tPartObj.define(tPartSymbol, tmodel, tPalette, tColor, pDirection, tAction, me)
    pPartList.add(tPartObj)
  end repeat
  pPartIndex = [:]
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
  return 1
end

on arrangeParts me
  tTailInd = pPartIndex["tl"]
  tHeadInd = pPartIndex["hd"]
  tBodyInd = pPartIndex["bd"]
  tTail = pPartList[tTailInd]
  tHead = pPartList[tHeadInd]
  tBody = pPartList[tBodyInd]
  tHeadDir = tHead.getDirection()
  if tHeadDir = 7 then
    pPartList = [tHead, tBody, tTail]
    pPartIndex = ["hd": 1, "bd": 2, "tl": 3]
  else
    if pDirection = 6 or pDirection = 7 or pDirection = 0 then
      pPartList = [tBody, tHead, tTail]
      pPartIndex = ["bd": 1, "hd": 2, "tl": 3]
    else
      pPartList = [tTail, tBody, tHead]
      pPartIndex = ["tl": 1, "bd": 2, "hd": 3]
    end if
  end if
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end

on getOffsetList me, tSize
  if voidp(tSize) then
    tSize = #large
  end if
  if tSize = #large then
    tList = [:]
    tList["hd_std"] = [[36, -21], [38, -18], [37, -18], [32, -15], [32, -20]]
    tList["hd_sit"] = [[36, -21], [38, -18], [37, -18], [32, -14], [32, -17]]
    tList["hd_lay"] = [[36, -13], [38, -11], [37, -12], [32, -8], [32, -11]]
    tList["hd_slp"] = [[36, -11], [38, -9], [37, -10], [32, -6], [32, -9]]
    tList["hd_wlk"] = tList["hd_std"]
    tList["hd_pla"] = tList["hd_sit"]
    tList["hd_spc"] = tList["hd_std"]
    tList["hd_rdy"] = [[35, -17], [38, -11], [37, -7], [32, -11], [32, -17]]
    tList["hd_beg"] = [[24, -24], [25, -27], [26, -28], [32, -26], [32, -24]]
    tList["hd_ded"] = [[40, -3], [38, 1], [37, 5], [32, 8], [32, -7]]
    tList["hd_jmp_0"] = tList["hd_rdy"]
    tList["hd_jmp_1"] = tList["hd_sit"]
    tList["hd_jmp_2"] = [[36, -33], [38, -30], [37, -30], [32, -27], [32, -32]]
    tList["hd_jmp_3"] = [[36, -25], [38, -22], [37, -22], [32, -19], [32, -24]]
    tList["hd_scr_0"] = tList["hd_sit"]
    tList["hd_scr_1"] = [[36, -19], [39, -16], [37, -16], [32, -12], [32, -15]]
    tList["hd_scr_2"] = tList["hd_sit"]
    tList["hd_scr_3"] = tList["hd_scr_1"]
    tList["hd_bnd_0"] = tList["hd_rdy"]
    tList["hd_bnd_1"] = [[35, -22], [36, -19], [36, -19], [32, -16], [32, -21]]
    tList["hd_bnd_2"] = tList["hd_bnd_1"]
    tList["hd_bnd_3"] = tList["hd_bnd_1"]
    tList["tl_std"] = [[21, -10], [20, -12], [23, -19], [32, -23], [32, -10]]
    tList["tl_sit"] = [[21, -2], [22, -1], [23, -6], [32, -19], [32, -3]]
    tList["tl_lay"] = [[21, 1], [18, -1], [23, -10], [32, -15], [32, 0]]
    tList["tl_slp"] = tList["tl_lay"]
    tList["tl_wlk"] = tList["tl_std"]
    tList["tl_pla"] = tList["tl_sit"]
    tList["tl_spc"] = tList["tl_std"]
    tList["tl_rdy"] = [[21, -10], [20, -12], [23, -19], [32, -23], [32, -11]]
    tList["tl_beg"] = [[21, -2], [22, -1], [23, -5], [32, -14], [32, 1]]
    tList["tl_ded"] = [[23, 2], [18, 1], [23, -19], [32, -20], [32, -10]]
    tList["tl_jmp_0"] = tList["tl_rdy"]
    tList["tl_jmp_1"] = tList["tl_sit"]
    tList["tl_jmp_2"] = [[21, -16], [20, -18], [23, -25], [32, -28], [32, -16]]
    tList["tl_jmp_3"] = [[21, -20], [20, -22], [23, -29], [32, -33], [32, -20]]
    tList["tl_scr_0"] = tList["tl_sit"]
    tList["tl_scr_1"] = [[21, -1], [22, 0], [23, -5], [32, -18], [32, -2]]
    tList["tl_scr_2"] = tList["tl_sit"]
    tList["tl_scr_3"] = tList["tl_scr_1"]
    tList["tl_bnd_0"] = tList["tl_rdy"]
    tList["tl_bnd_1"] = [[23, -13], [24, -14], [25, -21], [32, -27], [32, -12]]
    tList["tl_bnd_2"] = tList["tl_bnd_1"]
    tList["tl_bnd_3"] = tList["tl_bnd_1"]
  else
    tList = [:]
    tList["hd_std"] = [[21, -14], [21, -12], [21, -12], [19, -11], [19, -13]]
    tList["hd_sit"] = [[21, -14], [21, -12], [21, -12], [19, -10], [19, -11]]
    tList["hd_lay"] = [[21, -10], [21, -9], [21, -9], [19, -7], [19, -9]]
    tList["hd_slp"] = [[21, -9], [22, -8], [21, -8], [19, -6], [19, -8]]
    tList["hd_wlk"] = tList["hd_std"]
    tList["hd_pla"] = tList["hd_sit"]
    tList["hd_spc"] = tList["hd_std"]
    tList["hd_rdy"] = [[21, -12], [22, -9], [21, -7], [19, -9], [19, -12]]
    tList["hd_beg"] = [[15, -15], [15, -17], [16, -17], [19, -14], [19, -15]]
    tList["hd_ded"] = [[22, -5], [22, 4], [21, 6], [19, 7], [19, -7]]
    tList["hd_jmp_0"] = tList["hd_rdy"]
    tList["hd_jmp_1"] = tList["hd_sit"]
    tList["hd_jmp_2"] = [[21, -20], [23, -19], [21, -18], [19, -17], [19, -19]]
    tList["hd_jmp_3"] = [[21, -16], [22, -14], [21, -14], [19, -13], [19, -15]]
    tList["hd_scr_0"] = tList["hd_sit"]
    tList["hd_scr_1"] = [[20, -13], [22, -11], [21, -11], [19, -9], [19, -11]]
    tList["hd_scr_2"] = tList["hd_sit"]
    tList["hd_scr_3"] = tList["hd_scr_1"]
    tList["hd_bnd_0"] = tList["hd_rdy"]
    tList["hd_bnd_1"] = [[21, -15], [21, -13], [21, -13], [19, -11], [19, -14]]
    tList["hd_bnd_2"] = tList["hd_bnd_1"]
    tList["hd_bnd_3"] = tList["hd_bnd_1"]
    tList["tl_std"] = [[14, -8], [13, -9], [15, -13], [19, -14], [19, -8]]
    tList["tl_sit"] = [[12, -1], [13, -1], [16, -5], [19, -13], [19, -4]]
    tList["tl_lay"] = [[12, 1], [12, -1], [15, -8], [19, -11], [19, 0]]
    tList["tl_slp"] = tList["tl_lay"]
    tList["tl_wlk"] = tList["tl_std"]
    tList["tl_pla"] = tList["tl_sit"]
    tList["tl_spc"] = tList["tl_std"]
    tList["tl_rdy"] = [[14, -8], [13, -9], [15, -13], [19, -15], [19, -9]]
    tList["tl_beg"] = [[14, -1], [14, -1], [15, -5], [19, -10], [19, 1]]
    tList["tl_ded"] = [[15, 1], [12, 1], [15, -13], [19, -13], [19, -8]]
    tList["tl_jmp_0"] = tList["tl_rdy"]
    tList["tl_jmp_1"] = tList["tl_sit"]
    tList["tl_jmp_2"] = [[14, -11], [13, -12], [15, -16], [19, -17], [19, -11]]
    tList["tl_jmp_3"] = [[14, -13], [13, -14], [15, -17], [19, -20], [19, -13]]
    tList["tl_scr_0"] = tList["tl_sit"]
    tList["tl_scr_1"] = [[14, -1], [14, 0], [15, -5], [19, -12], [19, -1]]
    tList["tl_scr_2"] = tList["tl_sit"]
    tList["tl_scr_3"] = tList["tl_scr_1"]
    tList["tl_bnd_0"] = tList["tl_rdy"]
    tList["tl_bnd_1"] = [[15, -10], [15, -10], [16, -14], [19, -17], [19, -9]]
    tList["tl_bnd_2"] = tList["tl_bnd_1"]
    tList["tl_bnd_3"] = tList["tl_bnd_1"]
  end if
  return tList
end

on getCanvasName me
  return pClass && pIDPrefix && pName & me.getID() && "Canvas"
end

on action_mv me, tProps
  pMainAction = "wlk"
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = getLocalFloat(tloc.item[3])
  the itemDelimiter = tDelim
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pMoveStart = the milliSeconds
  pPartList[pPartIndex["bd"]].defineAct("wlk")
end

on action_sld me, tProps
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = getLocalFloat(tloc.item[3])
  the itemDelimiter = tDelim
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pMoveStart = the milliSeconds
end

on action_sit me, tProps
  pMainAction = "sit"
  pPartList[pPartIndex["bd"]].defineAct("sit")
  if pCorrectLocZ then
    pRestingHeight = getLocalFloat(tProps.word[2]) - pLocH
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  else
    pRestingHeight = getLocalFloat(tProps.word[2])
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pRestingHeight)
  end if
end

on action_snf me
  pSniffing = 1
  pPartList[pPartIndex["hd"]].defineAct("snf")
end

on action_scr me
  me.pMainAction = "scr"
  pPartList[pPartIndex["bd"]].defineAct("scr")
end

on action_bnd me
  me.pMainAction = "bnd"
  pPartList[pPartIndex["bd"]].defineAct("bnd")
end

on action_lay me, tProps
  pMainAction = "lay"
  pPartList[pPartIndex["bd"]].defineAct("lay")
  if pCorrectLocZ then
    pRestingHeight = getLocalFloat(tProps.word[2]) - pLocH
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  else
    pRestingHeight = getLocalFloat(tProps.word[2])
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pRestingHeight)
  end if
end

on action_slp me, tProps
  me.action_lay(tProps)
  me.closeEyes()
  pMainAction = "slp"
end

on action_jmp me, tProps
  pMainAction = "jmp"
  pPartList[pPartIndex["bd"]].defineAct("jmp")
end

on action_ded me, tProps
  pMainAction = "ded"
  pPartList[pPartIndex["hd"]].defineAct("ded")
  pPartList[pPartIndex["bd"]].defineAct("ded")
  pPartList[pPartIndex["tl"]].defineAct("ded")
end

on action_eat me, tProps
  pPartList[pPartIndex["hd"]].defineAct("eat")
end

on action_beg me, tProps
  pMainAction = "beg"
  pPartList[pPartIndex["bd"]].defineAct("beg")
end

on action_pla me, tProps
  pMainAction = "pla"
  pPartList[pPartIndex["bd"]].defineAct("pla")
end

on action_rdy me, tProps
  pMainAction = "rdy"
  pPartList[pPartIndex["bd"]].defineAct("rdy")
end

on action_talk me, tProps
  pTalking = 1
end

on action_wav me, tProps
  pWaving = 1
  pPartList[pPartIndex["tl"]].defineAct("wav")
end

on action_gst me, tProps
  tGesture = tProps.word[2]
  pPartList[pPartIndex["hd"]].defineAct(tGesture)
  case tGesture of
    "sml", "agr", "sad", "puz":
      pPartList[pPartIndex["tl"]].defineAct(tGesture)
  end case
end
