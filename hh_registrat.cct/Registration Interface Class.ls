property pTempPassword, pOpenWindow, pWindowTitle, pMode, pOldFigure, pOldSex, pPartChangeButtons, pBodyPartObjects, pPeopleSize, pBuffer, pFlipList, pNameChecked, pLastNameCheck, pPropsToServer, pErrorMsg

on construct me
  pTempPassword = [:]
  pPropsToServer = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = EMPTY
  pWindowTitle = getText("win_figurecreator", "Your own Habbo")
  if not variableExists("permitted.name.chars") then
    setVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
  end if
  return 1
end

on deconstruct me
  pBodyPartObjects = VOID
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  if objectExists(#temp_humanobj_figurecreator) then
    removeObject(#temp_humanobj_figurecreator)
  end if
  if objectExists("CountryMngr") then
    removeObject("CountryMngr")
  end if
  return 1
end

on showHideFigureCreator me, tNewOrUpdate
  if windowExists(pWindowTitle) then
    me.closeFigureCreator()
  else
    me.openFigureCreator(tNewOrUpdate)
  end if
end

on openFigureCreator me, tNewOrUpdate
  pPropsToServer = [:]
  me.ChangeWindowView("figure_namepage.window")
  if not voidp(tNewOrUpdate) then
    me.defineModes(tNewOrUpdate)
  end if
end

on closeFigureCreator me
  pPropsToServer = [:]
  pBodyPartObjects = VOID
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return 1
end

on showLoadingWindow me
  me.ChangeWindowView("figure_loading.window")
  me.blinkLoading()
  return 1
end

on blinkLoading me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("reg_loading")
  if tElem = 0 then
    return 0
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  me.delay(500, #blinkLoading)
  return 1
end

on defineModes me, tMode
  pTempPassword = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = EMPTY
  pMode = tMode
  if tMode = "update" then
    tUserName = getObject(#session).get(#userName)
    pNameChecked = 1
    me.NewFigureInformation()
    me.getMyInformation()
    me.createTemplateHuman()
    me.setMyDataToFields()
  else
    pNameChecked = 0
    if voidp(pPropsToServer["name"]) then
      me.NewFigureInformation()
      me.createDefaultFigure()
      me.createTemplateHuman()
      me.setMyDataToFields()
    else
      me.setMyDataToFields()
    end if
  end if
  me.updateSexRadioButtons()
  me.updateFigurePreview()
  me.updateAllPrewIcons()
end

on NewFigureInformation me
  pPropsToServer["name"] = EMPTY
  pPropsToServer["figure"] = [:]
  pPropsToServer["sex"] = "M"
  pPropsToServer["customData"] = EMPTY
  pPropsToServer["email"] = EMPTY
  pPropsToServer["birthday"] = EMPTY
  pPropsToServer["country"] = EMPTY
  pPropsToServer["phoneNumber"] = EMPTY
  pPropsToServer["directMail"] = "0"
  pPropsToServer["has_read_agreement"] = "0"
end

on ChangeWindowView me, tWindowName
  if not windowExists(pWindowTitle) then
    createWindow(pWindowTitle, "habbo_basic.window", 381, 73)
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcFigurecreator, me.getID(), #mouseDown)
    tWndObj.registerProcedure(#eventProcFigurecreator, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcFigurecreator, me.getID(), #keyDown)
  else
    tWndObj = getWindow(pWindowTitle)
    tWndObj.unmerge()
  end if
  tWndObj.merge(tWindowName)
  pOpenWindow = tWindowName
end

on getMyInformation me
  pPropsToServer = [:]
  tTempProps = ["name", "password", "figure", "sex", "customData", "email", "birthday", "country", "region", "phoneNumber", "directMail", "has_read_agreement"]
  repeat with tProp in tTempProps
    if getObject(#session).exists("user_" & tProp) then
      pPropsToServer[tProp] = getObject(#session).get("user_" & tProp)
      next repeat
    end if
    pPropsToServer[tProp] = EMPTY
  end repeat
  pPropsToServer["figure"].deleteProp("li")
  pPropsToServer["figure"].deleteProp("ri")
  pOldFigure = pPropsToServer["figure"].duplicate()
  if pPropsToServer["sex"].char[1] = "f" or pPropsToServer["sex"].char[1] = "F" then
    pPropsToServer["sex"] = "F"
  else
    pPropsToServer["sex"] = "M"
  end if
  pOldSex = pPropsToServer["sex"]
end

on setMyDataToFields me
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  case pOpenWindow of
    "figure_namepage.window":
      if pMode = "update" then
        tWndObj.getElement("char_mission_field").setFocus(1)
        tWndObj.getElement("char_name_field").setProperty(#blend, 30)
        tWndObj.getElement("char_name_field").setEdit(0)
        tWndObj.getElement("char_name_field").setText(pPropsToServer["name"])
      else
        tWndObj.getElement("char_name_field").setFocus(1)
        tWndObj.getElement("char_namepage_done_button").hide()
        tWndObj.getElement("char_page_number").setText("1/3")
      end if
      tTempProps = ["name": "char_name_field", "customData": "char_mission_field"]
    "figure_infopage.window":
      tTempProps = ["email": "char_email_field", "phoneNumber": "char_mobile_field"]
      pTempPassword = [:]
      tDelim = the itemDelimiter
      the itemDelimiter = "."
      tWndObj.getElement("char_birth_dd_field").setText(pPropsToServer["birthday"].item[1])
      tWndObj.getElement("char_birth_mm_field").setText(pPropsToServer["birthday"].item[2])
      tWndObj.getElement("char_birth_yyyy_field").setText(pPropsToServer["birthday"].item[3])
      the itemDelimiter = tDelim
      if pMode <> "update" then
        tTempProps.deleteProp("phoneNumber")
        tWndObj.getElement("char_mobile_field").setText(getText("char_defphonenum"))
        tWndObj.getElement("char_infopage_done_button").hide()
        tWndObj.getElement("char_page_number").setText("2/3")
      end if
    "figure_areapage.window":
      tTempProps = [:]
      tSelection = tWndObj.getElement("char_continent_drop").getSelection()
      tCountryListImg = getObject("CountryMngr").getCountryListImg(tSelection)
      tWndObj.getElement("char_country_field").feedImage(tCountryListImg)
      if pMode <> "update" then
        tWndObj.getElement("char_page_number").setText("3/3")
      end if
  end case
  repeat with f = 1 to tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps[tProp]
    if tWndObj.elementExists(tElem) then
      tWndObj.getElement(tElem).setText(pPropsToServer[tProp])
    end if
  end repeat
end

on getMyDataFromFields me
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  case pOpenWindow of
    "figure_namepage.window":
      tTempProps = ["name": "char_name_field", "customData": "char_mission_field"]
    "figure_infopage.window":
      tDay = tWndObj.getElement("char_birth_dd_field").getText()
      tMonth = tWndObj.getElement("char_birth_mm_field").getText()
      tYear = tWndObj.getElement("char_birth_yyyy_field").getText()
      pPropsToServer["birthday"] = tDay & "." & tMonth & "." & tYear
      tTempProps = ["email": "char_email_field", "phoneNumber": "char_mobile_field"]
    "figure_areapage.window":
      tSelection = tWndObj.getElement("char_continent_drop").getSelection(#text)
      if voidp(tSelection) then
        error(me, "Drop selection returns VOID!!!", #getMyDataFromFields)
      end if
      tContinent = getObject("CountryMngr").getContinentData(tSelection)
      if not voidp(tContinent) then
        if tContinent.type = #country then
          pPropsToServer["region"] = getObject("CountryMngr").getSelectedCountryID()
          pPropsToServer["country"] = "0"
        else
          pPropsToServer["region"] = tContinent[#number]
          pPropsToServer["country"] = getObject("CountryMngr").getSelectedCountryID()
        end if
      else
        pPropsToServer["region"] = "0"
        pPropsToServer["country"] = "0"
      end if
  end case
  repeat with f = 1 to tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps[tProp]
    if tWndObj.elementExists(tElem) then
      pPropsToServer[tProp] = tWndObj.getElement(tElem).getText()
    end if
  end repeat
  return 1
end

on updateSexRadioButtons me
  tRadioButtonOnImg = member(getmemnum("button.radio.on")).image
  tRadioButtonOffImg = member(getmemnum("button.radio.off")).image
  if voidp(pPropsToServer["sex"]) then
    pPropsToServer["sex"] = "M"
  end if
  tWndObj = getWindow(pWindowTitle)
  if pPropsToServer["sex"] contains "F" then
    if tWndObj.elementExists("char_sex_f") then
      tWndObj.getElement("char_sex_f").feedImage(tRadioButtonOnImg)
    end if
    if tWndObj.elementExists("char_sex_m") then
      tWndObj.getElement("char_sex_m").feedImage(tRadioButtonOffImg)
    end if
  else
    if tWndObj.elementExists("char_sex_m") then
      tWndObj.getElement("char_sex_m").feedImage(tRadioButtonOnImg)
    end if
    if tWndObj.elementExists("char_sex_f") then
      tWndObj.getElement("char_sex_f").feedImage(tRadioButtonOffImg)
    end if
  end if
end

on updateCheckButton me, tElement, tProp, tChangeMode
  tOnImg = member(getmemnum("button.checkbox.on")).image
  tOffImg = member(getmemnum("button.checkbox.off")).image
  tWndObj = getWindow(pWindowTitle)
  if voidp(pPropsToServer[tProp]) then
    pPropsToServer[tProp] = "1"
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pPropsToServer[tProp] = "1" then
      pPropsToServer[tProp] = "0"
    else
      pPropsToServer[tProp] = "1"
    end if
  end if
  if pPropsToServer[tProp] = "1" then
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on createDefaultFigure me, tRandom
  pPropsToServer["figure"] = [:]
  if not voidp(pOldFigure) and pOldSex = pPropsToServer["sex"] then
    pPropsToServer["figure"] = pOldFigure
    repeat with tPart in ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"]
      tmodel = pPropsToServer["figure"][tPart]["model"]
      tColor = pPropsToServer["figure"][tPart]["color"]
      me.setPartModel(tPart, tmodel)
      me.setPartColor(tPart, tColor)
    end repeat
    me.updateFigurePreview()
    me.updateAllPrewIcons()
    return 
  end if
  repeat with tPart in ["hr", "hd", "ch", "lg", "sh"]
    if voidp(tRandom) then
      tRandom = 0
    end if
    if tRandom then
      tMaxValue = me.getComponent().getCountOfPart(tPart, pPropsToServer["sex"])
      tNumber = random(tMaxValue)
    else
      tNumber = 1
    end if
    tPartProps = me.getComponent().getModelOfPartByOrderNum(tPart, tNumber, pPropsToServer["sex"])
    if tPartProps.ilk = #propList then
      tColorList = tPartProps["firstcolor"]
      tSetID = tPartProps["setid"]
      tColorId = 1
      if not listp(tColorList) then
        tColorList = list(tColorList)
      end if
      repeat with f = 1 to tPartProps["changeparts"].count
        tMultiPart = tPartProps["changeparts"].getPropAt(f)
        tmodel = string(tPartProps["changeparts"][tMultiPart])
        if tmodel.char.count = 1 then
          tmodel = "00" & tmodel
        else
          if tmodel.char.count = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        if tColorList.count >= f then
          tColor = rgb(tColorList[f])
        else
          tColor = rgb(tColorList[1])
        end if
        me.setPartModel(tMultiPart, tmodel)
        me.setPartColor(tMultiPart, tColor)
        pPropsToServer["figure"][tMultiPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": tColorId]
        me.setIndexNumOfPartOrColor("partcolor", tMultiPart, 0)
      end repeat
    end if
  end repeat
  me.updateFigurePreview()
  me.updateAllPrewIcons()
end

on createTemplateHuman me
  if not voidp(pBodyPartObjects) then
    return 0
  end if
  tProps = pPropsToServer
  pPeopleSize = "h"
  pBuffer = image(1, 1, 8)
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pBodyPartObjects = [:]
  repeat with tPart in ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"]
    tmodel = pPropsToServer["figure"][tPart]["model"]
    tColor = pPropsToServer["figure"][tPart]["color"]
    tDirection = 1
    tAction = "std"
    tAncestor = me
    tTempPartObj = createObject(#temp, "Bodypart Template Class")
    tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
    pBodyPartObjects.addProp(tPart, tTempPartObj)
  end repeat
end

on getSetID me, tPart
  if voidp(pPropsToServer["figure"][tPart]) then
    return error(me, "Part missing:" && tPart, #getSetID)
  end if
  if voidp(pPropsToServer["figure"][tPart]["setid"]) then
    return error(me, "Part setid missing:" && tPart, #getSetID)
  end if
  return pPropsToServer["figure"][tPart]["setid"]
end

on updateFigurePreview me
  if not voidp(pBodyPartObjects) and windowExists(pWindowTitle) then
    tWndObj = getWindow(pWindowTitle)
    tHumanImg = image(64, 102, 16)
    me.getPartImg(["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"], tHumanImg)
    tHumanImg = me.flipImage(tHumanImg)
    tWidth = tWndObj.getElement("human.preview.img").getProperty(#width)
    tHeight = tWndObj.getElement("human.preview.img").getProperty(#height)
    tPrewImg = image(tWidth, tHeight, 16)
    tdestrect = tPrewImg.rect - tHumanImg.rect * 2
    tMargins = rect(-11, -6, -11, -6)
    tdestrect = rect(0, tdestrect.bottom, tHumanImg.width * 2, tPrewImg.rect.bottom) + tMargins
    tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
    if tWndObj.elementExists("human.preview.img") then
      tWndObj.getElement("human.preview.img").feedImage(tPrewImg)
    end if
  end if
end

on updateAllPrewIcons me
  repeat with tPart in ["hr", "hd", "ch", "lg", "sh"]
    me.setIndexNumOfPartOrColor("partcolor", tPart, 0)
    me.setIndexNumOfPartOrColor("partmodel", tPart, 0)
    if not voidp(pPropsToServer["figure"][tPart]["color"]) then
      me.updatePartColorPreview(tPart, pPropsToServer["figure"][tPart]["color"])
      case tPart of
        "hd":
          tTemp = ["hd": pPropsToServer["figure"]["hd"]["model"], "ey": pPropsToServer["figure"]["ey"]["model"], "fc": pPropsToServer["figure"]["fc"]["model"]]
          me.updatePartPreview(tPart, tTemp)
        "ch":
          tTemp = ["ls": pPropsToServer["figure"]["ls"]["model"], "ch": pPropsToServer["figure"]["ch"]["model"], "rs": pPropsToServer["figure"]["rs"]["model"]]
          me.updatePartPreview(tPart, tTemp)
        otherwise:
          tTemp = [:]
          tTemp.addProp(tPart, pPropsToServer["figure"][tPart]["model"])
          me.updatePartPreview(tPart, tTemp)
      end case
    end if
  end repeat
end

on updatePartPreview me, tPart, tChangingPartPropList
  tElemID = "part." & tPart & ".preview"
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement(tElemID)
  if not voidp(pBodyPartObjects) and tElem <> 0 then
    tTempPartImg = image(64, 102, 16)
    tPartList = []
    case tPart of
      "hd":
        tTempChangingParts = ["hd", "ey", "fc"]
      "ch":
        tTempChangingParts = ["ls", "ch", "rs"]
      otherwise:
        tTempChangingParts = [tPart]
    end case
    repeat with tChancePart in tTempChangingParts
      tMultiPart = tChancePart
      tTempChangeParts = ["hr", "hd", "ch", "lg", "sh", "ey", "fc", "ls", "rs", "ls", "rs"]
      if tTempChangeParts.getOne(tMultiPart) > 0 then
        tmodel = string(tChangingPartPropList[tMultiPart])
        tPartList.add(tMultiPart)
        if length(tmodel) = 1 then
          tmodel = "00" & tmodel
        else
          if length(tmodel) = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        me.setPartModel(tMultiPart, tmodel)
      end if
    end repeat
    me.getPartImg(tPartList, tTempPartImg)
    tTempPartImg = me.flipImage(tTempPartImg).trimWhiteSpace()
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tPrewImg = image(tWidth, tHeight, 16)
    tdestrect = tPrewImg.rect - tTempPartImg.rect
    tMarginH = tPrewImg.width / 2 - tTempPartImg.width / 2
    tMarginV = tPrewImg.height / 2 - tTempPartImg.height / 2
    tdestrect = tTempPartImg.rect + rect(tMarginH, tMarginV, tMarginH, tMarginV)
    tPrewImg.copyPixels(tTempPartImg, tdestrect, tTempPartImg.rect)
    tElem.feedImage(tPrewImg)
  end if
end

on updatePartColorPreview me, tPart, tColor
  tElemID = "part.color." & tPart & ".preview"
  if voidp(tColor) then
    tColor = rgb(255, 255, 255)
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists(tElemID) then
    tWndObj.getElement(tElemID).getProperty(#sprite).bgColor = tColor
  end if
end

on getPartImg me, tPartList, tImg
  if tPartList.ilk <> #list then
    tPartList = [tPartList]
  end if
  repeat with tPart in tPartList
    call(#copyPicture, [pBodyPartObjects[tPart]], tImg)
  end repeat
end

on setPartColor me, tPart, tColor
  if not voidp(pBodyPartObjects) then
    call(#setColor, [pBodyPartObjects[tPart]], tColor)
  end if
end

on setPartModel me, tPart, tmodel
  if not voidp(pBodyPartObjects) then
    call(#setModel, [pBodyPartObjects[tPart]], tmodel)
  end if
end

on setIndexNumOfPartOrColor me, tChange, tPart, tOrderNum, tMaxValue
  if voidp(pPartChangeButtons[tChange]) then
    pPartChangeButtons[tChange] = [:]
  end if
  if voidp(pPartChangeButtons[tChange][tPart]) then
    pPartChangeButtons[tChange][tPart] = [:]
  end if
  if tOrderNum = 0 then
    pPartChangeButtons[tChange][tPart] = 1
  else
    if pPartChangeButtons[tChange][tPart] + tOrderNum > tMaxValue then
      pPartChangeButtons[tChange][tPart] = 1
    else
      if pPartChangeButtons[tChange][tPart] + tOrderNum < 1 then
        pPartChangeButtons[tChange][tPart] = tMaxValue
      else
        pPartChangeButtons[tChange][tPart] = pPartChangeButtons[tChange][tPart] + tOrderNum
      end if
    end if
  end if
  return pPartChangeButtons[tChange][tPart]
end

on changePart me, tPart, tButtonDir
  tSetID = me.getSetID(tPart)
  if tSetID = 0 then
    return error(me, "Incorrect part data", #changePart)
  end if
  tMaxValue = me.getComponent().getCountOfPart(tPart, pPropsToServer["sex"])
  tPartIndexNum = me.setIndexNumOfPartOrColor("partmodel", tPart, tButtonDir, tMaxValue)
  tPartProps = me.getComponent().getModelOfPartByOrderNum(tPart, tPartIndexNum, pPropsToServer["sex"])
  if tPartProps.ilk = #propList then
    tColorList = tPartProps["firstcolor"]
    tSetID = tPartProps["setid"]
    tColorId = 1
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    repeat with f = 1 to tPartProps["changeparts"].count
      tMultiPart = tPartProps["changeparts"].getPropAt(f)
      tmodel = string(tPartProps["changeparts"][tMultiPart])
      if tmodel.char.count = 1 then
        tmodel = "00" & tmodel
      else
        if tmodel.char.count = 2 then
          tmodel = "0" & tmodel
        end if
      end if
      if tColorList.count >= f then
        tColor = rgb(tColorList[f])
      else
        tColor = rgb(tColorList[1])
      end if
      me.setPartModel(tMultiPart, tmodel)
      me.setPartColor(tMultiPart, tColor)
      pPropsToServer["figure"][tMultiPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": tColorId]
      me.setIndexNumOfPartOrColor("partcolor", tMultiPart, 0)
    end repeat
    if not voidp(pPropsToServer["figure"][tPart]) then
      if not voidp(pPropsToServer["figure"][tPart]["color"]) then
        tColor = pPropsToServer["figure"][tPart]["color"]
      end if
    end if
    me.updateFigurePreview()
    me.updatePartColorPreview(tPart, tColor)
    me.updatePartPreview(tPart, tPartProps["changeparts"])
  end if
end

on changePartColor me, tPart, tButtonDir
  tSetID = me.getSetID(tPart)
  if tSetID = 0 then
    return error(me, "Incorrect part data", #changePartColor)
  end if
  tMaxValue = me.getComponent().getCountOfPartColors(tPart, tSetID, pPropsToServer["sex"])
  tColorIndexNum = me.setIndexNumOfPartOrColor("partcolor", tPart, tButtonDir, tMaxValue)
  tPartProps = me.getComponent().getColorOfPartByOrderNum(tPart, tColorIndexNum, tSetID, pPropsToServer["sex"])
  if tPartProps.ilk = #propList then
    tColorList = tPartProps["color"]
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    repeat with f = 1 to tPartProps["changeparts"].count
      tMultiPart = tPartProps["changeparts"].getPropAt(f)
      if tColorList.count >= f then
        tColor = rgb(tColorList[f])
      else
        tColor = rgb(tColorList[1])
      end if
      me.setPartColor(tMultiPart, tColor)
      pPropsToServer["figure"][tMultiPart]["color"] = tColor
      pPropsToServer["figure"][tMultiPart]["colorid"] = tColorIndexNum
    end repeat
    if not voidp(pPropsToServer["figure"][tPart]) then
      if not voidp(pPropsToServer["figure"][tPart]["color"]) then
        tColor = pPropsToServer["figure"][tPart]["color"]
      end if
    end if
    me.updateFigurePreview()
    me.updatePartColorPreview(tPart, tColor)
    me.updatePartPreview(tPart, tPartProps["changeparts"])
  end if
end

on focusKeyboardToSprite me, tElemID
  getWindow(pWindowTitle).getElement(tElemID).setFocus(1)
end

on checkName me
  if pMode <> "update" then
    tField = getWindow(pWindowTitle).getElement("char_name_field")
    if tField = 0 then
      return error(me, "Couldn't perform name check!", #checkName)
    end if
    tName = tField.getText().word[1]
    tField.setText(tName)
    if length(tName) = 0 then
      executeMessage(#alert, [#msg: "Alert_NoNameSet", #id: "nonameset"])
      return 0
    else
      if length(tName) < getIntVariable("name.length.min", 3) then
        executeMessage(#alert, [#msg: "Alert_YourNameIstooShort", #id: "name2short"])
        me.focusKeyboardToSprite("char_name_field")
        return 0
      else
        if pLastNameCheck <> tName then
          if me.getComponent().checkUserName(tName) = 0 then
            return 0
          end if
        end if
      end if
    end if
  end if
  pNameChecked = 1
  return 1
end

on checkPassword me
  if voidp(pTempPassword["char_pw_field"]) then
    tPw1 = []
  else
    tPw1 = pTempPassword["char_pw_field"]
  end if
  if voidp(pTempPassword["char_pwagain_field"]) then
    tPw2 = []
  else
    tPw2 = pTempPassword["char_pwagain_field"]
  end if
  if tPw1.count = 0 then
    pErrorMsg = pErrorMsg & getText("Alert_ForgotSetPassword") & RETURN
    return 0
  end if
  if tPw1.count < getIntVariable("pass.length.min", 3) then
    pErrorMsg = pErrorMsg & getText("Alert_YourPasswordIsTooShort") & RETURN
    me.ClearPasswordFields()
    return 0
  end if
  if tPw1 <> tPw2 then
    pErrorMsg = pErrorMsg & getText("Alert_WrongPassword") & RETURN
    me.ClearPasswordFields()
    return 0
  end if
  return 1
end

on BirthdayANDemailcheck me
  tWndObj = getWindow(pWindowTitle)
  tDay = integer(tWndObj.getElement("char_birth_dd_field").getText())
  tMonth = integer(tWndObj.getElement("char_birth_mm_field").getText())
  tYear = integer(tWndObj.getElement("char_birth_yyyy_field").getText())
  tBirthday = tDay & "." & tMonth & "." & tYear
  tEmail = tWndObj.getElement("char_email_field").getText()
  tBirthOK = 1
  if voidp(tDay) or tDay < 1 or tDay > 31 then
    tBirthOK = 0
  end if
  if voidp(tMonth) or tMonth < 1 or tMonth > 12 then
    tBirthOK = 0
  end if
  if voidp(tYear) or tYear < 1900 or tYear > 2100 then
    tBirthOK = 0
  end if
  tEmailOK = 0
  if length(tEmail) > 6 and tEmail contains "@" then
    repeat with f = offset("@", tEmail) + 1 to length(tEmail)
      if tEmail.char[f] = "." then
        tEmailOK = 1
      end if
      if tEmail.char[f] = "@" then
        tEmailOK = 0
        exit repeat
      end if
    end repeat
  end if
  if not tBirthOK then
    pErrorMsg = pErrorMsg & getText("Alert_Char_Birthday") & RETURN
  end if
  if not tEmailOK then
    pErrorMsg = pErrorMsg & getText("Alert_Char_Email") & RETURN
  end if
  if not tEmailOK or not tBirthOK then
    return 0
  else
    return 1
  end if
end

on checkAgreeTerms me
  if pPropsToServer["has_read_agreement"] <> "1" then
    pErrorMsg = pErrorMsg & getText("Alert_Char_Terms") & RETURN
    return 0
  else
    return 1
  end if
end

on userNameUnacceptable me
  executeMessage(#alert, [#msg: "Alert_unacceptableName", #id: "namenogood"])
  me.clearUserNameField()
end

on userNameAlreadyReserved me
  executeMessage(#alert, [#msg: "Alert_NameAlreadyUse", #id: "namereserved"])
  me.clearUserNameField()
end

on clearUserNameField me
  pNameChecked = 0
  tElem = getWindow(pWindowTitle).getElement("char_name_field")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(EMPTY)
  tElem.setFocus(1)
end

on ClearPasswordFields me
  tWndObj = getWindow(pWindowTitle)
  tWndObj.getElement("char_pw_field").setText(EMPTY)
  tWndObj.getElement("char_pwagain_field").setText(EMPTY)
  pTempPassword["char_pw_field"] = []
  pTempPassword["char_pwagain_field"] = []
  tWndObj.getElement("char_pw_field").setFocus(1)
end

on getPassword me
  tPw = EMPTY
  repeat with f in pTempPassword["char_pw_field"]
    tPw = tPw & f
  end repeat
  return tPw
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end

on eventProcFigurecreator me, tEvent, tSprID, tParm, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close", "char_namepage_back_button":
        me.getComponent().closeFigureCreator()
        me.getComponent().updateState("start")
        if getObject(#session).get(#userName) = EMPTY then
          if threadExists(#navigator) then
            getThread(#navigator).getInterface().getLogin().showLogin()
          end if
          if connectionExists(getVariable("connection.info.id")) then
            removeConnection(getVariable("connection.info.id"))
          end if
        end if
      "char_namepage_done_button":
        me.getMyDataFromFields()
        getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
        me.getComponent().sendFigureUpdateToServer(pPropsToServer)
        return me.closeFigureCreator()
      "char_namepage_next_button":
        if pNameChecked = 0 then
          if me.checkName() = 0 then
            return 1
          end if
        end if
        me.getMyDataFromFields()
        me.ChangeWindowView("figure_infopage.window")
        me.setMyDataToFields()
        me.updateCheckButton("char_spam_checkbox", "directMail")
        me.updateCheckButton("char_terms_checkbox", "has_read_agreement")
        if pMode = "update" then
          executeMessage(#alert, [#title: "char_note_title", #msg: "char_note_text", #id: "pwnote"])
        end if
      "char_infopage_back_button":
        me.getMyDataFromFields()
        me.ChangeWindowView("figure_namepage.window")
        me.setMyDataToFields()
        me.defineModes(pMode)
      "char_infopage_next_button", "char_infopage_done_button":
        if not objectExists("CountryMngr") then
          createObject("CountryMngr", "Country Selection Manager")
        end if
        pErrorMsg = EMPTY
        tProceed = 1
        tProceed = tProceed and me.checkPassword()
        tProceed = tProceed and me.BirthdayANDemailcheck()
        tProceed = tProceed and me.checkAgreeTerms()
        if tProceed then
          pPropsToServer["password"] = getPassword()
          me.getMyDataFromFields()
          if tSprID = "char_infopage_done_button" then
            getObject(#session).set(#userName, pPropsToServer["name"])
            getObject(#session).set(#password, pPropsToServer["password"])
            getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
            me.getComponent().sendFigureUpdateToServer(pPropsToServer)
            return me.closeFigureCreator()
          else
            if tSprID = "char_infopage_next_button" then
              me.ChangeWindowView("figure_areapage.window")
              return me.setMyDataToFields()
            end if
          end if
        else
          executeMessage(#alert, [#title: "Alert_Char_T", #msg: pErrorMsg, #id: "problems"])
        end if
      "char_areapage_back_button":
        me.getMyDataFromFields()
        me.ChangeWindowView("figure_infopage.window")
        me.setMyDataToFields()
        me.updateCheckButton("char_spam_checkbox", "directMail")
        me.updateCheckButton("char_terms_checkbox", "has_read_agreement")
      "char_areapage_done_button":
        me.getMyDataFromFields()
        getObject(#session).set(#userName, pPropsToServer["name"])
        getObject(#session).set(#password, pPropsToServer["password"])
        getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
        if pMode = "update" then
          me.getComponent().sendFigureUpdateToServer(pPropsToServer)
        else
          me.getComponent().sendNewFigureDataToServer(pPropsToServer)
        end if
        return me.getComponent().closeFigureCreator()
      "char_sex_m":
        pPropsToServer["sex"] = "M"
        me.createDefaultFigure(1)
        me.updateSexRadioButtons()
      "char_sex_f":
        pPropsToServer["sex"] = "F"
        me.createDefaultFigure(1)
        me.updateSexRadioButtons()
      "char_spam_checkbox":
        me.updateCheckButton("char_spam_checkbox", "directMail", 1)
      "char_terms_checkbox":
        me.updateCheckButton("char_terms_checkbox", "has_read_agreement", 1)
      "char_name_field":
        if pMode <> "update" and pNameChecked = 1 then
          pNameChecked = 0
        end if
      "char_continent_drop":
        tCountryListImg = getObject("CountryMngr").getCountryListImg(tParm)
        getWindow(pWindowTitle).getElement("char_country_field").feedImage(tCountryListImg)
      "char_terms_linktext":
        openNetPage("url_helpterms")
      "char_pledge_linktext":
        openNetPage("url_helppledge")
      "char_country_field":
        tWndObj = getWindow(pWindowTitle)
        tCntryMngr = getObject("CountryMngr")
        tCont = tWndObj.getElement("char_continent_drop").getSelection()
        tLine = tCntryMngr.getClickedLineNum(tParm)
        tName = tCntryMngr.getNthCountryName(tLine, tCont)
        if tName = 0 then
          return 1
        end if
        tCntryMngr.selectCountry(tName, tCont)
        tWndObj.getElement("char_country_field").feedImage(tCntryMngr.getCountryListImg(tCont))
      otherwise:
        if tSprID contains "change" and tSprID contains "button" then
          tTempDelim = the itemDelimiter
          the itemDelimiter = "."
          tPart = tSprID.item[2]
          tButtonType = tSprID.item[tSprID.item.count - 1]
          the itemDelimiter = tTempDelim
          if tButtonType contains "left" then
            tButtonType = -1
          else
            tButtonType = 1
          end if
          if not (tSprID contains "color") then
            me.changePart(tPart, tButtonType)
          else
            me.changePartColor(tPart, tButtonType)
          end if
        end if
    end case
  else
    if tEvent = #keyDown then
      case tSprID of
        "char_name_field":
          if charToNum(the key) = 0 then
            return 0
          end if
          tValidKeys = getVariable("permitted.name.chars")
          if not (tValidKeys contains the key) then
            case the keyCode of
              48:
                me.checkName()
                return 0
              49:
                return 1
              51:
                return 0
              117:
                getWindow(pWindowTitle).getElement(tSprID).setText(EMPTY)
                return 0
              otherwise:
                if tValidKeys = EMPTY then
                  return 0
                else
                  return 1
                end if
            end case
          else
            return 0
          end if
        "char_pw_field", "char_pwagain_field":
          if pNameChecked = 0 then
            if not me.checkName() then
              return 1
            end if
          end if
          if voidp(pTempPassword[tSprID]) then
            pTempPassword[tSprID] = []
          end if
          case the keyCode of
            48:
              return 0
            49:
              return 1
            51:
              if pTempPassword[tSprID].count > 0 then
                pTempPassword[tSprID].deleteAt(pTempPassword[tSprID].count)
              end if
            117:
              pTempPassword[tSprID] = []
            otherwise:
              tValidKeys = getVariable("permitted.name.chars")
              tTheKey = the key
              tASCII = charToNum(tTheKey)
              if tASCII > 31 and tASCII < 128 then
                if tValidKeys contains tTheKey or tValidKeys = EMPTY then
                  if pTempPassword[tSprID].count < getIntVariable("pass.length.max", 16) then
                    pTempPassword[tSprID].append(tTheKey)
                  else
                    executeMessage(#alert, [#title: "alert_tooLongPW", #msg: "alert_shortenPW", #id: "pw2long"])
                  end if
                end if
              end if
          end case
          tStr = EMPTY
          repeat with tChar in pTempPassword[tSprID]
            put "*" after tStr
          end repeat
          getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
          set the selStart to pTempPassword[tSprID].count
          set the selEnd to pTempPassword[tSprID].count
          return 1
        "char_mission_field":
          if pNameChecked = 0 then
            if not me.checkName() then
              return 1
            end if
          end if
        "char_email_field":
          return 0
        "char_birth_dd_field", "char_birth_mm_field":
          case the keyCode of
            48:
              return 0
            51:
              return 0
            117:
              return 0
            otherwise:
              if getWindow(tWndID).getElement(tSprID).getText().length < 2 then
                return 0
              else
                return 1
              end if
          end case
        "char_birth_yyyy_field":
          case the keyCode of
            48:
              return 0
            51:
              return 0
            117:
              return 0
            otherwise:
              if getWindow(tWndID).getElement(tSprID).getText().length < 4 then
                return 0
              else
                return 1
              end if
          end case
      end case
    end if
  end if
end
