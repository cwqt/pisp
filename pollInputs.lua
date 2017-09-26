-- make sure lua runs with su priviledges, e.g. with sudo chmod +s /usr/bin/lua
-- or run this script with "sudo lua"

local GPIO = require('periphery').GPIO
local P    = require('posix')

local pins = {
    { pin=16, code="KEY_UP"       }, -- D-pad
    { pin=12, code="KEY_DOWN"     },
    { pin=20, code="KEY_LEFT"     },
    { pin=21,  code="KEY_RIGHT"    },

    { pin=23, code="KEY_LEFTCTRL" },
    { pin=7,  code="KEY_LEFTALT"  },
    { pin=2,  code="KEY_5"        },
    { pin=27, code="KEY_1"        },
    { pin=3,  code="KEY_SPACE"    },
    { pin=4,  code="KEY_ENTER"    },
    { pin=22, code="KEY_TAB"      },
    { pin=24, code="KEY_ESC" 	  }
}

-- Create a table of GPIO-Pins, same order as the "pins" table
local gpios = {}
for t = 1,#pins do
    gpios[t] = GPIO( pins[t].pin, "in")
    -- Get interrupt on button press and release
    gpios[t].edge = "both"
end

-- Forever loop:
while true do
    -- Create a table of FileDescriptors for posix-poll()
    -- GPIO-Interrupts arrive with flag "PRI"
    local fds = {}
    for t = 1, #gpios do
        fds[gpios[t].fd] = { events = { PRI = true , index = t }}
    end

    local numevents = P.poll(fds,1000)
    if numevents > 0 then -- Anything changed?
        for _,f in pairs(fds) do -- Now search all revents with PRI=true
            local revents = f.revents
            if revents then
                if revents.PRI then
                    local ix = f.events.index -- Get Index of our gpios table
                    local res = gpios[ix]:read() -- Get the input state
                    print(res, gpios[ix], pins[ix].code) -- Give some user feedback
                end
            end
        end
    end
end