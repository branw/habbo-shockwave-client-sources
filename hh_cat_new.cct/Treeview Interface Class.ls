property pData, pimage, pwidth, pheight, pClickAreas

on construct me
  pData = VOID
  pimage = VOID
  pwidth = 0
  pheight = 0
  pClickAreas = []
end

on deconstruct me
  pData = VOID
end

on feedData me, tdata
  pData = tdata
  pData.getRootNode().setState(#open)
end

on define me, tProps
  pwidth = tProps[#width]
  pheight = tProps[#height]
  pClickAreas = []
end

on getImage me
  if voidp(pimage) then
    me.render()
  end if
  return pimage
end

on appendRenderToImage me, tImageDest, tImageSrc, tRectDest, tRectSrc
  if tImageDest.height > tRectDest.bottom then
    tImageDest.copyPixels(tImageSrc, tRectDest, tRectSrc, [#useFastQuads: 1])
    return tImageDest
  else
    tImageNew = image(tImageDest.width, tRectDest.bottom, tImageDest.depth)
    tImageNew.copyPixels(tImageDest, tImageDest.rect, tImageDest.rect, [#useFastQuads: 1])
    tImageNew.copyPixels(tImageSrc, tRectDest, tRectSrc, [#useFastQuads: 1])
    return tImageNew
  end if
end

on renderNode me, tNode, tOffsetY
  if not (tNode = pData.getRootNode()) and not tNode.getData(#navigateable) then
    return tOffsetY
  end if
  if tNode.getData(#navigateable) then
    tNodeImage = tNode.getImage()
    me.pimage = me.appendRenderToImage(me.pimage, tNodeImage, tNodeImage.rect + rect(0, tOffsetY, 0, tOffsetY), tNodeImage.rect)
    pClickAreas.add([#min: tOffsetY, #max: tOffsetY + tNodeImage.height, #data: tNode])
    tOffsetY = tOffsetY + tNodeImage.height
  end if
  if tNode.getState() = #open and tNode.getChildren().count > 0 then
    repeat with tChild in tNode.getChildren()
      tOffsetY = me.renderNode(tChild, tOffsetY)
    end repeat
  end if
  return tOffsetY
end

on render me
  pimage = image(pwidth, pheight, 32)
  pClickAreas = []
  tOffsetY = 0
  me.renderNode(pData.getRootNode(), tOffsetY)
end

on selectNode me, tNode, tSelectedNode
  if tNode = tSelectedNode then
    tNode.select(1)
  else
    tNode.select(0)
  end if
  repeat with tChild in tNode.getChildren()
    me.selectNode(tChild, tSelectedNode)
  end repeat
end

on select me, tNodeObj
  me.selectNode(pData.getRootNode(), tNodeObj)
end

on simulateClickByName me, tNodeName
  if ilk(pClickAreas) <> #list then
    return 0
  end if
  tClickLoc = point(2, 0)
  repeat with i = 1 to pClickAreas.count
    if ilk(pClickAreas[i]) = #propList then
      if objectp(pClickAreas[i][#data]) then
        if pClickAreas[i][#data].getData(#nodename) = tNodeName then
          tClickLoc.locV = pClickAreas[i][#min] + 1
          exit repeat
        end if
      end if
    end if
  end repeat
  me.handleClick(tClickLoc)
end

on handleClick me, tloc
  if ilk(tloc) <> #point then
    return 
  end if
  tNode = VOID
  repeat with i = 1 to pClickAreas.count
    if pClickAreas[i][#min] < tloc.locV and pClickAreas[i][#max] > tloc.locV then
      tNode = pClickAreas[i][#data]
      exit repeat
    end if
  end repeat
  if voidp(tNode) then
    return 0
  end if
  if tNode.getChildren().count > 0 then
    if tNode.getState() = #open then
      tNode.setState(#closed)
    else
      tNode.setState(#open)
    end if
  end if
  if tNode.getData(#level) <= 1 then
    pData.getRootNode().setState(#open)
    repeat with tChild in pData.getRootNode().getChildren()
      if tNode <> tChild then
        tChild.setState(#closed)
      end if
    end repeat
  end if
  me.select(tNode)
  me.render()
  if tNode.getData(#pageid) <> -1 then
    pData.handlePageRequest(tNode.getData(#pageid))
  end if
  return 1
end
