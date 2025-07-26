# Valves

[![shield](https://img.shields.io/badge/Ko--fi-Donate%20-hotpink?logo=kofi&logoColor=white)](https://ko-fi.com/stringweasel) [![shield](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fvalves)](https://mods.factorio.com/mod/valves)

Fully functioning overflow, top-up and one-way(check) as separate entities with animations. The thresholds can be configured using shortcuts.

## Shortcuts (configurable)
- **Numpad +**: Increase threshold for overflow or top-up valves.
- **Numpad -**: Decrease threshold for overflow or top-up valves.

# Settings
- Startup settings for default thresholds for overflow and top-up valves.
- A startup setting for the valves' pump speed when it's open.

## Compatibility
Should be comptatibile with most mods. If it's not compatible, please let me know.
- **Pyanodons**: Will automatically migrate old Factorio 1.1 valves to their 2.0 counter part.

It's also possible for other modders to hook their own valve prototypes into this Valves mod. Then this mod will manage your custom mod's thresholds, show it on entity selected, show warnings, etc. See the [mod-data.lua](https://github.com/heinwessels/factorio-valves/blob/master/prototypes/mod-data.lua) for more information.

## Limitation with Pumps
A valve's output cannot be connected to a pump's input, regardless of valve type. Due to a game engine limitation the pump will bypass the valve as if it's not there. The [one image in the gallery](https://assets-mod.factorio.com/assets/316cf62d974334fdc45e1fe82ef87192ba9d3b25.png) shows the different pump connections. You can check for bad valve connections in game at any point using `/valves-find-bad-connections`.

# UPS Impact
These valves use the prototypes provided by the game engine. That means it probably has less of a UPS impact than normal pumps. There are no fluid calculations done in this mod itself.

## Credits
- _Boskid_ for adding the ability to link pipes to the Factorio engine.
- [raiguard](https://mods.factorio.com/user/raiguard) for adding native valve prototypes.
- [GotLag and Snouz](https://mods.factorio.com/mod/Flow%20Control) for the high quality graphics of the old pump sprite.
- _justarandomgeek_ for the [Factorio Modding Toolkit](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug), without which this mod would not have been possible.
