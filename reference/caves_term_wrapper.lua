-- Forlorn Fox
-- Copyright © 2020 Rob Probin
-- No redistribution without permission.
--

require("strict")

local class = require("middleclass")
local text_buffer = require("player/text_buffer")
local UnicodeTextEntry = require("main_menu/unicode_text_entry")
require("easter_eggs/caves129")
local copas = require("copas")
local Queue = require("utilities/Queue")
local term = require("player/term")

--
-- Very slight extension to unicode text entry to
-- call the terminal
--
--local caves_term = class("caves_term", UnicodeTextEntry)
local caves_term = class("caves_term")

-- these persist across instances (one per client)
local caves_buffer = nil
local caves_thread = nil
local caves_output = nil

function caves_term:printf(text)
    -- we might have /n inside this text. We might also have trailing text without NL.
    for str, nl in string.gmatch(text, "([^\n]*)(\n?)") do
        if #nl ~= 0 then
            if caves_output then
                gulp.text_buffer:add_line(caves_output .. str, "YELLOW")
                caves_output = nil
            else
                gulp.text_buffer:add_line(str, "YELLOW")
            end
        else
            if caves_output then
                caves_output = caves_output .. str   -- actually str can be empty string... but doesn't really matter
            elseif str ~= "" then
                caves_output = str
            end
        end
    end
end


function caves_term:get_line()
    -- always dump the text to the screen before waiting for input
    if caves_output then
        gulp.text_buffer:add_line(caves_output, "YELLOW")
        caves_output = nil
    end
    
    while caves_buffer:empty() do
        copas.sleep(0.1)
    end
    return caves_buffer:popfirst()
end

local function caves_error(msg, co, skt)
  print (msg, co, skt)
  error(msg)
end

-- wrapper so we can set error handler in coroutine
local function caves_wrap()
    copas.setErrorHandler(caves_error)
    caves_main()
    print("Caves ended without error")
end


function caves_term:initialize(CLI)    
    -- start two lines down from text aligned location
    --UnicodeTextEntry.initialize(self, 0, 2, "", gulp.colour.CYAN.simple_colour)
    
    term.open(self)
    
    gulp.caves = self
    
    -- make sure buffer is full at start
    caves_buffer = Queue:new()
    
    if not caves_thread or coroutine.status(caves_thread) == "dead" then
        caves_thread = copas.addthread(caves_wrap)
    end
end

function caves_term:text_complete(text)
    caves_buffer:pushlast(text)
end

function caves_term:on_close()
    --print("close!")
end


return caves_term