local Prox = {}

local function IsPlainTable(v)
    return type(v) == "table"
end

-- Wraps `tbl` in a proxy that fires self._attributeSignals[key] whenever
-- a field actually changes. Recurses into nested tables automatically.
function Prox.WrapTable(self, tbl, path)
    local raw = {}

    for k, v in pairs(tbl) do
        if IsPlainTable(v) then
            raw[k] = Prox.WrapTable(self, v, path and (path .. "." .. tostring(k)) or tostring(k))
        else
            raw[k] = v
        end
    end

    local proxy = setmetatable({}, {
        __index = raw,
        __newindex = function(_, key, value)
            local old = raw[key]
            local fullPath = path and (path .. "." .. tostring(key)) or tostring(key)

            -- collision check: warn if this key name is already used elsewhere
            local existingPath = self._attributePaths[key]
            if existingPath and existingPath ~= fullPath then
                warn(("[Movement] Attribute name collision on '%s' (%s vs %s) - GetAttributeChangedSignal('%s') will fire for BOTH.")
                    :format(key, existingPath, fullPath, key))
            end
            self._attributePaths[key] = fullPath

            if IsPlainTable(value) and not IsPlainTable(old) then
                value = Prox.WrapTable(self, value, fullPath)
            end

            raw[key] = value

            if old ~= value then
                local sig = self._attributeSignals[key]
                if sig then
                    sig:Fire(value, old)
                end
            end
        end,
    })

    return proxy
end



return Prox