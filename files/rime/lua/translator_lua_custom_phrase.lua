--- @@ lua_custom_phrase
--[[
取代原先 table_translator@custom_phrase。
可多行，用\n\r。
--]]


---------------------------------------------------------------
--- 置入方案範例
--[[
engine:
  translators:
    - lua_translator@lua_custom_phrase

lua_custom_phrase:
  user_dict: "lua_custom_phrase"
--]]
---------------------------------------------------------------
-- local function file_exists(path)
--     if type(path)~="string" then return false end
--     return os.rename(path,path) and true or false
-- end

-- local function isFile(path)
--     if not file_exists(path) then return false end
--     local f = io.open(path)
--     if f then
--       local res = f:read(1) and true or false
--       f:close()
--       return res
--     end
--     return false
-- end

-- local slash = package.path:sub(1,1)  -- package.path 跑出的內容太長，不用。
---------------------------------------------------------------
--- 「load_text_dict」把 txt 檔變成 lua table 供後續查詢。

local function load_text_dict(text_dict)
  -- --- text_dict == "" 已會處理，但挪用此函數時此條有用。
  -- if text_dict == "" then return end
  --- 當輸入 text_dict 不為 string 則跳開，該函數為 nil。
  if (type(text_dict) ~= "string") then return end

  local path = rime_api.get_user_data_dir()
  -- local file_name = path .. "/" .. ( text_dict or "lua_custom_phrase" ) .. ".txt"  -- 如 text_dict 為 nil，下方已跳開，可不用 or
  local file_name = path .. "/" .. text_dict .. ".txt"
  -- local f = io.open(file_name, "r")

  --- 當找不到該 txt 字典檔案則跳開，該函數為 nil。
  -- if not isFile(file_name) then return end  -- 在 widonws 中會有問題。
  -- if io.open(file_name) == nil then return log.error("lua_custom_phrase： Missing user_dict File!") end  -- 錯誤日誌中提示遺失檔案（不存在）
  if io.open(file_name) == nil then return end
  -- if (f == nil) then return end

  local tab = {}
  for line in io.open(file_name):lines() do
  -- for line in f:lines() do
    local v_text, v_code = string.match(line, "^([^\t#][^\t]*)\t([%d%l,./; -]+)\t?.*$")
    if v_text then

      -- tab[v_code] = v_text  -- 一個 code 只能有一條短語，下方可一個 code，多條短語。
      if tab[v_code] == nil then
        local nn={}
        table.insert(nn, v_text)
        tab[v_code] = nn
      else
        table.insert(tab[v_code], v_text)
      end

    end
  end

  -- f:close()

  return tab
end

---------------------------------------------------------------
local function init(env)
  engine = env.engine
  schema = engine.schema
  config = schema.config
  -- namespace = "lua_custom_phrase"
  env.textdict = config:get_string(env.name_space .. "/user_dict") or ""
  --- 以下 「load_text_dict」 可能為 nil 故要 or {}
  env.tab = load_text_dict(env.textdict) or {}  -- 更新 txt 需「重新部署」或方案變換
  env.quality = 10
  -- log.info("lua_custom_phrase: \'" .. env.textdict .. ".txt\' Initilized!")  -- 日誌中提示已經載入 txt 短語
end


local function translate(input, seg, env)
  --- 當 schema 中找不到設定則跳開（env.textdict為""，該函數為 nil）
  -- if env.textdict == "" then return log.error("lua_custom_phrase： user_dict File Name is Wrong or Missing!") end  -- 錯誤日誌中提示名稱錯誤或遺失
  if env.textdict == "" then return end

  -- local engine = env.engine
  -- local context = engine.context
  -- local caret_pos = context.caret_pos
  --- 以下 「load_text_dict」 可能為 nil 故要 or {}
  -- local text_dict_tab = load_text_dict("lua_custom_phrase") or {}  -- 直接限定 txt 字典
  -- local text_dict_tab = load_text_dict(env.textdict) or {}  -- 更新 txt 不需「重新部署」
  --- {}['xxx'] 拋出 nil，{}不為 nil。
  -- local c_p_tab = text_dict_tab[input]  -- 更新 txt 不需「重新部署」
  local c_p_tab = env.tab[input]  -- 更新 txt 需「重新部署」或方案變換

  if c_p_tab then
  -- if (caret_pos == #input) and c_p_tab then  --只能在一開頭輸入，掛接後續無法。
    for _, v in pairs(c_p_tab) do
      local v = string.gsub(v, "\\n", "\n")  -- 可以多行文本
      local v = string.gsub(v, "\\r", "\r")  -- 可以多行文本
      local cand = Candidate("short", seg.start, seg._end, v, "〔短語〕")
      cand.quality = env.quality
      yield(cand)
    end
  end

  -- --- 以下測試用
  -- if (string.match(input, "^11$")~=nil) then
  --   cand.quality = env.quality
  --   yield( Candidate("short", seg.start, seg._end, '『測試用』', "〔短語〕") )
  --   yield(cand)

end


return {init = init, func = translate}
-- return lua_custom_phrase
---------------------------------------------------------------
--- 參考


--[[
local function load_ext_dict(ext_dict)
  --local path= string.gsub(debug.getinfo(1).source,"^@(.+/)[^/]+$", "%1")
  local path= rime_api.get_user_data_dir() .. slash
  filename =  path ..  ( ext_dict or "ext_dict" ) .. ".txt"
  if not isFile(filename) then return end

  local tab = {}
  for line in io.open(filename):lines() do
    if not line:match("^#") then  -- 第一字 #  不納入字典
      local t=line:split("\t")
      if t then
        tab[ t[1] ] = t[2]
      end
    end
  end
  return tab
end


-- return Translation
local function eng_tran(dict,mode,prefix_comment,cand)

  return Translation(function()
    -- 使用 context.input 查字典 type "english"
    local inp = cand.text
    for w in dict:iter(inp) do
      -- system_format 處理 comment 字串長度 格式
      local comment = system_format(  prefix_comment..w:get_info(mode) )
      local commit = sync_case(inp,w.word)
      -- 如果 與 字典相同 替換 first_cand cand.comment
      if cand.text:lower() == commit:lower() then
        cand.comment= comment
      else
        yield( ShadowCandidate(cand,cand.type,commit,comment) )
      end
    end
  end)
end
--]]