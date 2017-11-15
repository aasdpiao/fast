--
-- lstring.lua
-- Additions to Lua's built-in string functions.

--
-- Return the hexadecimal representation of the binary data
--
function string.hexlify(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return s
end

--
-- Return the binary data represented by the hexadecimal string hexstr.
--
function string.unhexlify(s)
    s = string.gsub(s, "(%x%x)", function (h)
        return string.char(tonumber(h, 16))
    end)
    return s
end

--
-- Capitalize the first letter of the string.
--

function string.capitalize(s)
    return s:gsub("^%l", string.upper)
end



--
-- Returns true if the string has a match for the plain specified pattern
--

function string.contains(s, match)
    return string.find(s, match, 1, true) ~= nil
end


--
-- Returns an array of strings, each of which is a substring of s
-- formed by splitting on boundaries formed by `pattern`.
--

function string.split(s, pattern, plain, maxTokens)
    if (pattern == '') then return false end
    local pos = 0
    local arr = { }
    for st,sp in function() return s:find(pattern, pos, plain) end do
        table.insert(arr, s:sub(pos, st-1))
        pos = sp + 1
        if maxTokens ~= nil and maxTokens > 0 then
            maxTokens = maxTokens - 1
            if maxTokens == 0 then
                break
            end
        end
    end
    table.insert(arr, s:sub(pos))
    return arr
end



--
-- Find the last instance of a pattern in a string.
--

function string.findlast(s, pattern, plain)
    local curr = 0
    repeat
        local next = s:find(pattern, curr + 1, plain)
        if (next) then curr = next end
    until (not next)
    if (curr > 0) then
        return curr
    end
end



--
-- Returns the number of lines of text contained by the string.
--

function string.lines(s)
    local trailing, n = s:gsub('.-\n', '')
    if #trailing > 0 then
        n = n + 1
    end
    return n
end

--
-- Trim any whitespace on both left and right of s
--
function string.strip(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
