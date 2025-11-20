local function greet(name: string): string
    return "Hello, " .. name .. "!"
end

return greet


print(greet("World"))  -- Output: Hello, World!