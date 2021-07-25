local term = require ('term')
local component = require ('component')
local event = require ('event')
local computer = require('computer')
local reactor = component.nc_fission_reactor

local reactor_state = false
local energy = 0
local currentHeat = 0
local cells = 0

local max_energy = reactor.getMaxEnergyStored()
local max_heat = reactor.getMaxHeatLevel()

-- CONFIGURATION --
MAXENERGYRATIO = 0.8

local function initialize()
    term.clear()
    print("Initializing...")
    reactor.forceUpdate()
    if reactor.isComplete() then
        return true
    else
        print(reactor.getProblem())
        return false
    end
end

local function updateValues()
    energy = reactor.getEnergyChange()
    reactor_state = reactor.isReactorOn()
    currentHeat = reactor.getHeatLevel()
    cells = reactor.getNumberOfCells()

    term.clear()
    if (reactor_state) then
        print("Reactor ACTIVE")
    else
        print("Reactor INACTIVE")
    end

    print('\n Heat:')
    print(currentHeat.."/"..max_heat)

    print('\n Cells Remaining:')
    print(cells)

    print('\n Stored Energy:')
    print(energy..'/'..max_energy)
end

local function updateMain()
    if (currentHeat > max_heat / 2) then
        computer.beep(30, 5)
        reactor.deactivate()
        print("Emergency Heat Shutdown")
    elseif (energy > max_energy * MAXENERGYRATIO) then
        computer.beep()
        reactor.deactivate()
        print("Excess Energy")
    else
        reactor.activate()
    end
end

---Program Start
computer.beep()

initialize()

repeat
updateValues()
updateMain()
until event.pull() == 'interrupted'
computer.beep(30, 5)
reactor.deactivate()