--[[--
 Base implementations of functions exported by `std.functional`.

 These functions are required by implementations of exported functions
 in other stdlib modules.  We keep them here to avoid bloating std.base,
 which is loaded by *every* stdlib module.

 @module std.base.functional
]]


local function callable (x)
  if type (x) == "function" then return true end
  return type ((getmetatable (x) or {}).__call) == "function"
end


local function collect (ifn, ...)
  local argt = {...}
  if not callable (ifn) then
    ifn, argt = ipairs, {ifn, ...}
  end

  local r = {}
  for k, v in ifn (unpack (argt)) do
    if v == nil then k, v = #r + 1, k end
    r[k] = v
  end
  return r
end


local function reduce (fn, d, ifn, ...)
  local nextfn, state, k = ifn (...)
  local t = {nextfn (state, k)}

  local r = d
  while t[1] ~= nil do
    r = fn (r, t[#t])
    t = {nextfn (state, t[1])}
  end
  return r
end


return {
  callable = callable,
  collect  = collect,
  reduce   = reduce,
}