local term = require ('term')
local component = require ('component')
local event = require ('event')
local computer = require('computer')
local reactor

local max_energy
local max_heat

local reactor_state = false
local energy = 0
local currentHeat = 0
local cells = 0

-- CONFIGURATION --
MAXENERGYRATIO = 0.8

local function initialize()
    term.clear()
    print("Initializing...")
    computer.beep()

    if not component.isAvailable("nc_fission_reactor") then
        print("Reactor not connected. Please connect the computer to the fission reactor.")
        return false
    end

    reactor = component.nc_fission_reactor

    max_energy = reactor.getMaxEnergyStored()
    max_heat = reactor.getMaxHeatLevel()

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
    print("\n Status:")
    if (currentHeat > max_heat / 2) then
        reactor.deactivate()
        computer.beep(30, 5)
        print("Emergency Heat Shutdown")
    elseif (energy > max_energy * MAXENERGYRATIO) then
        reactor.deactivate()
        print("Excess Energy")
    else
        print("Nominal")
        reactor.activate()
    end
end

---Program Start
if initialize() then
    repeat
        updateValues()
        updateMain()
    until event.pull() == 'interrupted'
    reactor.deactivate()
end
computer.beep(30, 5)