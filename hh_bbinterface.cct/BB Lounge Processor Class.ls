on construct me
  initThread("bouncingloungemenu.thread.index")
  return 1
end

on deconstruct me
  closeThread(#loungemenu)
  return 1
end

on refresh me, tTopic, tdata
  if getThread(#loungemenu) = 0 then
    return 0
  end if
  tIntObj = getThread(#loungemenu).getInterface()
  if tIntObj = 0 then
    return 0
  end if
  tComObj = getThread(#loungemenu).getComponent()
  if tComObj = 0 then
    return 0
  end if
  case tTopic of
    #loungeinfo:
      return 1
    #tournamentlogo:
      return tIntObj.setTournamentLogo(tdata)
    #numtickets:
      return tIntObj.setNumTickets()
    #instancelist:
      return tIntObj.setInstanceList()
    #gameparameters:
      return tIntObj.showGameCreation()
    #createok, #gameinstance:
      if tComObj.checkUserWasKicked() then
        tIntObj.showErrorMessage("kickedfromteam")
      end if
      tComObj.saveUserTeamIndex()
      return tIntObj.showInstance()
    #gamedeleted:
      me.getGameSystem().unobserveInstance()
      tComObj.resetUserTeamIndex()
      return tIntObj.ChangeWindowView(#gameList)
    #joinparameters:
      return tComObj.joinGame()
    #watchok:
      return tIntObj.setWatchMode(1)
    #watchfailed:
      tIntObj.setWatchMode(0)
      return tIntObj.showErrorMessage(tdata[#reasonstr], tdata[#request])
    #joinfailed:
      return tIntObj.showErrorMessage(tdata[#reasonstr], tdata[#request])
    #createfailed:
      return tIntObj.showErrorMessage(tdata[#reasonstr], tdata[#request], tdata[#key])
    #startfailed:
      return tIntObj.showErrorMessage(tdata[#reasonstr], tdata[#request])
    #instancenotavailable:
      return tIntObj.showErrorMessage("game_deleted")
    #idlewarning:
      return tIntObj.showErrorMessage("idlewarning")
  end case
  return 1
end
