property pTutorialID, pTutorialName, pTopics, pTopicStatuses, pTopicID, pSteps, pWaitingForPrefs, pEnabled, pStarted, pCurrentTopicID, pCurrentTopicNumber, pCurrentStepID, pCurrentStepNumber, pTriggerList, pRestrictionList, pUserSex, pUserName, pDefaultTutorial

on construct me
  me.pEnabled = 0
  me.pStarted = 0
  me.pWaitingForPrefs = 1
  me.pDefaultTutorial = "NUF"
  registerMessage(#userlogin, me.getID(), #getUserProperties)
  registerMessage(#restart_tutorial, me.getID(), #restartTutorial)
  registerMessage(#tutorial_send_console_message, me.getID(), #sendConsoleMessage)
  return 1
end

on deconstruct me
  unregisterMessage(#restart_tutorial, me.getID(), #restartTutorial)
  return 1
end

on getUserProperties me
  tSession = getObject(#session)
  me.pUserName = tSession.GET(#userName)
  me.pUserSex = tSession.GET(#user_sex)
  me.getInterface().setUserSex(me.pUserSex)
end

on startDefaultTutorial me
  me.startTutorial(me.pDefaultTutorial)
end

on restartTutorial me
  me.pEnabled = 1
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  tConn.send("SET_TUTORIAL_MODE", [#integer: 1])
  me.startTutorial(me.pDefaultTutorial)
end

on setEnabled me, tBoolean
  me.pEnabled = tBoolean
  if me.pWaitingForPrefs and me.pStarted then
    me.pWaitingForPrefs = 0
    me.startTutorial()
  end if
  return 1
end

on startTutorial me, tTutorialName
  me.pStarted = 1
  if not voidp(tTutorialName) then
    me.pTutorialName = tTutorialName
  end if
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  if me.pWaitingForPrefs then
    tConn.send("GET_ACCOUNT_PREFERENCES")
    return 0
  end if
  if not me.pEnabled or voidp(me.pTutorialName) then
    return 0
  end if
  tConn.send("GET_TUTORIAL_CONFIGURATION", [#string: me.pTutorialName])
  me.getInterface().show()
  return 1
end

on setTutorialConfig me, tConfigList
  me.pTutorialID = tConfigList[#id]
  me.pTutorialName = tConfigList[#name]
  me.pTopics = tConfigList.getaProp(#topics)
  repeat with tTopicNum = 1 to me.pTopics.count
    tTextKey = me.pTutorialName & "_" & me.pTopics[tTopicNum]
    me.pTopics[tTopicNum] = tTextKey
  end repeat
  me.pTopicStatuses = tConfigList.getaProp(#statuses)
  me.getInterface().showMenu(#welcome)
end

on setTopicConfig me, tTopicConfig
  me.pTopicID = tTopicConfig[#id]
  me.pSteps = tTopicConfig[#steps]
  tTopicName = me.pTopics.getaProp(me.pTopicID)
  repeat with tStepNum = 1 to me.pSteps.count
    tStepName = me.pSteps[tStepNum][#name]
    tContentList = me.pSteps[tStepNum][#content]
    repeat with tContentNum = 1 to tContentList.count
      tContentName = tContentList[tContentNum][#textKey]
      tTextKey = tTopicName & "_" & tStepName & "_" & tContentName
      tContentList[tContentNum][#textKey] = tTextKey
    end repeat
    me.pSteps[tStepNum][#tutor][#textKey] = tTopicName & "_" & tStepName & "_tutor"
  end repeat
  me.pCurrentStepNumber = 0
  me.nextStep()
  return 1
end

on selectTopic me, tTopicID
  if tTopicID = #menu then
    me.getInterface().showMenu()
    return 1
  end if
  me.pCurrentTopicID = tTopicID
  me.pCurrentTopicNumber = me.pTopics.getPos(me.pTopics.getaProp(tTopicID))
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  tConn.send("GET_TUTORIAL_TOPIC_CONFIGURATION", [#integer: tTopicID])
end

on nextStep me
  if me.pSteps.count = 0 then
    return 1
  end if
  me.pCurrentStepNumber = me.pCurrentStepNumber + 1
  if me.pCurrentStepNumber > me.pSteps.count then
    return 0
  end if
  me.pCurrentStepID = me.pSteps.getPropAt(me.pCurrentStepNumber)
  tTopic = me.pSteps[me.pCurrentStepNumber]
  me.clearTriggers()
  me.clearRestrictions()
  me.setTriggers(tTopic[#triggers])
  me.setRestrictions(tTopic[#restrictions])
  me.executePrerequisites(tTopic[#prerequisites])
  me.getInterface().setBubbles(tTopic[#content])
  tTutorList = tTopic[#tutor]
  if me.pCurrentStepNumber = me.pSteps.count then
    tLinkList = [:]
    tNextTopicNumber = me.pCurrentTopicNumber + 1
    if tNextTopicNumber <= me.pTopics.count then
      tNextTopicID = me.pTopics.getPropAt(tNextTopicNumber)
      tNextTopicName = me.pTopics[tNextTopicNumber]
      tLinkList.setaProp(tNextTopicID, tNextTopicName)
    end if
    tLinkList.setaProp(#menu, "Select another topic")
    tTutorList.setaProp(#links, tLinkList)
    tConn = getConnection(getVariable("connection.info.id"))
    if voidp(tConn) then
      return error(me, "Connection not found.", #startTutorial, #major)
    end if
    tConn.send("COMPLETE_TUTORIAL_TOPIC", [#integer: me.pTopicID])
  end if
  me.getInterface().setTutor(tTutorList)
end

on executePrerequisites me, tPrerequisiteList
  repeat with i = 1 to tPrerequisiteList.count
    tMessage = tPrerequisiteList.getPropAt(i)
    tParam = tPrerequisiteList[i]
    executeMessage(symbol(tMessage), tParam)
  end repeat
end

on setTriggers me, tTriggerList
  if not listp(tTriggerList) then
    return 0
  end if
  repeat with tTrigger in tTriggerList
    registerMessage(symbol(tTrigger), me.getID(), #nextStep)
  end repeat
  me.pTriggerList = tTriggerList
end

on setRestrictions me, tRestrictionList
  if not listp(tRestrictionList) then
    return 0
  end if
  repeat with tRestriction in tRestrictionList
    registerMessage(symbol(tRestriction), me.getID(), #restriction)
  end repeat
  me.pRestrictionList = tRestrictionList
end

on clearTriggers me
  if not listp(me.pTriggerList) then
    return 0
  end if
  repeat with tTrigger in me.pTriggerList
    unregisterMessage(symbol(tTrigger), me.getID())
  end repeat
end

on clearRestrictions me
  if not listp(me.pRestrictionList) then
    return 0
  end if
  repeat with tRestriction in me.pRestrictionList
    unregisterMessage(symbol(tRestriction), me.getID())
  end repeat
end

on stopTutorial me
  me.pStarted = 0
  me.clearTriggers()
  me.clearRestrictions()
  me.getInterface().stopTutorial()
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #stopTutorial, #major)
  end if
  tConn.send("SET_TUTORIAL_MODE", [#integer: 0])
end

on restriction me
  me.getInterface().showMenu(#offtopic)
end

on sendConsoleMessage me, tTextKey
  if getObject(#messenger_component).pItemList[#messages].count > 0 then
    return 1
  end if
  tText = getText(tTextKey)
  tMsg = [#campaign: 1, #id: "3", #url: "http://www.fi", #message: tText]
  getObject("messenger_component").receive_Message(tMsg)
end

on getTopics me
  return me.pTopics
end

on showMenu me
  me.clearTriggers()
  me.clearRestrictions()
  me.getInterface().showMenu()
end

on setTopicResult me, tBoolReward
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #stopTutorial, #major)
  end if
  tConn.send("GET_TUTORIAL_STATUS", [#integer: me.pTutorialID])
end

on setTutorialStatus me, tStatusList
  me.pTopicStatuses = tStatusList
end

on getProperty me, tProp
  case tProp of
    #topics:
      return me.pTopics
    #statuses:
      return me.pTopicStatuses
  end case
end
