property pCatalogProps, pProductOrderData

on construct me
  pOrderInfoList = []
  pCatalogProps = [:]
  pProductOrderData = [:]
  if variableExists("ctlg.editmode") then
    pCatalogProps["editmode"] = getVariable("ctlg.editmode")
  else
    pCatalogProps["editmode"] = "production"
  end if
  registerMessage(#edit_catalogue, me.getID(), #editModeOn)
  return 1
end

on deconstruct me
  pOrderInfoList = []
  pCatalogProps = [:]
  unregisterMessage(#edit_catalogue, me.getID())
  return 1
end

on editModeOn me
  setVariable("ctlg.editmode", "develop")
  pCatalogProps["editmode"] = getVariable("ctlg.editmode")
end

on getLanguage me
  if variableExists("language") then
    tLanguage = getVariable("language")
  else
    tLanguage = "en"
  end if
  return tLanguage
end

on checkProductOrder me, tProductProps
  if tProductProps.ilk <> #propList then
    return error(me, "Incorrect SelectedProduct proplist", #buySelectedProduct)
  end if
  if not voidp(tProductProps["purchaseCode"]) then
    tProps = [:]
    tstate = "OK"
    if not voidp(tProductProps["name"]) then
      tProps[#name] = tProductProps["name"]
    else
      tProps[#name] = "ERROR"
      tstate = "ERROR"
    end if
    if not voidp(tProductProps["purchaseCode"]) then
      tProps[#code] = tProductProps["purchaseCode"]
    else
      tProps[#code] = "ERROR"
      tstate = "ERROR"
    end if
    if not voidp(tProductProps["price"]) then
      tProps[#price] = tProductProps["price"]
    else
      tProps[#price] = "ERROR"
      tstate = "ERROR"
    end if
    pProductOrderData = tProductProps.duplicate()
    me.getInterface().showOrderInfo(tstate, tProps)
    return 1
  else
    pProductOrderData = [:]
    return 0
  end if
end

on purchaseProduct me, tGiftProps
  if pProductOrderData.ilk <> #propList then
    return error(me, "Incorrect Product data", #purchaseProduct)
  end if
  if tGiftProps.ilk <> #propList then
    return error(me, "Incorrect Gift Props", #purchaseProduct)
  end if
  if voidp(pProductOrderData["name"]) then
    return error(me, "Product name not found", #purchaseProduct)
  end if
  if voidp(pProductOrderData["purchaseCode"]) then
    return error(me, "PurchaseCode name not found", #purchaseProduct)
  end if
  if voidp(pProductOrderData["extra_parm"]) then
    pProductOrderData["extra_parm"] = "-"
  end if
  if voidp(pCatalogProps["editmode"]) then
    return error(me, "Catalogue mode not found", #purchaseProduct)
  end if
  if voidp(pCatalogProps["lastPageID"]) then
    return error(me, "Catalogue page id missing", #purchaseProduct)
  end if
  if not voidp(tGiftProps["gift"]) then
    tGift = tGiftProps["gift"] & RETURN
    if not voidp(tGiftProps["gift_receiver"]) then
      tGift = tGift & tGiftProps["gift_receiver"] & RETURN
    else
      tGift = EMPTY
    end if
    if not voidp(tGiftProps["gift_msg"]) then
      tGift = tGift & tGiftProps["gift_msg"] & RETURN
    else
      tGift = EMPTY
    end if
  else
    tGift = "0"
  end if
  tOrderStr = EMPTY
  tOrderStr = "GPRC /" & RETURN
  tOrderStr = tOrderStr & pCatalogProps["editmode"] & RETURN
  tOrderStr = tOrderStr & pCatalogProps["lastPageID"] & RETURN
  tOrderStr = tOrderStr & me.getLanguage() & RETURN
  tOrderStr = tOrderStr & pProductOrderData["purchaseCode"] & RETURN
  tOrderStr = tOrderStr & pProductOrderData["extra_parm"] & RETURN
  tOrderStr = tOrderStr & tGift
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  return getConnection(getVariable("connection.info.id")).send(#info, tOrderStr)
end

on retrieveCatalogueIndex me
  if not voidp(pCatalogProps["editmode"]) then
    tEditmode = pCatalogProps["editmode"]
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  if not voidp(pCatalogProps["catalogueIndex"]) and tEditmode <> "develop" then
    me.getInterface().saveCatalogueIndex(pCatalogProps["catalogueIndex"])
  else
    if connectionExists(getVariable("connection.info.id")) then
      return getConnection(getVariable("connection.info.id")).send(#info, "GCIX /" & tEditmode & "/" & tLanguage)
    else
      return 0
    end if
  end if
end

on retrieveCataloguePage me, tPageID
  if not voidp(pCatalogProps["editmode"]) then
    tEditmode = pCatalogProps["editmode"]
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  pProductOrderData = VOID
  if not voidp(pCatalogProps[tPageID]) and tEditmode <> "develop" then
    pCatalogProps["lastPageID"] = tPageID
    me.getInterface().cataloguePageData(pCatalogProps[tPageID])
  else
    if connectionExists(getVariable("connection.info.id")) then
      return getConnection(getVariable("connection.info.id")).send(#info, "GCAP /" & tEditmode & "/" & tPageID & "/" & tLanguage)
    else
      return 0
    end if
  end if
  return 0
end

on purchaseReady me, tStatus, tMsg
  case tStatus of
    "OK":
      me.getInterface().showPurchaseOk()
    "NOBALANCE":
      error(me, "User out of cash!", #purchaseReady)
    "ERROR":
      error(me, "Purchase error:" && tMsg, #purchaseReady)
    otherwise:
      error(me, "Unsupported purchase result:" && tStatus && tMsg, #purchaseReady)
  end case
  return 1
end

on saveCatalogueIndex me, tdata
  if tdata.ilk <> #propList then
    return error(me, "Incorrect Catalogue Format", #saveCatalogueIndex)
  end if
  if tdata.count = 0 then
    return 0
  end if
  pCatalogProps["catalogueIndex"] = tdata
  me.getInterface().saveCatalogueIndex(tdata)
end

on saveCataloguePage me, tdata
  if tdata.ilk <> #propList then
    return error(me, "Incorrect Catalogue Page Format", #saveCataloguePage)
  end if
  if tdata.count = 0 then
    return 0
  end if
  if not voidp(tdata["id"]) then
    tdata = me.solveCatalogueMembers(tdata)
    tPageID = tdata["id"]
    pCatalogProps[tPageID] = tdata
    pCatalogProps["lastPageID"] = tPageID
    me.getInterface().cataloguePageData(tdata)
  else
    return error(me, "Catalogue Page ID missing", #saveCataloguePage)
  end if
end

on solveCatalogueMembers me, tdata
  tLanguage = me.getLanguage()
  if not voidp(tdata["headerImage"]) then
    if memberExists(tdata["headerImage"] & "_" & tLanguage) then
      tdata["headerImage"] = getmemnum(tdata["headerImage"] & "_" & tLanguage)
    else
      if memberExists(tdata["headerImage"]) then
        tdata["headerImage"] = getmemnum(tdata["headerImage"])
      else
        tdata["headerImage"] = 0
      end if
    end if
  end if
  if not voidp(tdata["teaserImgList"]) then
    tImageNameList = tdata["teaserImgList"]
    tMemList = []
    if tImageNameList.count > 0 then
      repeat with tImg in tImageNameList
        if memberExists(tImg & "_" & tLanguage) then
          tMemList.add(getmemnum(tImg & "_" & tLanguage))
          next repeat
        end if
        if memberExists(tImg) then
          tMemList.add(getmemnum(tImg))
          next repeat
        end if
        tMemList.add(0)
      end repeat
    end if
    tdata["teaserImgList"] = tMemList
  end if
  if not voidp(tdata["productList"]) then
    repeat with f = 1 to tdata["productList"].count
      tProductData = tdata["productList"][f]
      if not voidp(tProductData["purchaseCode"]) then
        tPrewMember = "ctlg_pic_"
        tPurchaseCode = tProductData["purchaseCode"]
        if memberExists(tPrewMember & tLanguage & "_" & tPurchaseCode) then
          tdata["productList"][f]["prewImage"] = getmemnum(tPrewMember & tLanguage & "_" & tPurchaseCode)
        else
          if memberExists(tPrewMember & tPurchaseCode) then
            tdata["productList"][f]["prewImage"] = getmemnum(tPrewMember & tPurchaseCode)
          else
            tdata["productList"][f]["prewImage"] = 0
          end if
        end if
        if memberExists(tPrewMember & "small_" & tLanguage & tPurchaseCode) then
          tdata["productList"][f]["smallPrewImg"] = getmemnum(tPrewMember & "small_" & tLanguage & "_" & tPurchaseCode)
        else
          if memberExists(tPrewMember & "small_" & tPurchaseCode) then
            tdata["productList"][f]["smallPrewImg"] = getmemnum(tPrewMember & "small_" & tPurchaseCode)
          else
            tdata["productList"][f]["smallPrewImg"] = 0
          end if
        end if
      end if
      if not voidp(tProductData["class"]) then
        tClass = tProductData["class"]
        if tClass contains "*" then
          tClass = tClass.char[1..offset("*", tClass) - 1]
        end if
        if tdata["productList"][f]["smallPrewImg"] = 0 then
          if memberExists(tClass & "_small") then
            tdata["productList"][f]["smallPrewImg"] = getmemnum(tClass & "_small")
            next repeat
          end if
          tdata["productList"][f]["smallPrewImg"] = getmemnum("no_icon_small")
        end if
      end if
    end repeat
  end if
  return tdata
end
