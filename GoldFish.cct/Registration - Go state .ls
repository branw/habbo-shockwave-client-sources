property stateDiff
global gRegistrationManager

on mouseUp me
  gRegistrationManager.setState(gRegistrationManager.pState + stateDiff)
end

on getPropertyDescriptionList me
  p = [:]
  addProp(p, #stateDiff, [#comment: "Direction", #format: #integer, #range: [-1, 1, 2, 3], #default: 1])
  return p
end
