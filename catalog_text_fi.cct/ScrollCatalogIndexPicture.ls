property sFrame, context
global MyMaxWidth, ButtonWidth, ButtonHeigth, links, activeButton, whichIsFirstNow, MaxVisibleIndexButton, openCatalog

on beginSprite me
  if openCatalog = 1 then
    openCatalog = 0
    oldItemLimiter = the itemDelimiter
    the itemDelimiter = ","
    activeButton = 1
    ButtonWidth = member(member("CatalogPage_index").line[1].item[1] & "_inactive").width
    ButtonHeigth = member(member("CatalogPage_index").line[1].item[1] & "_inactive").height
    Pages = member("CatalogPage_index").line.count
    indexWidth = ButtonWidth * Pages
    myImage = image(indexWidth, ButtonHeigth, 32)
    member("catalogIndexPic").image = myImage
    links = []
    previousEndPoint = point(0, 0)
    repeat with f = 1 to Pages
      if f = 1 then
        Pic = member(member("CatalogPage_index").line[f].item[1] & "_active")
      else
        Pic = member(member("CatalogPage_index").line[f].item[1] & "_inactive")
      end if
      StartPoint = previousEndPoint
      EndPoint = point(Pic.width, Pic.height) + StartPoint
      previousEndPoint = point(EndPoint.locH, 0)
      targetRect = rect(StartPoint, EndPoint)
      sourseRect = Pic.rect
      member("catalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
      links.append(member("CatalogPage_index").line[f].item[2])
    end repeat
    updateStage()
    CropToVisibleArea(me, point(0, 0))
    the itemDelimiter = oldItemLimiter
  end if
end

on ScrollCatalogIndex me, direction
  global whichIsFirstNow, MaxVisibleIndexButton
  scroll = 1
  if direction = "left" then
    repeat while scroll
      scrollTime = the ticks + 25
      repeat with f = (whichIsFirstNow - 1) * ButtonWidth / 7 down to (whichIsFirstNow - 2) * ButtonWidth / 7
        if the ticks > scrollTime then
          exit repeat
        end if
        CropToVisibleArea(me, point(f * 7, 0))
        updateStage()
      end repeat
      if the ticks > scrollTime then
        CropToVisibleArea(me, point((whichIsFirstNow - 2) * ButtonWidth, 0))
      end if
      whichIsFirstNow = whichIsFirstNow - 1
      if the mouseDown = 0 or whichIsFirstNow = 1 then
        scroll = 0
      end if
    end repeat
  else
    repeat while scroll
      scrollTime = the ticks + 25
      repeat with f = (whichIsFirstNow - 1) * ButtonWidth / 7 to whichIsFirstNow * ButtonWidth / 7
        if the ticks > scrollTime then
          exit repeat
        end if
        CropToVisibleArea(me, point(f * 7, 0))
        updateStage()
      end repeat
      if the ticks > scrollTime then
        CropToVisibleArea(me, point(whichIsFirstNow * ButtonWidth, 0))
      end if
      whichIsFirstNow = whichIsFirstNow + 1
      if the mouseDown = 0 or whichIsFirstNow + MaxVisibleIndexButton - 1 = member("CatalogPage_index").line.count then
        scroll = 0
      end if
    end repeat
  end if
end

on CropToVisibleArea me, StartPoint
  StartPoint = StartPoint + point(1, 0)
  MyMaxWidth = sprite(me.spriteNum + 1).left - sprite(me.spriteNum - 1).right
  myImage = image(MyMaxWidth, ButtonHeigth, 32)
  member("CropcatalogIndexPic").image = myImage
  Pic = member("catalogIndexPic")
  targetRect = member("CropcatalogIndexPic").rect
  sourseRect = rect(StartPoint, StartPoint + point(ButtonWidth * (MyMaxWidth / ButtonWidth + 1), ButtonHeigth))
  member("CropcatalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
end

on mouseUp me
  global whichIsFirstNow, MaxVisibleIndexButton
  oldItemLimiter = the itemDelimiter
  the itemDelimiter = ","
  click = (the mouseH - sprite(me.spriteNum).left) / ButtonWidth + whichIsFirstNow
  Pic = member(member("CatalogPage_index").line[activeButton].item[1] & "_inactive")
  aPoint = point(ButtonWidth * (activeButton - 1), 0)
  sourseRect = member(member("CatalogPage_index").line[activeButton].item[1] & "_inactive").rect
  targetRect = rect(aPoint, aPoint + point(ButtonWidth, ButtonHeigth))
  member("catalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
  Pic = member(member("CatalogPage_index").line[click].item[1] & "_active")
  aPoint = point(ButtonWidth * (click - 1), 0)
  sourseRect = member(member("CatalogPage_index").line[click].item[1] & "_active").rect
  targetRect = rect(aPoint, aPoint + point(ButtonWidth, ButtonHeigth))
  member("catalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
  activeButton = click
  CropToVisibleArea(me, point((whichIsFirstNow - 1) * ButtonWidth, 0))
  sFrame = links[click]
  if not voidp(sFrame) then
    goContext(sFrame, context)
  end if
  the itemDelimiter = oldItemLimiter
end
