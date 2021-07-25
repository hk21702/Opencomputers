local term = require 'term'
local component = require 'component'
local event = require 'event'
local computer = require 'computer'
local reactor = component.nc_fission_reactor

computer.beep()

print("Initializing...")

repeat
    local power = reactor.getEnergyChange()
    print(power)
until event.pull() == 'interrupted'