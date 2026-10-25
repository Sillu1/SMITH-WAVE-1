--[[
    KUKIRIN LIFE — Trick Farm Hub v4 (fast landing profile)
    game: [🎃] Kukirin Life [Testing] (place 122840796290491)
    executor: Potassium (Luau), client-side
]]

-- ═══════════════════ KEY GATE (smith) ═══════════════════
local GATE = {
    getKey = "https://direct-link.net/8170810/ebh4JhemtK3j",   -- where users GET a key
    url    = "https://raw.githubusercontent.com/Sillu1/SMITH-WAVE-1/main/keys.txt",
    salt   = "SMITH_KUKIRIN_v1",
    owner  = "80bc38f935bec368e49b1c8762932a1092bac8903e578f827a0e63cc3dd33f7ae1be7acec815765dfa0bb550a4d9e24228a493b45da6ef4601e321eb04faf057",
    file   = "smith_key.txt",
    claim  = "",   -- optional worker /claim endpoint for one-use key binding
}

local function gateHttpGet(url)
    for attempt = 1, 3 do
        local okH, res = pcall(function()
            return (http_request or request)({ Url = url, Method = "GET" })
        end)
        if okH and res and res.Success then return res.Body end
        if attempt < 3 then task.wait(0.4) end
    end
    return nil
end

local function gateLicense()
    local okH, lic = pcall(function()
        return crypt.hash(gethwid() .. GATE.salt, "sha256")
    end)
    return (okH and lic) or tostring(gethwid()):sub(1, 32)
end

local function gateFetchUserKey()
    local saved = ""
    pcall(function()
        if isfile and isfile(GATE.file) then saved = readfile(GATE.file) end
    end)
    return saved
end

-- accepts BOTH: hwid licenses (never expire) and linkvertise wave keys
-- wave keys = listed line + "-" + TODAY'S UTC stamp, e.g. SMITH-WAVE-1-251026
local function gateListCheck(key)
    local selfLicensed = (key == gateLicense())
    if GATE.url == "" and GATE.claim == "" then
        return selfLicensed
    end
    local body = gateHttpGet(GATE.url)
    if not body then return false, "keylist unreachable" end
    local stamp = os.date("!%d%m%y")        -- UTC: DDMMYY (e.g. 251026)
    local dayLen = #stamp
    local found = false
    local expired = false
    for line in string.gmatch(body, "[^\r\n]+") do
        local l = line:gsub("^%s+", ""):gsub("%s+$", "")
        if #l >= 40 then
            if l == key then found = true end
        else
            if l == key then
                expired = true
            elseif #key == #l + 1 + dayLen and key:sub(1, #l) == l
               and key:sub(#l + 1, #l + 1) == "-" and key:sub(#l + 2) == stamp then
                found = true
            elseif #key > #l + 1 and key:sub(1, #l) == l
               and key:sub(#l + 1, #l + 1) == "-" then
                expired = true
            end
        end
    end
    if not found and GATE.url ~= "" then
        return false, (expired and "key expired - get today's key" or "not whitelisted")
    end
    if GATE.claim and GATE.claim ~= "" then
        local okC, okVal = pcall(function()
            return (http_request or request)({ Url = GATE.claim .. "?key=" .. key .. "&hwid=" .. gethwid(), Method = "GET" })
        end)
        if not okC or not okVal or not okVal.Success then
            return false, "key check failed (server)"
        end
        if not okVal.Body:find("CLAIMED->" .. gethwid():sub(1, 8)) then
            return false, "key already used on another pc"
        end
    end
    return true
end

local gatePassed = false
local gateWin    = nil

local function gateShowPrompt()
    local lpg = game:GetService("Players").LocalPlayer
    pcall(function()
        local hubParent0 = (gethui and gethui()) or game:GetService("CoreGui")
        local old = hubParent0:FindFirstChild("SMITH_KeyGate")
        if old then old:Destroy() end
    end)
    local gg = Instance.new("ScreenGui")
    gg.Name = "SMITH_KeyGate"
    gg.ResetOnSpawn = false
    gg.IgnoreGuiInset = true
    gg.DisplayOrder = 10000
    local hubParent = (gethui and gethui()) or game:GetService("CoreGui")
    if not hubParent then hubParent = lpg:WaitForChild("PlayerGui") end
    gg.Parent = hubParent

    local root = Instance.new("Frame", gg)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.Size = UDim2.fromOffset(360, 220)
    root.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    local rc = Instance.new("UICorner", root)
    rc.CornerRadius = UDim.new(0, 14)
    local rs = Instance.new("UIStroke", root)
    rs.Color = Color3.fromRGB(140, 110, 250)
    rs.Thickness = 1

    local title = Instance.new("TextLabel", root)
    title.Text = "KEY REQUIRED"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(232, 234, 242)
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(0, 18)
    title.Size = UDim2.new(1, 0, 0, 24)

    local sub = Instance.new("TextLabel", root)
    sub.Text = "paste the key you were given"
    sub.Font = Enum.Font.GothamSemibold
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(130, 138, 160)
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 44)
    sub.Size = UDim2.new(1, 0, 0, 16)

    local box = Instance.new("TextBox", root)
    box.PlaceholderText = "key"
    box.Text = ""
    box.Font = Enum.Font.GothamSemibold
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(232, 234, 242)
    box.BackgroundColor3 = Color3.fromRGB(23, 26, 34)
    box.Position = UDim2.fromOffset(24, 74)
    box.Size = UDim2.new(1, -48, 0, 34)
    local bxc = Instance.new("UICorner", box)
    bxc.CornerRadius = UDim.new(0, 8)
    local bxs = Instance.new("UIStroke", box)
    bxs.Color = Color3.fromRGB(45, 50, 65)
    bxs.Thickness = 1

    local msg = Instance.new("TextLabel", root)
    msg.Text = ""
    msg.Font = Enum.Font.GothamSemibold
    msg.TextSize = 11
    msg.TextColor3 = Color3.fromRGB(255, 120, 120)
    msg.BackgroundTransparency = 1
    msg.Position = UDim2.fromOffset(0, 166)
    msg.Size = UDim2.new(1, 0, 0, 14)

    local verifyBtn = Instance.new("TextButton", root)
    verifyBtn.Text = "VERIFY"
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 14
    verifyBtn.TextColor3 = Color3.fromRGB(16, 18, 24)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(140, 110, 250)
    verifyBtn.Position = UDim2.fromOffset(24, 118)
    verifyBtn.Size = UDim2.new(1, -48, 0, 30)
    local vbc = Instance.new("UICorner", verifyBtn)
    vbc.CornerRadius = UDim.new(0, 8)

    local hwidBtn = Instance.new("TextButton", root)
    hwidBtn.Text = "copy my HWID"
    hwidBtn.Font = Enum.Font.GothamSemibold
    hwidBtn.TextSize = 11
    hwidBtn.TextColor3 = Color3.fromRGB(130, 138, 160)
    hwidBtn.BackgroundColor3 = Color3.fromRGB(23, 26, 34)
    hwidBtn.AnchorPoint = Vector2.new(0, 1)
    hwidBtn.Position = UDim2.fromOffset(24, -12)
    hwidBtn.Size = UDim2.new(0, 120, 0, 20)
    local hbc = Instance.new("UICorner", hwidBtn)
    hbc.CornerRadius = UDim.new(0, 6)

    local function fail(why)
        msg.Text = why or "invalid key"
    end

    verifyBtn.MouseButton1Click:Connect(function()
        msg.Text = ""
        local typed = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if typed == "" then
            fail("paste a key")
            return
        end
        local okList, why = gateListCheck(typed)
        if not okList then
            fail(why == "keylist unreachable" and "couldn't reach keylist - try again" or (why or "not whitelisted"))
            return
        end
        gatePassed = true
        gg:Destroy()
    end)

    localgetKey = Instance.new("TextButton", root)
    localgetKey.Text = "GET A KEY"
    localgetKey.Font = Enum.Font.GothamBold
    localgetKey.TextSize = 11
    localgetKey.TextColor3 = Color3.fromRGB(0, 214, 143)
    localgetKey.BackgroundColor3 = Color3.fromRGB(23, 26, 34)
    localgetKey.AnchorPoint = Vector2.new(0, 1)
    localgetKey.Position = UDim2.new(1, -132, 0, -12)
    localgetKey.Size = UDim2.new(0, 110, 0, 20)
    local gkc = Instance.new("UICorner", localgetKey)
    gkc.CornerRadius = UDim.new(0, 6)
    localgetKey.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(GATE.getKey) end)
        msg.Text = "get-key link copied - open it in your browser"
        msg.TextColor3 = Color3.fromRGB(0, 214, 143)
    end)

    hwidBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(gethwid()) end)
        msg.Text = "HWID copied - send it to the seller"
        msg.TextColor3 = Color3.fromRGB(130, 138, 160)
    end)

    gateWin = gg

    task.spawn(function()
        root.BackgroundTransparency = 1
        game:GetService("TweenService"):Create(root, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
    end)
end

-- verdict chain: owner bypass is DISABLED — every PC needs today's key
do
    if false then
        gatePassed = true
    else
        gateShowPrompt()
    end
end

while not gatePassed do
    task.wait(0.1)
end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer

getgenv().__SMITH_TRICKFARM = getgenv().__SMITH_TRICKFARM or {}
local State = getgenv().__SMITH_TRICKFARM

_G.__SMITH_KILL = false
if State.conns then for _, c in ipairs(State.conns) do c:Disconnect() end end
if State.heartbeat then State.heartbeat:Disconnect() end
State.conns = {}
State.farmEnabled = false
State.trickCount  = 0
State.sessionCash = 0
State.cashAtStart = lp:GetAttribute("Cash") or 0

local Rides     = ReplicatedStorage.Remotes.Rides
local TrickLens = ReplicatedStorage.Remotes.Tricks.TrickState
local RideName  = "ScooterG2Master"

local MODES = {
    { name = "Quad Spin",    sub = "+$300  ~1.3s", spin = "yaw",   rate = 3600, rot = 3060 },
    { name = "Turbo Spin",   sub = "+$300  ~1.0s", spin = "yaw",   rate = 3600, rot = 2160 },
    { name = "Backflip x2",  sub = "+$100  ~1.0s", spin = "pitch", rate = 1200, rot = 720  },
}
local cfg = MODES[1]

local spinActive  = false
local spinAxisYaw = true
local spinRateDeg = 0
local spinRotTotal = 0
local spinTarget  = 0
local hoverPinned = false
local descending  = false

State.heartbeat = RunService.Heartbeat:Connect(function(dt)
    if _G.__SMITH_KILL then
        pcall(function() State.heartbeat:Disconnect() end)
        pcall(function()
            for _, cn in ipairs(State.conns or {}) do pcall(function() cn:Disconnect() end) end
        end)
        pcall(function()
            local huic = gethui and gethui() or game:GetService("CoreGui")
            local s = huic and huic["SMITH_KukirinTrickFarm"]
            if s then s:Destroy() end
            local g = huic and huic["SMITH_KeyGate"]
            if g then g:Destroy() end
        end)
        return
    end
    local ridesFolder = workspace:FindFirstChild("Rides")
    if not ridesFolder then return end
    local ride = ridesFolder:FindFirstChild("Ride_" .. lp.Name)
    if not ride then return end
    local body = ride:FindFirstChild("Body")
    if not body then return end
    local root = body:FindFirstChild("#Weight")
    if not root then return end

    if spinActive then
        local angle = math.rad(spinRateDeg * dt)
        spinRotTotal = spinRotTotal + spinRateDeg * dt
        local rot = spinAxisYaw and CFrame.Angles(0, angle, 0) or CFrame.Angles(angle, 0, 0)
        root.CFrame = root.CFrame * rot
        if spinRotTotal >= spinTarget then
            spinActive = false
            if not spinAxisYaw then
                local yaw = math.atan2(-root.CFrame.LookVector.X, -root.CFrame.LookVector.Z)
                root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
            end
            root.AssemblyLinearVelocity = Vector3.new(0, -60, 0)
            hoverPinned = false
            descending = true
        end
    end

    if hoverPinned then
        local v = root.AssemblyLinearVelocity
        if v.Y < 3 and v.Y > -60 then root.AssemblyLinearVelocity = Vector3.new(0, 5, 0) end
        if root.Position.Y < 6 then root.AssemblyLinearVelocity = Vector3.new(0, 20, 0) end
    elseif descending then
        local v = root.AssemblyLinearVelocity
        if v.Y < -60 then root.AssemblyLinearVelocity = Vector3.new(0, -60, 0) end
    end
end)

local function getRideRoot()
    local ridesFolder = workspace:FindFirstChild("Rides")
    if not ridesFolder then return nil, nil end
    local ride = ridesFolder:FindFirstChild("Ride_" .. lp.Name)
    if not ride then return nil, nil end
    local body = ride:FindFirstChild("Body")
    if not body then return nil, nil end
    return body:FindFirstChild("#Weight"), ride
end

local function ensureSeated()
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.SeatPart then return true end
    local _, ride = getRideRoot()
    if not ride then
        pcall(function() Rides.SpawnRide:InvokeServer(RideName) end)
        task.wait(1.0)
        _, ride = getRideRoot()
        if not ride then return false end
    end
    local seat = ride:FindFirstChild("DriveSeat")
    if not seat then return false end
    local prompt = seat:FindFirstChild("EnterPrompt")
    if prompt and seat:IsA("VehicleSeat") then
        pcall(function() seat:Sit(hum) end)
        task.wait(0.4)
    end
    if not hum.SeatPart and seat:IsA("VehicleSeat") then
        pcall(function() seat:Sit(hum) end)
        task.wait(0.5)
    end
    if not hum.SeatPart and prompt then pcall(function() fireproximityprompt(prompt) end) end
    task.wait(0.8)
    return hum.SeatPart ~= nil
end

local function doFlip()
    local root = getRideRoot()
    if not root then
        if not ensureSeated() then return end
        root = getRideRoot()
        if not root then return end
    end

    spinAxisYaw  = cfg.spin == "yaw"
    spinRateDeg  = cfg.rate
    spinTarget   = cfg.rot
    spinRotTotal = 0
    spinActive   = true
    hoverPinned  = true
    descending   = false

    root.AssemblyLinearVelocity = Vector3.new(0, 90, 0)

    local t = 0
    while t < 2.5 do
        task.wait(0.02)
        t = t + 0.02
        if not spinActive then break end
    end

    local t2 = 0
    while t2 < 2.0 do
        task.wait(0.016)
        t2 = t2 + 0.016
        local v = root.AssemblyLinearVelocity
        if math.abs(v.Y) < 1.2 then
            local yaw = math.atan2(-root.CFrame.LookVector.X, -root.CFrame.LookVector.Z)
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            break
        end
    end
    descending = false
    task.wait(0.08)
end

local function farmLoop()
    while State.farmEnabled and not _G.__SMITH_KILL do
        local ok, err = pcall(doFlip)
        if not ok then warn("flip err:", err) end
        task.wait(0.05)
    end
end

local Themes = {
    bg     = Color3.fromRGB(16, 18, 24),
    panel  = Color3.fromRGB(23, 26, 34),
    stroke = Color3.fromRGB(45, 50, 65),
    accent = Color3.fromRGB(140, 110, 250),
    green  = Color3.fromRGB(0, 214, 143),
    text   = Color3.fromRGB(232, 234, 242),
    dim    = Color3.fromRGB(130, 138, 160),
}
local FONT = Enum.Font.GothamSemibold

local sg = Instance.new("ScreenGui")
sg.Name = "SMITH_KukirinTrickFarm"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 9999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local hubHub = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if not hubHub then hubHub = lp:WaitForChild("PlayerGui") end
sg.Parent = hubHub

local win = Instance.new("Frame")
win.Size = UDim2.fromOffset(340, 430)
win.Position = UDim2.fromOffset(20, 120)
win.BackgroundColor3 = Themes.bg
win.BorderSizePixel = 0
win.Parent = sg
local wcorner = Instance.new("UICorner", win) ; wcorner.CornerRadius = UDim.new(0, 14)
local wstroke = Instance.new("UIStroke", win)
wstroke.Color = Themes.accent ; wstroke.Thickness = 1 ; wstroke.Transparency = 0.35

local title = Instance.new("TextLabel", win)
title.Text = "KUKIRIN LIFE — TRICK FARM"
title.Font = FONT ; title.TextSize = 16
title.TextColor3 = Themes.text ; title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18, 14)
title.Size = UDim2.new(1, -80, 0, 22)
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", win)
subtitle.Text = "SMITH · fast-landing profile"
subtitle.Font = FONT ; subtitle.TextSize = 11
subtitle.TextColor3 = Themes.dim ; subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(18, 34)
subtitle.Size = UDim2.new(1, -36, 0, 16)
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local mini = Instance.new("TextButton", win)
mini.Text = "_" ; mini.Font = FONT ; mini.TextSize = 17
mini.TextColor3 = Themes.text ; mini.BackgroundColor3 = Themes.panel
mini.Size = UDim2.fromOffset(22, 22)
mini.AnchorPoint = Vector2.new(1, 0)
mini.Position = UDim2.new(1, -10, 0, 10)
local mcorner = Instance.new("UICorner", mini) ; mcorner.CornerRadius = UDim.new(0, 6)

local bubble = Instance.new("TextButton", sg)
bubble.Text = "T" ; bubble.Font = FONT ; bubble.TextSize = 13
bubble.TextColor3 = Themes.text ; bubble.BackgroundColor3 = Themes.panel
bubble.Size = UDim2.fromOffset(48, 48)
bubble.Position = UDim2.fromOffset(24, 180)
bubble.Visible = false
local bcorner = Instance.new("UICorner", bubble) ; bcorner.CornerRadius = UDim.new(1, 0)
local bstroke = Instance.new("UIStroke", bubble)
bstroke.Color = Themes.accent ; bstroke.Thickness = 1
mini.MouseButton1Click:Connect(function() win.Visible = false ; bubble.Visible = true end)
bubble.MouseButton1Click:Connect(function() win.Visible = true ; bubble.Visible = false end)

local closeBtn = Instance.new("TextButton", win)
closeBtn.Text = "✕"
closeBtn.Font = FONT
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
closeBtn.BackgroundColor3 = Themes.panel
closeBtn.Size = UDim2.fromOffset(22, 22)
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -36, 0, 10)
local ccor = Instance.new("UICorner", closeBtn)
ccor.CornerRadius = UDim.new(0, 6)
local cst = Instance.new("UIStroke", closeBtn)
cst.Color = Color3.fromRGB(200, 70, 70)
cst.Thickness = 1
cst.Transparency = 0.5

closeBtn.MouseButton1Click:Connect(function()
    _G.__SMITH_KILL = true
    pcall(function() if State.heartbeat then State.heartbeat:Disconnect() end end)
    pcall(function()
        for _, c in ipairs(State.conns or {}) do pcall(function() c:Disconnect() end) end
    end)
    State.farmEnabled = false
    spinActive, hoverPinned, descending = false, false, false
    _G.__previouslyBooted = nil
    if getgenv then
        getgenv().__SMITH_HUB_READY = nil
        getgenv().__SMITH_TRICKFARM = nil
    end
    local huic = gethui and gethui() or game:GetService("CoreGui")
    pcall(function()
        for _, other in ipairs(huic:GetChildren()) do
            if other.Name == "SMITH_KukirinTrickFarm" or other.Name == "SMITH_KeyGate" then other:Destroy() end
        end
    end)
    pcall(function()
        local pg = lp:FindFirstChild("PlayerGui")
        if pg then
            for _, other in ipairs(pg:GetChildren()) do
                if other.Name == "SMITH_KukirinTrickFarm" or other.Name == "SMITH_KeyGate" then other:Destroy() end
            end
        end
    end)
    pcall(function() sg:Destroy() end)
    print("[SMITH] hub closed fully")
end)

local toastLayer = Instance.new("Frame", sg)
toastLayer.AnchorPoint = Vector2.new(1, 0)
toastLayer.Position = UDim2.new(1, -20, 0, 90)
toastLayer.Size = UDim2.fromOffset(260, 200)
toastLayer.BackgroundTransparency = 1
toastLayer.ZIndex = 100

local function toast(msg)
    local frame = Instance.new("Frame", toastLayer)
    frame.ZIndex = 101
    frame.BackgroundColor3 = Themes.panel
    frame.Size = UDim2.new(1, 0, 0, 24)
    local c = Instance.new("UICorner", frame) ; c.CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", frame)
    st.Color = Themes.green ; st.Thickness = 1 ; st.Transparency = 0.3
    local lbl = Instance.new("TextLabel", frame)
    lbl.ZIndex = 102
    lbl.Font = FONT ; lbl.TextSize = 13 ; lbl.Text = msg
    lbl.TextColor3 = Themes.text ; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -12, 1, 0) ; lbl.Position = UDim2.fromOffset(8, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local count = 0
    for _, f in ipairs(toastLayer:GetChildren()) do
        if f:IsA("Frame") and f ~= frame and f.Visible then count = count + 1 end
    end
    local target = UDim2.new(0, 0, 0, count * 28)
    frame.Position = target + UDim2.new(1, 300, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = target }):Play()
    task.spawn(function()
        task.wait(1.1)
        TweenService:Create(lbl, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
        TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
        task.wait(0.25) ; frame:Destroy()
    end)
end

local modeButtons = {}
for i, m in ipairs(MODES) do
    local btn = Instance.new("TextButton", win)
    btn.Font = FONT ; btn.TextSize = 13
    btn.Text = m.name .. "   " .. m.sub
    btn.TextColor3 = Themes.text
    btn.BackgroundColor3 = Themes.panel
    btn.Size = UDim2.new(1, -36, 0, 34)
    btn.Position = UDim2.fromOffset(18, 64 + (i - 1) * 44)
    local bc = Instance.new("UICorner", btn) ; bc.CornerRadius = UDim.new(0, 10)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = Themes.stroke ; bs.Thickness = 1
    btn.MouseButton1Click:Connect(function()
        cfg = m
        for _, obtn2 in ipairs(modeButtons) do
            obtn2.BackgroundColor3 = Themes.panel
            obtn2.UIStroke.Color = Themes.stroke
        end
        btn.BackgroundColor3 = Themes.accent
        btn.UIStroke.Color = Themes.accent
        toast("Mode: " .. m.name)
    end)
    modeButtons[i] = btn
end
modeButtons[1].BackgroundColor3 = Themes.accent
modeButtons[1].UIStroke.Color = Themes.accent

local toggleContainer = Instance.new("Frame", win)
toggleContainer.Size = UDim2.new(1, -36, 0, 44)
toggleContainer.Position = UDim2.fromOffset(18, 64 + #MODES * 44 + 12)
toggleContainer.BackgroundColor3 = Themes.panel
local tc2 = Instance.new("UICorner", toggleContainer) ; tc2.CornerRadius = UDim.new(0, 10)
local tlab = Instance.new("TextLabel", toggleContainer)
tlab.Text = "AUTO FARM   [Z]"
tlab.Font = FONT ; tlab.TextSize = 13 ; tlab.TextColor3 = Themes.text
tlab.BackgroundTransparency = 1
tlab.Position = UDim2.fromOffset(12, 0) ; tlab.Size = UDim2.new(0.6, 0, 1, 0)
tlab.TextXAlignment = Enum.TextXAlignment.Left

local farmBtn = Instance.new("TextButton", toggleContainer)
farmBtn.Text = "OFF"
farmBtn.Font = FONT ; farmBtn.TextSize = 12 ; farmBtn.TextColor3 = Themes.dim
farmBtn.BackgroundColor3 = Themes.bg
farmBtn.Size = UDim2.fromOffset(64, 28)
farmBtn.AnchorPoint = Vector2.new(1, 0.5)
farmBtn.Position = UDim2.new(1, -10, 0.5, 0)
local fc2 = Instance.new("UICorner", farmBtn) ; fc2.CornerRadius = UDim.new(0, 8)
local fs2 = Instance.new("UIStroke", farmBtn)
fs2.Color = Themes.stroke ; fs2.Thickness = 1

local function setFarmVisual(on)
    farmBtn.Text = on and "ON" or "OFF"
    farmBtn.TextColor3 = on and Themes.green or Themes.dim
    fs2.Color = on and Themes.green or Themes.stroke
end

local function toggleFarm()
    State.farmEnabled = not State.farmEnabled
    setFarmVisual(State.farmEnabled)
    if State.farmEnabled then
        toast("Farm ON — " .. cfg.name)
        task.spawn(farmLoop)
    else
        spinActive, hoverPinned, descending = false, false, false
        toast("Farm OFF")
    end
end
farmBtn.MouseButton1Click:Connect(toggleFarm)

local statsHolder = Instance.new("Frame", win)
statsHolder.Size = UDim2.new(1, -36, 0, 60)
statsHolder.Position = UDim2.new(0, 18, 1, -78)
statsHolder.BackgroundColor3 = Themes.panel
local sc2 = Instance.new("UICorner", statsHolder) ; sc2.CornerRadius = UDim.new(0, 10)

local cashLabel = Instance.new("TextLabel", statsHolder)
cashLabel.Font = FONT ; cashLabel.TextSize = 13 ; cashLabel.TextColor3 = Themes.text
cashLabel.BackgroundTransparency = 1
cashLabel.Position = UDim2.fromOffset(10, 6) ; cashLabel.Size = UDim2.new(0.5, -6, 0.5, 0)
cashLabel.TextXAlignment = Enum.TextXAlignment.Left

local trLabel = Instance.new("TextLabel", statsHolder)
trLabel.Font = FONT ; trLabel.TextSize = 13 ; trLabel.TextColor3 = Themes.text
trLabel.BackgroundTransparency = 1
trLabel.Position = UDim2.fromOffset(10, 34) ; trLabel.Size = UDim2.new(0.5, -6, 0.5, 0)
trLabel.TextXAlignment = Enum.TextXAlignment.Left

local sessionLabel = Instance.new("TextLabel", statsHolder)
sessionLabel.Font = FONT ; sessionLabel.TextSize = 16
sessionLabel.TextColor3 = Themes.green
sessionLabel.BackgroundTransparency = 1
sessionLabel.Position = UDim2.new(0.5, 4, 0, 0)
sessionLabel.Size = UDim2.new(0.5, -8, 1, 0)
sessionLabel.TextXAlignment = Enum.TextXAlignment.Right

local hint = Instance.new("TextLabel", win)
hint.Text = "X — hide ui"
hint.Font = FONT ; hint.TextSize = 11 ; hint.TextColor3 = Themes.dim
hint.BackgroundTransparency = 1
hint.Position = UDim2.new(0, 18, 1, -96)
hint.Size = UDim2.new(1, -36, 0, 14)
hint.TextXAlignment = Enum.TextXAlignment.Left

local function refreshStats()
    cashLabel.Text  = "CASH   $" .. (lp:GetAttribute("Cash") or 0)
    trLabel.Text    = "TRICKS " .. State.trickCount
    sessionLabel.Text = "+$" .. State.sessionCash
end

State.conns[#State.conns+1] = TrickLens.OnClientEvent:Connect(function(state, name, amount)
    if state == "landed" and typeof(amount) == "number" then
        State.trickCount += 1
        toast(("+%s  %s"):format("$" .. tostring(amount), tostring(name)))
        refreshStats()
    elseif state == "failed" then
        toast("Failed: " .. tostring(name))
    end
end)

State.conns[#State.conns+1] = lp:GetAttributeChangedSignal("Cash"):Connect(function()
    State.sessionCash = (lp:GetAttribute("Cash") or 0) - State.cashAtStart
    refreshStats()
end)

State.conns[#State.conns+1] = UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Z then toggleFarm() end
    if input.KeyCode == Enum.KeyCode.X then sg.Enabled = not sg.Enabled end
end)

do
    local dragging, dragStart, startPos = false, nil, nil
    local bindable = { title, subtitle }
    local function bind(node)
        node.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, win.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        node.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                win.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    for _, n in ipairs(bindable) do bind(n) end
end

State.autoBoot = true
refreshStats()

if _G.__previouslyBooted then
    task.delay(0.4, function() toggleFarm() end)
end
_G.__previouslyBooted = true

getgenv().__SMITH_HUB_READY = true
print(("[SMITH] Kukirin TrickFarm v4c loaded · cash=%s · mode=%s (fast landing)"):format(
    tostring(lp:GetAttribute("Cash")), cfg.name))
