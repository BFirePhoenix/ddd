-- ⚡ Ultra Deep Dumper v50.0++ (Remotes / Items / Traits / Units)
-- ✨ אוסף כל מידע אפשרי: Remotes, Ids, Names, Traits, Items, Units
-- 🛠️ דורש Exploit עם decompile, writefile, getgenv (למשל Synapse X)

local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")

local dump = {
    Remotes = {},
    Scripts = {},
    Instances = {
        Items = {},
        Units = {},
        Traits = {},
        Others = {}
    }
}

local function safeHash(str)
    local h = 0
    for i = 1,#str do h = (h*33 + str:byte(i)) % 4294967296 end
    return string.format("%08X", h)
end

-- 🧩 פונקציה לאיסוף נתוני אובייקט
local function collectInstance(obj)
    local data = {
        Name = obj.Name,
        Class = obj.ClassName,
        Path = obj:GetFullName(),
        Attributes = obj:GetAttributes()
    }
    for _,prop in ipairs({"Value","Text","ToolTip","Texture","Id","DisplayName"}) do
        local ok,val = pcall(function() return obj[prop] end)
        if ok and val ~= nil and typeof(val) ~= "Instance" then
            data[prop] = tostring(val)
        end
    end
    -- מסווג לקטגוריה
    local lname = obj.Name:lower()
    if lname:find("item") or lname:find("burner") or lname:find("lock") then
        table.insert(dump.Instances.Items, data)
    elseif lname:find("unit") or lname:find("hero") or lname:find("char") then
        table.insert(dump.Instances.Units, data)
    elseif lname:find("trait") or lname:find("potential") then
        table.insert(dump.Instances.Traits, data)
    else
        table.insert(dump.Instances.Others, data)
    end
end

-- 📜 איסוף סקריפטים (דוגמה + hash)
local function collectScript(obj)
    if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        local ok,src = pcall(decompile,obj)
        if ok and type(src)=="string" then
            table.insert(dump.Scripts,{
                Name = obj.Name,
                Class = obj.ClassName,
                Path = obj:GetFullName(),
                Size = #src,
                Hash = safeHash(src),
                Sample = src:sub(1,300)
            })
        end
    end
end

-- 🎯 איסוף Remotes
local function collectRemote(obj)
    table.insert(dump.Remotes,{
        Name = obj.Name,
        Class = obj.ClassName,
        Path = obj:GetFullName()
    })
end

-- 🛰️ מעבר על כל הצאצאים
local total = #game:GetDescendants()
local count = 0

for _,inst in ipairs(game:GetDescendants()) do
    count = count + 1
    if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") or inst:IsA("BindableEvent") or inst:IsA("BindableFunction") then
        collectRemote(inst)
    end
    collectInstance(inst)
    collectScript(inst)
    if count % 500 == 0 then
        print("[🔎] סרקתי: "..count.."/"..total)
    end
end

-- 🔥 סריקה ספציפית בתיקיות חשובות
for _,folderName in ipairs({"Items","Units","Traits","Gacha","Shop"}) do
    local folder = RS:FindFirstChild(folderName)
    if folder then
        for _,child in ipairs(folder:GetDescendants()) do
            collectInstance(child)
        end
    end
end

-- 💾 שמירת קבצים
writefile("Ultra_Info_Remotes_v50.json", HttpService:JSONEncode(dump))
writefile("Ultra_Remotes_List.txt", table.concat((function()
    local t = {}
    for _,r in ipairs(dump.Remotes) do
        table.insert(t,r.Name.." | "..r.Path)
    end
    return t
end)(),"\n"))

writefile("Ultra_Items_List.txt", HttpService:JSONEncode(dump.Instances.Items))
writefile("Ultra_Units_List.txt", HttpService:JSONEncode(dump.Instances.Units))
writefile("Ultra_Traits_List.txt", HttpService:JSONEncode(dump.Instances.Traits))

print("✅ נשמר בהצלחה! Remotes/Items/Units/Traits נאספו!")

-- 📌 GUI קטן (לא חובה)
local ScreenGui = Instance.new("ScreenGui",game.CoreGui)
local TextLabel = Instance.new("TextLabel",ScreenGui)
TextLabel.Size = UDim2.new(0,400,0,50)
TextLabel.Position = UDim2.new(0,20,0,20)
TextLabel.BackgroundTransparency = 0.3
TextLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
TextLabel.TextColor3 = Color3.fromRGB(0,255,0)
TextLabel.TextScaled = true
TextLabel.Text = "✅ Dump Done: "..tostring(#dump.Remotes).." Remotes, "..tostring(#dump.Instances.Items).." Items, "..tostring(#dump.Instances.Units).." Units, "..tostring(#dump.Instances.Traits).." Traits."
