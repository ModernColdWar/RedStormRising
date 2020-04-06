# Red Storm Rising

A persistent PvP mission for DCS world.

## Installation

 1. From your install folder (not saved games), open `Scripts/MissionScripting.lua`
 2. Comment out all the lines in the do block below the sanitization function with `-\-`.  This allows the LUA engine access to the file system. It should look similar to:
```lua
  --sanitizeModule('os')
  --sanitizeModule('io')
  --sanitizeModule('lfs')
  --require = nil
  --loadlib = nil
```
 3. Clone this repository: from your `Saved Games\DCS\Scripts` folder run `git clone https://github.com/ModernColdWar/RedStormRising.git RSR`.  This should create a folder named `RSR` and in the end it should look like `Saved Games\DCS\Scripts\RSR`
 4. Update your mission file to include a `DO SCRIPT` trigger to run `dofile(lfs.writedir() .. [[Scripts\RSR\RSR.lua]])`
 5. Follow the steps on the [Developer-setup](https://github.com/ModernColdWar/RedStormRising/wiki/Developer-setup) wiki page
