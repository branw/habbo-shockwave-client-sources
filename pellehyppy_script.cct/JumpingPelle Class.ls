property direction, memberPrefix, memberModels, moving, destLScreen, startLScreen, moveStart, moveTime, talking, pModels, pDirections, pSprites, pInks, lParts, pActions, pColors, pLocZShifts, counter, pAnimFixH, pAnimFixV, pFlipped, mainAction, restingHeight, controller, userController, myEy, pLocFix, iLocZFix, swimSuitModels, swim, swimSdHeight, swimAnimCountDir, StayAndSwim, sign, signSpr, signDir, tSpr, pModLevel, isModerator, name, PelleImg, jumpAction, jumpAnimFrame, runAnimList, AnimListCounter, pSmallJumpList, changes, plastPressKey, pSpeed, pStatus, pnewLocV, pJumpSpeed, pVelocityV, pjumpBoardEnd, pjumpBoardStart, locX, locY, height, pMyLoc, pStartloc, pJumpDirection, pJumpLastDirection, pJumpMode, pJumpLoop, pJumpMaxAnimFrames, pJumpData, pPlayerMode, pLastJumpDirection, myLocZ, pScreenUpOrDown, pRemoveJumperTime, pBgScreenBuffer
global gMyModLevel, gpelleBgImg, OOO, gpObjects, gUserSprites, gMyName, gXFactor, gYFactor, peopleSize

on new me, tName, tMemberModels, tswimsuit, tplayerMode
  name = tName
  memberPrefix = "h"
  memberModels = tMemberModels
  counter = 0
  pModels = keyValueToPropList(tMemberModels, "&")
  pColors = [:]
  pInks = [:]
  pFlipped = [:]
  sort(pInks)
  sort(pColors)
  sort(pModels)
  lParts = []
  pSprites = [:]
  pLocFix = point(0, 0)
  iLocZFix = 0
  pPlayerMode = tplayerMode
  if not (tswimsuit contains "ch=") then
    put "UIMAPUKU PUUTTUU" && name && tswimsuit
    return me
  end if
  swimSuitModels = keyValueToPropList(tswimsuit, "&")
  changes = 0
  pStatus = #Run
  lastPressKey = EMPTY
  pRemoveJumperTime = the milliSeconds
  pSpeed = 0
  jumpAction = "std"
  runAnimList = [0, 1, 2, 3, 3, 2, 1, 0]
  pSmallJumpList = [1, 1, 1, 2, 2, 2, 2, 2, 0, 0, 1]
  jumpAnimFrame = 0
  AnimListCounter = 1
  pJumpDirection = "u"
  pLastJumpDirection = "d"
  pJumpLastDirection = pJumpDirection
  pJumpLoop = 0
  pStartloc = point(545, 99)
  sprite(40).loc = pStartloc
  locX = sprite(40).locH
  locY = sprite(40).locV
  pMyLoc = sprite(40).loc
  pnewLocV = sprite(40).locV
  sprite(40).flipH = 1
  sprite(40).flipV = 0
  myLocZ = 20000021
  pScreenUpOrDown = #up
  pVelocityV = 1.5
  pjumpBoardEnd = 393
  pjumpBoardStart = 523
  pJumpSpeed = 2
  swimsuit(me)
  figure(me)
  PelleImg = image(60, 60, 32, rgb(155, 155, 255))
  gpelleBgImg = image(108, 102, 16, rgb(157, 206, 255))
  pBgScreenBuffer = image(member(getmemnum("bg3")).width, member(getmemnum("bg3")).height, 16, rgb(157, 206, 255))
  pBgScreenBuffer.fill(pBgScreenBuffer.rect, rgb(157, 206, 255))
  pilvet = [point(141 + random(250), random(100)), point(141 + random(250), random(30) + 150), point(141 + random(250), random(20) + 240)]
  repeat with f in pilvet
    num = getmemnum("pilvi" & random(5))
    tRect = member(num).rect + rect(f.locH, f.locV, f.locH, f.locV)
    pBgScreenBuffer.copyPixels(member(num).image, tRect, member(num).rect, [#maskImage: member(num).image.createMatte(), #ink: 8])
  end repeat
  pBgScreenBuffer.copyPixels(member(getmemnum("bg3")).image, pBgScreenBuffer.rect, pBgScreenBuffer.rect, [#maskImage: member(getmemnum("bg3")).image.createMatte(), #ink: 8])
  pKeyTimerStat = 0
  UpdatePelle(me)
  return me
end

on swimsuit me
  if swimSuitModels.findPos("ch") <> VOID then
    oldDelim = the itemDelimiter
    pModels.ch = swimSuitModels.ch
    the itemDelimiter = "/"
    pModels.sd = "s01" & "/" & pModels.sd.item[2]
    pModels.bd = "s01" & "/" & pModels.bd.item[2]
    pModels.lh = "s01" & "/" & pModels.lh.item[2]
    pModels.rh = "s01" & "/" & pModels.rh.item[2]
    the itemDelimiter = oldDelim
    pModels.deleteProp("rs")
    pModels.deleteProp("ls")
    pModels.deleteProp("sh")
    pModels.deleteProp("lg")
    repeat with f in ["rs", "ls", "sh", "lg"]
      if pSprites.findPos(f) <> VOID then
        delspr = pSprites.getProp(f)
        gUserSprites.deleteProp(delspr)
        pSprites.deleteProp(f)
        sprMan_releaseSprite(delspr)
      end if
    end repeat
  end if
end

on figure me
  if (the movieName).char[1..length(the movieName) - 4] <> "gf_private" then
    peopleSize = "sh"
  else
    peopleSize = "h"
  end if
  pAnimFixV = [[0, 0, 1, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 1], [0, 0, 0, 0]]
  oldDelim = the itemDelimiter
  repeat with i = 1 to count(pModels)
    add(lParts, string(getPropAt(pModels, i)))
    model = getAt(pModels, i)
    the itemDelimiter = "/"
    if (item 2 of model).length > 3 then
      clothColor = value("color(#rgb," & item 2 of model & ")")
    else
      clothColor = paletteIndex(integer(item 2 of model))
    end if
    if clothColor = VOID then
      clothColor = color(#rgb, 0, 0, 0)
    end if
    addProp(pColors, getPropAt(pModels, i), clothColor)
    model = item 1 of model
    if (getPropAt(pModels, i) = "fc" or getPropAt(pModels, i) = "hd") and model = "002" and gXFactor < 33 then
      model = "001"
    end if
    setAt(pModels, i, model)
    the itemDelimiter = oldDelim
  end repeat
  pLocZShifts = [:]
  addProp(pLocZShifts, #sd, -100)
  addProp(pLocZShifts, #bd, 0)
  addProp(pLocZShifts, #sh, 5)
  addProp(pLocZShifts, #lg, 10)
  addProp(pLocZShifts, #ch, 15)
  addProp(pLocZShifts, #lh, 20)
  addProp(pLocZShifts, #ls, 30)
  addProp(pLocZShifts, #rh, 20)
  addProp(pLocZShifts, #rs, 30)
  addProp(pLocZShifts, #fc, 100)
  addProp(pLocZShifts, #ey, 111)
  addProp(pLocZShifts, #hr, 112)
  addProp(pLocZShifts, #hd, 31)
  animFrame = 0
  swimAnimCountDir = 0
  OOO = me
  if gXFactor < 33 then
    myEy = [:]
    addProp(myEy, #models, getaProp(pModels, #ey))
    addProp(myEy, #colors, getaProp(pColors, #ey))
    addProp(myEy, #Inks, getaProp(pInks, #ey))
    addProp(myEy, #LocZShifts, getaProp(pLocZShifts, #ey))
    deleteProp(pSprites, #ey)
    if getPos(lParts, "ey") > 0 then
      deleteAt(lParts, getPos(lParts, "ey"))
    end if
  end if
end

on beginSprite me
  the keyboardFocusSprite = me.spriteNum
end

on StopRunnig me
  if pStatus = #Run then
    pSpeed = pSpeed - 0.10000000000000001
    if pSpeed <= 0 then
      jumpAction = "std"
      jumpAnimFrame = 0
      pSpeed = 0
    end if
  end if
end

on StopJumping me
  global gpShowSprites
  if pMyLoc.locV > 511 then
    if pScreenUpOrDown = #up then
      pScreenUpOrDown = #down
      pMyLoc.locV = -20
      pnewLocV = pMyLoc.locV
      myLocZ = 70003
      if pPlayerMode = 0 then
        go("jumpingplace_down")
      else
        if the frame = label("jumpplay") + 1 then
          go("play_down")
        end if
      end if
    end if
  else
    if pScreenUpOrDown = #down then
      pJumStoploc = point(429, 310)
      jumpReadyV = pJumStoploc.locV + (pJumStoploc.locH - pMyLoc.locH) / 2
      if pMyLoc.locV >= jumpReadyV - 40 then
        spr = getaProp(gpShowSprites, "SplashBig")
        if spr > 0 then
          sendSprite(spr, symbol("fuseShow_enter"), pMyLoc + point(-10, 0))
        end if
      end if
      if pMyLoc.locV >= jumpReadyV - 20 then
        myLocZ = 69999
      end if
      if pMyLoc.locV >= jumpReadyV then
        pMyLoc.locV = jumpReadyV
        if pPlayerMode = 0 then
          pStatus = #ready
          if name = gMyName then
            repeat with f = 1 to length(pJumpData)
              temp = f
              if pJumpData.char[f] <> "0" then
                exit repeat
              end if
            end repeat
            pJumpData = pJumpData.char[temp..length(pJumpData)]
            sendJumpData = compressString(pJumpData)
            sendFuseMsg("JUMPPERF " & name & RETURN & memberModels & RETURN & swimSuitModels & RETURN & sendJumpData)
            pJumpData = EMPTY
          end if
        else
          pStatus = #dive
        end if
      end if
    end if
  end if
end

on UpdatePelle me
  PelleImg = image(60, 60, 32, rgb(255, 255, 255))
  repeat with f in ["bd", "lh", "hd", "fc", "hr", "ch", "rh"]
    case f of
      "ey":
        pInk = 36
      "ch":
        pInk = 41
      "sd":
        pInk = 32
      otherwise:
        pInk = 41
    end case
    cColor = pColors.getProp(f)
    if f = "bd" or f = "lh" or f = "ch" or f = "rh" then
      if jumpAction contains "jd" then
        dir = 0
      else
        dir = 2
      end if
      mem = getmemnum("sh_" & jumpAction & "_" & f & "_" & pModels.getProp(f) & "_" & dir & "_" & jumpAnimFrame)
      if mem < 0 then
        mem = getmemnum("sh_" & "std" & "_" & f & "_" & pModels.getProp(f) & "_" & 2 & "_" & 0)
      end if
    else
      if pJumpDirection = "d" or jumpAction contains "jus" and jumpAnimFrame = 2 then
        dir = 0
      else
        dir = 2
      end if
      if jumpAction contains "jds" and jumpAnimFrame = 2 then
        dir = 2
      end if
      mem = getmemnum("sh_" & "std" & "_" & f & "_" & pModels.getProp(f) & "_" & dir & "_0")
    end if
    if mem < 0 then
      next repeat
    end if
    tMemNum = mem
    tImage = member(tMemNum).image
    tRegPoint = member(tMemNum).regPoint
    tX = -tRegPoint[1] + 10
    tY = PelleImg.rect.height - tRegPoint[2] - 8
    tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
    PelleImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tImage.createMatte(), #ink: pInk, #bgColor: cColor])
  end repeat
  member(getmemnum("JumpingPelle")).image = PelleImg
  member(getmemnum("JumpingPelle")).centerRegPoint = 1
end

on JumpingExitFrame me
  if pStatus = #Run then
    if jumpAction = "run" then
      AnimListCounter = AnimListCounter + 1
      if AnimListCounter > runAnimList.count then
        AnimListCounter = 1
      end if
      jumpAnimFrame = runAnimList[AnimListCounter]
      pMyLoc.locH = pMyLoc.locH - 2 * integer(pSpeed)
      pnewLocV = pnewLocV + 1 * integer(pSpeed)
      if pSpeed > 1 then
        pMyLoc.locV = pnewLocV - jumpAnimFrame
      else
        pMyLoc.locV = pnewLocV
      end if
    end if
    UpdatePelle(me)
    if pMyLoc.locH <= pjumpBoardEnd + 3 then
      jumpAnimFrame = 1
      pStatus = #jump
      pJumpSpeed = 1
    else
      pSpeed = pSpeed - 0.05
      if pSpeed < 0 then
        pSpeed = 0
      end if
    end if
    StopRunnig(me)
  else
    if pStatus = #jump then
      pMyLoc.locH = pMyLoc.locH - 2 * integer(pSpeed)
      pnewLocV = pnewLocV + 1 * integer(pSpeed) - pJumpSpeed
      pMyLoc.locV = pnewLocV
      pJumpSpeed = pJumpSpeed - pVelocityV
      if pMyLoc.locH > pjumpBoardEnd then
        jumpBoardColV = pStartloc.locV + (pStartloc.locH - pMyLoc.locH) / 2
        if pMyLoc.locV >= jumpBoardColV then
          pMyLoc.locV = jumpBoardColV
          pStatus = #Run
          jumpAction = "std"
          jumpAnimFrame = 0
          StopRunnig(me)
          pJumpSpeed = 0
        end if
      else
        if pJumpSpeed < -12 then
          pJumpSpeed = -12
        end if
        pSpeed = pSpeed - 0.08
        if pSpeed < 0 then
          pSpeed = 0
        end if
      end if
      UpdatePelle(me)
      if pStatus = #jump then
        if pMyLoc.locH > pjumpBoardEnd and pMyLoc.locV - 3 > jumpBoardColV then
          pJumpMode = #goinactive
        end if
        if pJumpMode = #Active and pJumpLoop = 0 and plastPressKey <> jumpAction.char[3] then
          pJumpMode = #goinactive
        end if
        if jumpAction = "jus" or jumpAction = "jds" then
          pJumpMode = #Active
        end if
        if pJumpMode = #Active then
          jumpAnimFrame = jumpAnimFrame + 1
          if jumpAnimFrame > pJumpMaxAnimFrames then
            if pJumpLoop = 1 then
              jumpAnimFrame = 0
            else
              jumpAnimFrame = pJumpMaxAnimFrames
            end if
          end if
          if jumpAnimFrame = pJumpMaxAnimFrames then
            if jumpAction = "jus" or jumpAction = "jds" then
              jumpAnimFrame = 1
              pJumpMaxAnimFrames = 1
              if pJumpDirection = "u" then
                pJumpDirection = "d"
              else
                pJumpDirection = "u"
              end if
              jumpAction = "j" & pJumpDirection & "n"
            end if
          end if
        else
          if pJumpMode = #goinactive then
            if pJumpLoop = 1 then
              jumpAnimFrame = 0
              pJumpMode = #inactive
            else
              jumpAnimFrame = jumpAnimFrame - 1
              if jumpAnimFrame < 0 then
                jumpAnimFrame = 0
                pJumpMode = #inactive
              end if
            end if
            if jumpAction = "jun" or jumpAction = "jdn" then
              jumpAnimFrame = 1
            end if
          else
            if pJumpMode = #inactive then
              jumpAction = "jmp"
              if pJumpSpeed > 0 then
                jumpAnimFrame = 2
              else
                jumpAnimFrame = 0
              end if
              if pJumpSpeed < -5 then
                jumpAnimFrame = 1
                pJumpMaxAnimFrames = 1
                jumpAction = "j" & pJumpDirection & "n"
              end if
            end if
          end if
        end if
        if pMyLoc.locV > 511 then
          pStatus = #Run
          pSpeed = 0
          StopJumping(me)
        end if
        StopJumping(me)
      end if
    end if
  end if
  if pJumpLastDirection <> pJumpDirection then
    if pJumpDirection = "u" then
      sprite(40).flipH = 1
      sprite(40).flipV = 0
    else
      sprite(40).flipH = 0
      sprite(40).flipV = 1
    end if
  end if
  pJumpLastDirection = pJumpDirection
  sprite(40).loc = pMyLoc
  sprite(40).locZ = myLocZ
  if the frameLabel contains "pool_b" and pPlayerMode and pScreenUpOrDown = #up then
    sprite(40).loc = point(660, 72)
    sprite(40).locZ = 33000
    if voidp(gpelleBgImg) then
      sprite(40).locH = 1000
    end if
    gpelleBgImg.fill(rect(0, 0, 108, 102), rgb(157, 206, 255))
    h = PelleImg.height - 4
    w = PelleImg.width - 6
    BgsourceRect = gpelleBgImg.rect + rect(pMyLoc.locH - w, pMyLoc.locV - h, pMyLoc.locH - w, pMyLoc.locV - h)
    pBgScreenBuffer.copyPixels(member(getmemnum("pomppulauta_4")).image, rect(393, 131, 523, 199), member(getmemnum("pomppulauta_4")).rect, [#maskImage: member(getmemnum("pomppulauta_4")).image.createMatte(), #ink: 8])
    gpelleBgImg.copyPixels(pBgScreenBuffer, rect(0, 0, 108, 102), BgsourceRect)
  end if
end

on jumpBoardCollisionD me, xx
  return pStartloc.locV + integer((pStartloc.locH - xx) / 2)
end

on MykeyDown me, PelleKey
  if pStatus = #Run then
    case PelleKey of
      "a", "d":
        if PelleKey <> plastPressKey then
          jumpAction = "run"
          pSpeed = pSpeed + 0.59999999999999998
          if pSpeed > 4 then
            pSpeed = 4
          end if
          pJumpData = pJumpData & PelleKey
        else
          pJumpData = pJumpData & "0"
        end if
      " ":
        if pStatus <> #jump then
          ppJumpMode = #inactive
          pJumpLoop = 1
          jumpAction = "jmp"
          jumpAnimFrame = 1
          pStatus = #jump
          pJumpSpeed = 0
          if pMyLoc.locH < pjumpBoardStart and pMyLoc.locH > pjumpBoardEnd then
            pJumpSpeed = (pjumpBoardStart - pMyLoc.locH) / 22 * pSpeed
          end if
          pJumpSpeed = pJumpSpeed + 5
          pJumpDirection = "u"
        end if
        if pSpeed < 1 then
          pSpeed = pSpeed + 0.5
        end if
        pJumpData = pJumpData & PelleKey
      otherwise:
        pSpeed = pSpeed - 0.20000000000000001
        if pSpeed < 0 then
          pSpeed = 0
        end if
        pJumpData = pJumpData & "0"
    end case
  else
    if pStatus = #jump then
      hyppyKesken = 0
      if pJumpLoop = 0 and PelleKey <> jumpAction.char[3] then
        if jumpAction <> "jun" and jumpAction <> "jdn" then
          hyppyKesken = 1
        end if
      end if
      if hyppyKesken = 0 then
        case PelleKey of
          "w":
            if jumpAction <> "j" & pJumpDirection & "w" then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "w"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpMaxAnimFrames = 1
            pJumpData = pJumpData & PelleKey
          "a":
            if jumpAction <> "j" & pJumpDirection & "a" then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "a"
            pJumpLoop = 1
            pJumpMode = #Active
            if pJumpDirection = "u" then
              pJumpMaxAnimFrames = 4
            else
              pJumpMaxAnimFrames = 7
            end if
            pJumpData = pJumpData & PelleKey
          "d":
            if jumpAction <> "j" & pJumpDirection & "d" then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "d"
            pJumpLoop = 1
            pJumpMode = #Active
            if pJumpDirection = "u" then
              pJumpMaxAnimFrames = 6
            else
              pJumpMaxAnimFrames = 5
            end if
            pJumpData = pJumpData & PelleKey
          "e":
            if jumpAction <> "j" & pJumpDirection & "e" then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "e"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpMaxAnimFrames = 1
            pJumpData = pJumpData & PelleKey
          "z":
            if jumpAction <> "j" & pJumpDirection & "z" then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "z"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpMaxAnimFrames = 1
            pJumpData = pJumpData & PelleKey
          "x":
            if jumpAction <> "j" & pJumpDirection & "x" then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "x"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpMaxAnimFrames = 1
            pJumpData = pJumpData & PelleKey
          "s":
            if pMyLoc.locH > pjumpBoardEnd then
              pJumpDirection = "u"
            else
              if jumpAction <> "j" & pJumpDirection & "s" then
                jumpAnimFrame = 0
              else
              end if
              jumpAction = "j" & pJumpDirection & "s"
              pJumpLoop = 0
              pJumpMode = #Active
              pJumpMaxAnimFrames = 3
            end if
            pJumpData = pJumpData & PelleKey
          otherwise:
            pJumpData = pJumpData & "0"
        end case
      else
        pJumpData = pJumpData & PelleKey
      end if
    end if
  end if
  plastPressKey = PelleKey
  JumpingExitFrame(me)
end

on NotKeyDown me
  if the milliSeconds > pRemoveJumperTime + 45000 then
    if pMyLoc.locH > pjumpBoardEnd then
      pStatus = #Run
      jumpAction = "run"
      pSpeed = 2
    end if
    if voidp(pJumpData) = 0 then
      if pJumpData.char[length(pJumpData)] = "a" then
        presskey = "d"
      else
        presskey = "a"
      end if
      MykeyDown(me, presskey)
    else
      pJumpData = pJumpData & "a"
    end if
  else
    pJumpData = pJumpData & "0"
    pJumpMode = #inactive
    JumpingExitFrame(me)
  end if
end
