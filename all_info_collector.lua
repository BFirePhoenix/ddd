-- 🚀 Deep Scanner v4 – RollBack Focus – בלי ספאם, בלי stack overflow
-- ✅ שומר שמות ו-ID של Units / Items / Traits בלבד
-- 🛠️ דורש exploit עם writefile

local RS = game:GetService("ReplicatedStorage")
local results, seen = {}, {}

local function add(tag,name,path,id)
    local line = "["..tag.."] Name: "..tostring(name).." | ID: "..tostring(id or "N/A").." | Path: "..tostring(path)
    if not seen[line] then
        seen[line] = true
        table.insert(results, line)
    end
end

local function handleInstance(obj, tag)
    local id, name
    pcall(function() id = obj.Id end)
    pcall(function() name = obj.DisplayName end)
    name = name or obj.Name
    add(tag, name, obj:GetFullName(), id)
end

local function scanInstance(inst)
    local n = inst.Name:lower()
    if n:find("unit") or n:find("hero") or n:find("char") then
        handleInstance(inst,"Unit")
    elseif n:find("item") or n:find("burner") or n:find("lock") then
        handleInstance(inst,"Item")
    elseif n:find("trait") or n:find("potential") then
        handleInstance(inst,"Trait")
    end
end

print("🔎 [Scanner] התחלת סריקה ממוקדת...")

-- 🔎 מעבר על כל הצאצאים במשחק
for _,inst in ipairs(game:GetDescendants()) do
    scanInstance(inst)
end

-- 🔎 תיקיות ידועות
for _,folderName in ipairs({"Items","Units","Traits","Gacha","Shop"}) do
    local f = RS:FindFirstChild(folderName)
    if f then
        for _,c in ipairs(f:GetDescendants()) do
            scanInstance(c)
        end
    end
end

-- 💾 כתיבת הקובץ
local finalText = table.concat(results, "\n")
writefile("RollBackData.txt", finalText)

print("✅ [Scanner] הסריקה הסתיימה בהצלחה!")
print("📂 [Scanner] הקובץ נשמר בשם: RollBackData.txt (ניתן למצוא אותו דרך Media Manager ב־BlueStacks)")
