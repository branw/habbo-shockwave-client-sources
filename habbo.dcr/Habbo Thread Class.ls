property pLoaderBarID

on new me
  return me
end

on construct me
  pLoaderBarID = "JustAloader"
  registerMessage(#initialize, me.getID(), #updateState)
  return 1
end

on deconstruct me
  if windowExists(pLoaderBarID) then
    removeWindow(pLoaderBarID)
  end if
  unregisterMessage(#initialize, me.getID())
  return 1
end

on updateState me, tState
  case tState of
    "initialize":
      pState = tState
      return me.delay(1000, #updateState, "load_external_casts")
    "load_external_casts":
      pState = tState
      tCastList = me.solveRequiredCasts()
      if tCastList.count > 0 then
        tCastLoadId = startCastLoad(tCastList, 1)
        if memberExists("habbo_simple.window") then
          createWindow(pLoaderBarID, "habbo_simple.window", 255, 215)
          tWndObj = getWindow(pLoaderBarID)
          tWndObj.merge("general_loader.window")
          tWndObj.getElement("general_loader_text").setText(getText("loading_project"))
          tBuffer = tWndObj.getSpriteByID("gen_loaderbar").member.image
          tProps = [#buffer: tBuffer, #bgColor: rgb(255, 255, 255)]
        else
          tProps = [#buffer: #window, #bgColor: rgb(255, 255, 255)]
        end if
        showLoadingBar(tCastLoadId, tProps)
        registerCastloadCallback(tCastLoadId, #updateState, me.getID(), "holdOn")
      else
        return me.updateState("login")
      end if
      return 1
    "holdOn":
      pState = tState
      tCastList = me.solveRequiredCasts()
      tNewList = [:]
      repeat with i = 1 to tCastList.count
        tCastName = tCastList[i]
        if not castExists(tCastName) then
          tInteger = tCastList.getPropAt(i)
          tNewList.addProp(tInteger, tCastName)
        end if
      end repeat
      if tNewList.count > 0 then
        tCastLoadId = startCastLoad(tNewList, 1)
        tBuffer = getWindow(pLoaderBarID).getSpriteByID("gen_loaderbar").member.image
        tProps = [#buffer: tBuffer, #bgColor: rgb(255, 255, 255)]
        showLoadingBar(tCastLoadId, tProps)
        registerCastloadCallback(tCastLoadId, #updateState, me.getID(), "holdOn")
      else
        if windowExists(pLoaderBarID) then
          removeWindow(pLoaderBarID)
        end if
        return me.delay(1000, #updateState, "login")
      end if
    "login":
      pState = tState
      getThread(#navigator).getComponent().updateState("login")
      return 1
  end case
end

on solveRequiredCasts me
  tCastList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  i = 1
  repeat while 1
    if variableExists("cast.load." & i) then
      tString = getVariable("cast.load." & i)
      if tString.item.count = 2 then
        tInt = value(tString.item[1])
        if voidp(tInt) then
          tInt = 1
        end if
        tName = tString.item[2]
      else
        tInt = 1
        tName = tString
      end if
      tCastList.addProp(tInt, tName)
      i = i + 1
      next repeat
    end if
    exit repeat
  end repeat
  the itemDelimiter = tDelim
  return tCastList
end
