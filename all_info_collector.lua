-- ⚡ Ultra Deep Dumper v3000.0++ | Console Output Only
-- 🔥 מחפש ומדפיס כל Remote / Item / Unit / Trait / Id / DisplayName / Constants אפשריים
-- 🛠️ דורש exploit עם getgc, getreg, getloadedmodules, debug.getupvalues, debug.getconstants, debug.getproto

local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local seen = {}

local function mark(obj)
    local id = tostring(obj)
    if seen[id] then return false end
    seen[id] = true
    return true
end

local function dumpInfo(tag, data)
    print("["..tag.."] "..HttpService:JSONEncode(data))
end

local function scanInstance(inst)
    if not mark(inst) then return end
    local low = inst.Name:lower()
    if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
        dumpInfo("Remote", {Name=inst.Name,Path=inst:GetFullName(),Class=inst.ClassName})
    elseif low:find("item") or low:find("burner") or low:find("lock") then
        dumpInfo("Item", {Name=inst.Name,Path=inst:GetFullName(),Class=inst.ClassName,Attrs=inst:GetAttributes()})
    elseif low:find("unit") or low:find("hero") or low:find("char") then
        dumpInfo("Unit", {Name=inst.Name,Path=inst:GetFullName(),Class=inst.ClassName,Attrs=inst:GetAttributes()})
    elseif low:find("trait") or low:find("potential") then
        dumpInfo("Trait", {Name=inst.Name,Path=inst:GetFullName(),Class=inst.ClassName,Attrs=inst:GetAttributes()})
    end
    for _,prop in ipairs({"DisplayName","Id","Value","Text","ToolTip","Texture"}) do
        local ok,v = pcall(function() return inst[prop] end)
        if ok and v~=nil and typeof(v)~="Instance" then
            dumpInfo("Prop", {Owner=inst.Name,Prop=prop,Val=tostring(v)})
        end
    end
end

-- 🔎 scan all descendants
print("🔎 סורק Descendants...")
for _,inst in ipairs(game:GetDescendants()) do
    scanInstance(inst)
end
for _,folderName in ipairs({"Items","Units","Traits","Gacha","Shop"}) do
    local f = RS:FindFirstChild(folderName)
    if f then
        for _,c in ipairs(f:GetDescendants()) do
            scanInstance(c)
        end
    end
end

-- 🔎 scan getgc
if getgc then
    print("🔎 סורק getgc()...")
    for _,obj in ipairs(getgc(true)) do
        if typeof(obj)=="table" then
            if mark(obj) then
                for k,v in pairs(obj) do
                    if type(k)=="string" then
                        local lk=k:lower()
                        if lk:find("id") or lk:find("item") or lk:find("unit") or lk:find("trait") then
                            dumpInfo("GC-Key",{Key=k,Val=tostring(v)})
                        end
                    end
                    if type(v)=="string" then
                        local lv=v:lower()
                        if lv:find("id") or lv:find("item") or lv:find("unit") or lv:find("trait") then
                            dumpInfo("GC-Val",{Val=v})
                        end
                    end
                end
            end
        elseif typeof(obj)=="function" then
            if mark(obj) then
                for _,c in ipairs(debug.getconstants(obj)) do
                    if type(c)=="string" then
                        local lc=c:lower()
                        if lc:find("id") or lc:find("item") or lc:find("unit") or lc:find("trait") then
                            dumpInfo("GC-Const",{Const=c})
                        end
                    end
                end
                for i,uv in ipairs(debug.getupvalues(obj)) do
                    if type(uv)=="string" then
                        local lu=uv:lower()
                        if lu:find("id") or lu:find("item") or lu:find("unit") or lu:find("trait") then
                            dumpInfo("GC-Upv",{Upval=uv})
                        end
                    elseif type(uv)=="table" then
                        for k,v in pairs(uv) do
                            if type(k)=="string" then
                                local lk=k:lower()
                                if lk:find("id") or lk:find("item") or lk:find("unit") or lk:find("trait") then
                                    dumpInfo("GC-UpvKey",{Key=k,Val=tostring(v)})
                                end
                            end
                        end
                    end
                end
                if debug.getproto then
                    for i=1,5 do
                        local ok,proto = pcall(function() return debug.getproto(obj,i) end)
                        if ok and proto then
                            dumpInfo("GC-Proto",{Index=i,Proto=tostring(proto)})
                        end
                    end
                end
            end
        end
    end
end

-- 🔎 scan getreg
if getreg then
    print("🔎 סורק getreg()...")
    for k,v in pairs(getreg()) do
        local t = typeof(v)
        if t=="Instance" then
            scanInstance(v)
        elseif t=="table" then
            for kk,vv in pairs(v) do
                if type(kk)=="string" then
                    local lk=kk:lower()
                    if lk:find("id") or lk:find("item") or lk:find("unit") or lk:find("trait") then
                        dumpInfo("REG-Key",{Key=kk,Val=tostring(vv)})
                    end
                end
                if type(vv)=="string" then
                    local lv=vv:lower()
                    if lv:find("id") or lv:find("item") or lv:find("unit") or lv:find("trait") then
                        dumpInfo("REG-Val",{Val=vv})
                    end
                end
            end
        end
    end
end

-- 🔎 scan loaded modules
if getloadedmodules then
    print("🔎 סורק getloadedmodules()...")
    for _,mod in ipairs(getloadedmodules()) do
        if not seen[mod] then
            seen[mod] = true
            local ok,src = pcall(decompile,mod)
            if ok and src and type(src)=="string" then
                local lines = 0
                for w in src:gmatch("[^\r\n]+") do
                    lines = lines + 1
                    local lw = w:lower()
                    if lw:find("id") or lw:find("item") or lw:find("unit") or lw:find("trait") then
                        dumpInfo("MOD-Src",{Module=mod.Name,Line=lines,Text=w})
                    end
                end
            end
        end
    end
end

print("✅ הסריקה המלאה הסתיימה! בדוק את הקונסול — כל Remote, Item, Trait, Unit, Id ו‑DisplayName שמצאתי הודפסו.")
