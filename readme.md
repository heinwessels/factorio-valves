# Valves

[![shield](https://img.shields.io/badge/Ko--fi-Donate%20-hotpink?logo=kofi&logoColor=white)](https://ko-fi.com/stringweasel) [![shield](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fvalves)](https://mods.factorio.com/mod/valves)

Overflow, top-up and one-way(check) valves, just like Flow Control and Advanced Fluid Handling. The thresholds can be configured using shortcuts.

This is a fully standalone mod, even though it's uses the techniques used in [Configurable Valves](https://mods.factorio.com/mod/configurable-valves). The difference is you can only set the thresholds using shortcuts, whereas with Configurable Valves you can set the conditions directly.

## Shortcuts (configurable)
- **Numpad +**: Increase threshold for overflow or top-up valves.
- **Numpad -**: Decrease threshold for overflow or top-up valves.

**Note:** The default threshold when placed can be changed in settings.

## Compatibility
Should be comptatibile with most mods. If it's not compatible, please let me know.
    - **Pyanodons**: Will automatically migrate old Factorio 1.1 valves to their 2.0 counter part.

# UPS Impact
This valve has no measurable impact. It's the same UPS impact as using a pump + combinator + storage-tank to control fluid movement. There are no `on_tick` calculations.

## Credits
- _Boskid_ for adding the ability to link pipes to the Factorio engine.
- [GotLag and Snouz](https://mods.factorio.com/mod/Flow%20Control) for the high quality graphics of the old pump sprite. 
- _justarandomgeek_ for the [Factorio Modding Toolkit](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug), without which this mod would not have been possible.
