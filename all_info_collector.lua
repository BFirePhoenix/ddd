-- 🚀 Deep Scanner v3.2 – RollBack Focus – בלי ספאם בכלל
-- ✅ שומר רק שמות ו-ID של Units / Items / Traits
-- 🛠️ דורש exploit עם writefile, getgc, getreg, getupvalues

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

local function deepScanTable(t, from)
    -- לא מדפיס כלום! רק מוסיף לרשימה
    for k,v in pairs(t) do
        if type(k)=="string" and type(v)=="string" then
            local lk, lv = k:lower(), v:lower()
            if lk:find("id") or lk:find("name") or lv:find("unit") or lv:find("item") or lv:find("trait") then
                if lv:find("unit") or lv:find("hero") or lv:find("char") then
                    add("Unit", v, "(from:"..from..")", k)
                elseif lv:find("item") or lv:find("burner") or lv:find("lock") then
                    add("Item", v, "(from:"..from..")", k)
                elseif lv:find("trait") or lv:find("potential") then
                    add("Trait", v, "(from:"..from..")", k)
                end
            end
        elseif type(v)=="table" then
            deepScanTable(v, from)
        end
    end
end

-- 🟢 התחלת הסריקה
print("🔎 [Scanner] התחלת סריקה עמוקה...")

-- 🔎 מעבר על כל הצאצאים
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

-- 🔎 getgc
if getgc then
    for _,obj in ipairs(getgc(true)) do
        if type(obj)=="table" then
            deepScanTable(obj,"GC")
        end
    end
end

-- 🔎 getreg
if getreg then
    for _,obj in ipairs(getreg()) do
        if type(obj)=="table" then
            deepScanTable(obj,"REG")
        end
    end
end

-- 🔎 upvalues
if debug and debug.getupvalues then
    for _,f in ipairs(getgc(true)) do
        if type(f)=="function" then
            for _,v in ipairs(debug.getupvalues(f)) do
                if type(v)=="table" then
                    deepScanTable(v,"UPVAL")
                end
            end
        end
    end
end

-- 💾 כתיבת הקובץ
local finalText = table.concat(results, "\n")
writefile("RollBackData.txt", finalText)

-- 🏁 סוף
print("✅ [Scanner] הסריקה הסתיימה!")
print("📂 [Scanner] הקובץ נשמר בשם: RollBackData.txt")
