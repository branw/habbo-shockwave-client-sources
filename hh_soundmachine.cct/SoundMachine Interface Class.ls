property pSoundMachineWindowID, pSoundMachineConfirmWindowID, pSoundSetSlotWd, pSoundSetSlotHt, pSoundSetSlotMarginWd, pSoundSetSlotMarginHt, pSoundSetSampleMemberList, pSoundSetSampleMemberName, pTimeLineSlotWd, pTimeLineSlotHt, pTimeLineSlotMarginWd, pTimeLineSlotMarginHt, pSoundSetIconUpdateTimer, pPlayHeadUpdateTimer

on construct me
  pSoundSetIconUpdateTimer = "sound_machine_icon_timer"
  pPlayHeadUpdateTimer = "sound_machine_playhead_timer"
  pSoundMachineWindowID = getText("sound_machine_window")
  pSoundMachineConfirmWindowID = getText("sound_machine_confirm_window")
  registerMessage(#s_machine, me.getID(), #showSoundMachine)
  pSoundSetSlotWd = 25
  pSoundSetSlotHt = 25
  pSoundSetSlotMarginWd = -1
  pSoundSetSlotMarginHt = -1
  pSoundSetSampleMemberList = ["sound_system_ui_sample_g_", "sound_system_ui_sample_y_", "sound_system_ui_sample_p_"]
  pSoundSetSampleMemberName = "sound_system_ui_sample_"
  pTimeLineSlotWd = 23
  pTimeLineSlotHt = 25
  pTimeLineSlotMarginWd = -1
  pTimeLineSlotMarginHt = 1
  return 1
end

on deconstruct me
  unregisterMessage(#s_machine, me.getID())
  if timeoutExists(pSoundSetIconUpdateTimer) then
    removeTimeout(pSoundSetIconUpdateTimer)
  end if
  if timeoutExists(pPlayHeadUpdateTimer) then
    removeTimeout(pPlayHeadUpdateTimer)
  end if
  return 1
end

on showSoundMachine me
  if not windowExists(pSoundMachineWindowID) then
    if not createWindow(pSoundMachineWindowID, "sound_machine_window.window", VOID, VOID, #modal) then
      return error(me, "Failed to open Sound Machine window!!!", #showSoundMachine)
    else
      tWndObj = getWindow(pSoundMachineWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseLeave)
      if not tWndObj.merge("sound_machine_ui.window") then
        return tWndObj.close()
      end if
      me.updateListVisualizations()
      me.renderTimeLine()
      me.updatePlayHead()
      me.updatePlayButton()
      me.getComponent().getConfigurationData()
      tElem = tWndObj.getElement("sound_timeline_playhead")
      if tElem <> 0 then
        tsprite = tElem.getProperty(#sprite)
        if ilk(tsprite) = #sprite then
          removeEventBroker(tsprite.spriteNum)
        end if
      end if
      tWndObj.center()
      tWndObj.moveBy(0, -30)
    end if
  end if
  return 1
end

on hideSoundMachine me
  if windowExists(pSoundMachineWindowID) then
    me.getComponent().closeEdit()
    return removeWindow(pSoundMachineWindowID)
  else
    return 0
  end if
end

on confirmAction me, tAction, tParameter
  tResult = me.getComponent().confirmAction(tAction, tParameter)
  if tResult then
    if not windowExists(pSoundMachineConfirmWindowID) then
      if not createWindow(pSoundMachineConfirmWindowID, "habbo_full.window", VOID, VOID, #modal) then
        return error(me, "Failed to open Sound Machine confirm window!!!", #confirmAction)
      else
        tWndObj = getWindow(pSoundMachineConfirmWindowID)
        tWndObj.registerClient(me.getID())
        tWndObj.registerProcedure(#eventProcConfirm, me.getID(), #mouseUp)
        if not tWndObj.merge("habbo_decision_dialog.window") then
          return tWndObj.close()
        end if
        tElem = tWndObj.getElement("habbo_decision_text_a")
        if tElem <> 0 then
          tText = getText("sound_machine_confirm_" & tAction)
          tElem.setText(tText)
        end if
        tElem = tWndObj.getElement("habbo_decision_text_b")
        if tElem <> 0 then
          tText = getText("sound_machine_confirm_" & tAction & "_long")
          tElem.setText(tText)
        end if
        tWndObj.center()
        tWndObj.moveBy(0, -30)
      end if
    end if
  end if
  return tResult
end

on soundMachineSelected me, tIsOn
  if windowExists(pSoundMachineWindowID) then
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem = 0 then
      return 0
    end if
  end if
  return me.showSelectAction(tIsOn)
end

on showSelectAction me, tIsOn
  if not windowExists(pSoundMachineWindowID) then
    if not createWindow(pSoundMachineWindowID, "habbo_full.window") then
      return error(me, "Failed to open Sound Machine window!!!", #showSoundMachine)
    else
      tWndObj = getWindow(pSoundMachineWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSelectAction, me.getID(), #mouseUp)
      if not tWndObj.merge("sound_machine_action.window") then
        return tWndObj.close()
      end if
      tElem = tWndObj.getElement("sound_machine_onoff")
      if tElem <> 0 then
        if tIsOn then
          tText = getText("sound_machine_turn_off")
        else
          tText = getText("sound_machine_turn_on")
        end if
        tElem.setText(tText)
      end if
      tWndObj.center()
      tWndObj.moveBy(0, -30)
    end if
  else
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem <> 0 then
      if tIsOn then
        tText = getText("sound_machine_turn_off")
      else
        tText = getText("sound_machine_turn_on")
      end if
      tElem.setText(tText)
    end if
  end if
  return 1
end

on hideSelectAction me
  if windowExists(pSoundMachineWindowID) then
    return removeWindow(pSoundMachineWindowID)
  else
    return 0
  end if
end

on hideConfirm me
  if windowExists(pSoundMachineConfirmWindowID) then
    return removeWindow(pSoundMachineConfirmWindowID)
  else
    return 0
  end if
end

on renderSoundSets me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  repeat with tIndex = me.getComponent().getSoundSetLimit() down to 1
    if pSoundSetSampleMemberList.count >= tIndex then
      tNameBase = pSoundSetSampleMemberList[tIndex]
    else
      tNameBase = pSoundSetSampleMemberList[1]
    end if
    tElem = tWndObj.getElement("sound_set_samples_" & tIndex)
    if tElem <> 0 then
      tImg = me.getComponent().renderSoundSet(tIndex, pSoundSetSlotWd, pSoundSetSlotHt, pSoundSetSlotMarginWd, pSoundSetSlotMarginHt, tNameBase, pSoundSetSampleMemberName)
      if tImg <> 0 then
        tElem.feedImage(tImg)
        next repeat
      end if
      tElem.feedImage(image(0, 0, 32))
    end if
  end repeat
  return 1
end

on updateSoundSetTabs me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tHooveredTab = me.getComponent().getSoundSetHooveredTab()
  repeat with tIndex = me.getComponent().getSoundSetLimit() down to 1
    tVisible = 1
    tid = me.getComponent().getSoundSetID(tIndex)
    if tid <> 0 then
      tElem = tWndObj.getElement("sound_set_tab_text_" & tIndex)
      if tElem <> 0 then
        tElem.setProperty(#visible, 1)
        if tIndex <> tHooveredTab then
          tText = getText("furni_sound_set_" & tid & "_name")
        else
          tText = getText("sound_machine_eject")
        end if
        tElem.setText(tText)
      end if
    else
      tVisible = 0
    end if
    tElemList = ["sound_set_tab_" & tIndex, "sound_set_tab_text_" & tIndex]
    repeat with tElemName in tElemList
      tElem = tWndObj.getElement(tElemName)
      if tElem <> 0 then
        tElem.setProperty(#visible, tVisible)
      end if
    end repeat
  end repeat
  return 1
end

on updateSoundSetList me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tSetsReady = 1
  repeat with tIndex = me.getComponent().getSoundSetListPageSize() down to 1
    tid = me.getComponent().getSoundSetListID(tIndex)
    if tid <> 0 then
      tElem = tWndObj.getElement("set_list_text_" & tIndex)
      if tElem <> 0 then
        tText = getText("furni_sound_set_" & tid & "_name")
        tElem.setText(tText)
      end if
      tElem = tWndObj.getElement("set_list_icon_" & tIndex)
      if tElem <> 0 then
        if objectExists("Preview_renderer") then
          tSoundSetName = "sound_set_" & tid
          tdata = [#class: tSoundSetName, #type: #Active]
          executeMessage(#downloadObject, tdata)
          if tdata[#ready] = 0 then
            tSetsReady = 0
          end if
          tIcon = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, VOID, tSoundSetName)
          tIcon = tIcon.trimWhiteSpace()
        else
          tIcon = image(0, 0, 32)
        end if
        tWd = tElem.getProperty(#width)
        tHt = tElem.getProperty(#height)
        tCenteredImage = image(tWd, tHt, 32)
        tMatte = tIcon.createMatte()
        tXchange = (tCenteredImage.width - tIcon.width) / 2
        tYchange = (tCenteredImage.height - tIcon.height) / 2
        tRect1 = tIcon.rect + rect(tXchange, tYchange, tXchange, tYchange)
        tCenteredImage.copyPixels(tIcon, tRect1, tIcon.rect, [#maskImage: tMatte, #ink: 41])
        tElem.feedImage(tCenteredImage)
      end if
    else
      tElem = tWndObj.getElement("set_list_text_" & tIndex)
      if tElem <> 0 then
        tElem.setText(EMPTY)
      end if
      tElem = tWndObj.getElement("set_list_icon_" & tIndex)
      if tElem <> 0 then
        tIcon = image(0, 0, 32)
        tElem.feedImage(tIcon)
      end if
    end if
    tElem = tWndObj.getElement("set_list_text2_" & tIndex)
    if tElem <> 0 then
      tElem.setText(EMPTY)
    end if
  end repeat
  tElem = tWndObj.getElement("set_list_index")
  if tElem <> 0 then
    tText = me.getComponent().getSoundListPage() & "/" & me.getComponent().getSoundListPageCount()
    tElem.setText(tText)
  end if
  if not tSetsReady then
    if not timeoutExists(pSoundSetIconUpdateTimer) then
      createTimeout(pSoundSetIconUpdateTimer, 500, #updateSoundSetList, me.getID(), VOID, 1)
    end if
  end if
end

on renderTimeLine me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("sound_timeline")
  if tElem <> 0 then
    tImg = me.getComponent().renderTimeLine(pTimeLineSlotWd, pTimeLineSlotHt, pTimeLineSlotMarginWd, pTimeLineSlotMarginHt, pSoundSetSampleMemberList, pSoundSetSampleMemberName, "sound_system_ui_timeline_bg2")
    if tImg <> 0 then
      tElem.feedImage(tImg)
    else
      tElem.feedImage(image(0, 0, 32))
    end if
  end if
  return 1
end

on updateListVisualizations me
  me.updateSoundSetList()
  me.updateSoundSetTabs()
  me.renderSoundSets()
end

on updateSoundSetSlots me
  me.updateSoundSetTabs()
  me.renderSoundSets()
end

on soundSetEvent me, tSetID, tPos, tEvent
  if tEvent <> #mouseLeave then
    if tPos.locH < 0 or tPos.locV < 0 then
      return 0
    end if
    tX = 1 + tPos.locH / (pSoundSetSlotWd + pSoundSetSlotMarginWd)
    tY = 1 + tPos.locV / (pSoundSetSlotHt + pSoundSetSlotMarginHt)
  else
    tX = 1
    tY = 1
  end if
  if me.getComponent().soundSetEvent(tSetID, tX, tY, tEvent) then
    me.renderSoundSets()
    return 1
  end if
  return 0
end

on soundSetTabEvent me, tSetID, tEvent
  if me.getComponent().soundSetTabEvent(tSetID, tEvent) then
    me.updateListVisualizations()
  end if
  return 1
end

on timeLineEvent me, tPos, tRect, tEvent
  tX = 1 + tPos.locH / (pTimeLineSlotWd + pTimeLineSlotMarginWd)
  tY = 1 + tPos.locV / (pTimeLineSlotHt + pTimeLineSlotMarginHt)
  if tEvent = #mouseLeave or tEvent = #mouseWithin then
    if tPos.locH < 0 or tPos.locV < 0 or tPos.locH > tRect[3] - tRect[1] or tPos.locV > tRect[4] - tRect[2] then
      tX = -1
      tY = -1
      tEvent = #mouseLeave
    end if
  end if
  if me.getComponent().timeLineEvent(tX, tY, tEvent) then
    me.renderTimeLine()
  end if
  return 1
end

on updatePlayHead me
  tPlayTime = me.getComponent().getPlayTime()
  tSlotLength = me.getComponent().getTimeLineSlotLength()
  tBehind = tPlayTime mod tSlotLength
  if not timeoutExists(pPlayHeadUpdateTimer) then
    createTimeout(pPlayHeadUpdateTimer, tSlotLength - tBehind, #updatePlayHead, me.getID(), VOID, 1)
  end if
  tPos = tPlayTime / tSlotLength
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("sound_timeline")
  if tElem <> 0 then
    tLocX = tElem.getProperty(#locX)
    tElem = tWndObj.getElement("sound_timeline_playhead")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
      tWd = tElem.getProperty(#width)
      tElem.setProperty(#locX, tLocX + (pTimeLineSlotWd - tWd) / 2 + pTimeLineSlotWd * tPos + pTimeLineSlotMarginWd * tPos)
    end if
  end if
  return 1
  return 0
end

on updatePlayButton me
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if me.getComponent().getPlayTime() = 0 then
    tElem = tWndObj.getElement("sound_play_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
    end if
    tElem = tWndObj.getElement("sound_stop_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
  else
    tElem = tWndObj.getElement("sound_play_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
    tElem = tWndObj.getElement("sound_stop_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
    end if
  end if
end

on eventProcSoundMachine me, tEvent, tSprID, tParam, tWndID
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if offset("sound_set_samples_", tSprID) = 1 then
    tSoundSetID = value(tSprID.char[("sound_set_samples_").length + 1..tSprID.length])
    tElem = tWndObj.getElement(tSprID)
    tRect = tElem.getProperty(#rect)
    me.soundSetEvent(tSoundSetID, point(the mouseH - tRect[1], the mouseV - tRect[2]), tEvent)
    if not me.getComponent().getHooveredSampleReady() then
      tElem.setProperty(#cursor, 4)
    else
      tElem.setProperty(#cursor, "cursor.finger")
    end if
  else
    if offset("sound_set_tab_text_", tSprID) = 1 then
      tSoundSetID = value(tSprID.char[("sound_set_tab_text_").length + 1..tSprID.length])
      me.soundSetTabEvent(tSoundSetID, tEvent)
    else
      if tSprID = "sound_timeline" or tSprID = "sound_timeline_bg" then
        tElem = tWndObj.getElement("sound_timeline")
        if tElem <> 0 then
          tRect = tElem.getProperty(#rect)
          me.timeLineEvent(point(the mouseH - tRect[1], the mouseV - tRect[2]), tRect, tEvent)
        end if
      end if
    end if
  end if
  if offset("set_list_icon_", tSprID) = 1 then
    if tEvent = #mouseEnter then
      tIndex = value(tSprID.char[("set_list_icon_").length + 1..tSprID.length])
      tElem = tWndObj.getElement("set_list_text2_" & tIndex)
      if tElem <> 0 then
        tText = getText("sound_machine_insert")
        tElem.setText(tText)
      end if
    else
      if tEvent = #mouseLeave then
        me.updateListVisualizations()
      end if
    end if
  end if
  if tEvent = #mouseUp then
    if tSprID = "set_list_left" then
      if me.getComponent().changeSetListPage(-1) then
        me.updateSoundSetList()
      end if
    else
      if tSprID = "set_list_right" then
        if me.getComponent().changeSetListPage(1) then
          me.updateSoundSetList()
        end if
      else
        if offset("set_list_icon_", tSprID) = 1 then
          tIndex = value(tSprID.char[("set_list_icon_").length + 1..tSprID.length])
          if me.getComponent().loadSoundSet(tIndex) then
            me.updateListVisualizations()
          end if
        else
          if tSprID = "sound_play_button" then
            me.getComponent().playSong()
            me.updatePlayHead()
          else
            if tSprID = "sound_stop_button" then
              me.getComponent().stopSong()
            else
              if tSprID = "sound_save_button" then
                me.confirmAction("save", EMPTY)
              else
                if tSprID = "sound_trash_button" then
                  me.confirmAction("clear", EMPTY)
                else
                  if tSprID = "close" then
                    me.confirmAction("close", EMPTY)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return 1
end

on eventProcSelectAction me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        me.hideSelectAction()
      "sound_machine_edit":
        me.hideSelectAction()
        me.getComponent().stopSong()
        me.showSoundMachine()
      "sound_machine_onoff":
        me.getComponent().changeFurniState()
        me.hideSelectAction()
    end case
  end if
  return 1
end

on eventProcConfirm me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close", "habbo_decision_cancel":
        me.hideConfirm()
      "habbo_decision_ok":
        me.getComponent().actionConfirmed()
        me.hideConfirm()
    end case
  end if
  return 1
end
