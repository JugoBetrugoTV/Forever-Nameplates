local _, NS = ...
local Share = {}
NS.Share = Share
local Deflate = LibStub("LibDeflate")
local fields = {"id","kind","source","text","x","y","width","height","alpha","layer","fontSize","enabled","locked","vertical","reverse","shape","asset"}
local bools = {enabled=true,locked=true,vertical=true,reverse=true}
local numbers = {x=true,y=true,width=true,height=true,alpha=true,layer=true,fontSize=true}
local function hex(value)
    return (value:gsub(".", function(c) return string.format("%02x", string.byte(c)) end))
end
local function unhex(value)
    if #value%2~=0 or value:find("[^0-9a-f]") then error("Invalid encoded string") end
    return (value:gsub("..", function(pair) return string.char(tonumber(pair,16)) end))
end
local function split(value, delimiter)
    local result,offset={},1
    while true do
        local first,last=value:find(delimiter,offset,true)
        if not first then result[#result+1]=value:sub(offset); break end
        result[#result+1]=value:sub(offset,first-1); offset=last+1
    end
    return result
end
function Share.Export(layout)
    local valid, err=NS.Model.Validate(layout)
    if not valid then return nil,err end
    local lines={"1",hex(valid.name)}
    for _, e in ipairs(valid.elements) do
        local row={}
        for _, key in ipairs(fields) do
            local value=e[key]
            if bools[key] then value=value and "1" or "0"
            elseif numbers[key] then value=string.format("%.6f",value)
            else value=hex(value) end
            row[#row+1]=value
        end
        for i=1,4 do row[#row+1]=string.format("%.6f",e.color[i]) end
        lines[#lines+1]=table.concat(row,";")
    end
    local raw=table.concat(lines,"\n")
    if #raw>32768 then return nil,"Layout exceeds share limit" end
    -- Independently compressed small blocks bound the work per decompression call.
    local blocks={}
    for i=1,#raw,160 do
        local compressed=Deflate:CompressDeflate(raw:sub(i,i+159),{level=5})
        blocks[#blocks+1]=Deflate:EncodeForPrint(compressed)
    end
    local code="FN1:"..table.concat(blocks,".")
    if #code>48000 then return nil,"Share code too large" end
    return code
end
local function decode(code)
    if type(code)~="string" or #code>48000 or code:sub(1,4)~="FN1:" then error("Invalid share header or size") end
    local blocks=split(code:sub(5),".")
    local raw,total={},0
    if #blocks>205 then error("Too many compressed blocks") end
    for _, block in ipairs(blocks) do
        if #block==0 or #block>240 or block:find("[^a-zA-Z0-9%(%) ]") then error("Invalid compressed block") end
        local compressed=Deflate:DecodeForPrint(block)
        if not compressed or #compressed>180 then error("Invalid compressed data") end
        local text,left=Deflate:DecompressDeflate(compressed)
        if not text or #text>160 or left~=0 then error("Invalid block output") end
        total=total+#text; if total>32768 then error("Decoded layout too large") end
        raw[#raw+1]=text
    end
    local lines=split(table.concat(raw),"\n")
    if lines[1]~="1" or #lines<3 or #lines>66 then error("Invalid layout envelope") end
    local layout={version=1,name=unhex(lines[2]),elements={}}
    for i=3,#lines do
        local row=split(lines[i],";")
        if #row~=#fields+4 then error("Invalid field count") end
        local e={color={}}
        for j,key in ipairs(fields) do
            if bools[key] then
                if row[j]~="0" and row[j]~="1" then error("Invalid boolean") end
                e[key]=row[j]=="1"
            elseif numbers[key] then e[key]=tonumber(row[j])
            else e[key]=unhex(row[j]) end
        end
        for j=1,4 do e.color[j]=tonumber(row[#fields+j]) end
        layout.elements[#layout.elements+1]=e
    end
    local valid,err=NS.Model.Validate(layout)
    if not valid then error(err) end
    return valid
end
function Share.Import(code)
    local ok,result=pcall(decode,code)
    if ok then return result end
    return nil,"Import rejected: "..tostring(result)
end
