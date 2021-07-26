local term = require ('term')
local component = require ('component')
local event = require ('event')
local computer = require('computer')

REACTOR = component.nc_fission_reactor or nil

local max_energy = 0
local max_heat = 0

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

    if REACTOR == nil then
        print("Reactor not connected. Please connect the computer to the fission reactor.")
        return false
    end

    max_energy = REACTOR.getMaxEnergyStored()
    max_heat = REACTOR.getMaxHeatLevel()

    REACTOR.forceUpdate()
    if REACTOR.isComplete() then
        return true
    else
        print(REACTOR.getProblem())
        return false
    end
end

local function updateValues()
    energy = REACTOR.getEnergyStored()
    reactor_state = REACTOR.isProcessing()
    currentHeat = REACTOR.getHeatLevel()
    cells = REACTOR.getNumberOfCells()

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
        REACTOR.deactivate()
        computer.beep(300, 5)
        print("Emergency Heat Shutdown")
    elseif (energy > max_energy * MAXENERGYRATIO) then
        REACTOR.deactivate()
        print("Excess Energy")
    else
        print("Nominal")
        REACTOR.activate()
    end
end

---Program Start
if initialize() then
    while true do
        updateValues()
        updateMain()
    end
    REACTOR.deactivate()
end
computer.beep(300, 2)