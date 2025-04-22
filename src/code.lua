local cellX = 24
local cellY = 24
local gapW = 4
local size = 4
local cursor = size * size
local cursorIndex = size * size
local offsetX = 0
local offsetY = 0
local data = {}
local random = 100
local keyDelay = 0
local keyDelayed = 250
local keyPress = Keys.None
local keyCommands = { Keys.Up, Keys.Down, Keys.Left, Keys.Right, Keys.N, Keys.None }
local won = false

function Init()
  local displaySize = Display()
  offsetX = (displaySize.x - cellX * size - gapW * (size + 1)) / 2
  offsetY = (displaySize.y - cellY * size - gapW * (size + 1)) / 2

  for i = 1, cursor, 1 do
    data[i] = i
  end
end

function KeyMove(keycode)
  StopSound()

  local nextIndex = 0
  if keycode == Keys.Down and cursorIndex > size then
    nextIndex = cursorIndex - size
  elseif keycode == Keys.Up and cursorIndex <= cursor - size then
    nextIndex = cursorIndex + size
  elseif keycode == Keys.Right and cursorIndex%size ~= 1 then
    nextIndex = cursorIndex - 1
  elseif keycode == Keys.Left and cursorIndex%size ~= 0 then
    nextIndex = cursorIndex + 1
  end

  if nextIndex > 0 then
    data[cursorIndex] = data[nextIndex]
    data[nextIndex] = cursor
    cursorIndex = nextIndex
    nextIndex = 0
    if random == 0 then
      PlaySound(0)
    end
  end
end

function Update(timeDelta)
  if Key(Keys.N) then
    random = 100
    return
  end

  if random > 0 then
    local i = math.random(1, 4)
    KeyMove(keyCommands[i])
    random = random - 1
    return
  end

  if keyDelay < keyDelayed then
    keyDelay = keyDelay + timeDelta
    if Key(Keys.Up) and keyPress ~= Keys.Up then
      keyDelay = 0
      keyPress = Keys.Up
    elseif Key(Keys.Down) and keyPress ~= Keys.Down then
      keyDelay = 0
      keyPress = Keys.Down
    elseif Key(Keys.Left) and keyPress ~= Keys.Left then
      keyDelay = 0
      keyPress = Keys.Left
    elseif Key(Keys.Right) and keyPress ~= Keys.Right then
      keyDelay = 0
      keyPress = Keys.Right
    end
  else
    KeyMove(keyPress)
    keyDelay = 0
    keyPress = Keys.None
  end
end

function Draw()
  Clear()

  for i = 1, size, 1 do
    for j = 1, size, 1 do
      local index = (i - 1) * size + j
      DrawRect(offsetX + (cellX + gapW) * (j - 1) + gapW, offsetY + (cellY + gapW) * (i - 1) + gapW, cellX, cellY, 5, DrawMode.Sprite)
      if data[index] < cursor then
        DrawText(data[index], offsetX + (cellX + gapW) * (j - 1) + gapW * 2, offsetY + (cellY + gapW) * (i - 1) + gapW * 2, DrawMode.SpriteAbove, "large", 15)
      end
    end
  end
  DrawRect(offsetX, offsetY, cellX * size + gapW * (size + 1), cellY * size + gapW * (size + 1), 6, DrawMode.SpriteBelow)

  local flag = true
  for i = 1, cursor, 1 do
    if data[i] ~= i then
      flag = false
      break
    end
  end

  if flag and random == 0 then
    DrawText("Success!", 5, 5, DrawMode.SpriteAbove, "large", 15)
    if not won then
      PlaySound(1)
      won = true
    end
  else
    won = false
  end
end
