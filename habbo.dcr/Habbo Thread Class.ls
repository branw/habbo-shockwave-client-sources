property pLoaderBarID

on construct me
  pLoaderBarID = "InitLoader"
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

on updateState me, tstate
  case tstate of
    "initialize":
      pState = tstate
      return me.delay(1000, #updateState, "load_external_casts")
    "load_external_casts":
      pState = tstate
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
        if memberExists("habbo_simple.window") and memberExists("general_loader.window") then
          createWindow(pLoaderBarID, "habbo_simple.window")
          tWndObj = getWindow(pLoaderBarID)
          tWndObj.merge("general_loader.window")
          tWndObj.center()
          tWndObj.getElement("general_loader_text").setText(getText("loading_project"))
          tBuffer = tWndObj.getElement("gen_loaderbar").getProperty(#buffer).image
          tProps = [#buffer: tBuffer, #bgColor: rgb(255, 255, 255)]
        else
          tProps = [#buffer: #window, #bgColor: rgb(255, 255, 255)]
        end if
        showLoadingBar(tCastLoadId, tProps)
        registerCastloadCallback(tCastLoadId, #updateState, me.getID(), "load_external_casts")
      else
        if windowExists(pLoaderBarID) then
          removeWindow(pLoaderBarID)
        end if
        return me.delay(100, #updateState, "login")
      end if
    "login":
      pState = tstate
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().updateState("login")
      end if
      return 1
  end case
end

on solveRequiredCasts me
  tCastList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  tPrefix = "cast.load."
  i = 1
  repeat while 1
    if variableExists(tPrefix & i) then
      tString = getVariable(tPrefix & i)
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
