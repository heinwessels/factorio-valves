local constants = { }

constants.signal = {
    each =      { type = 'virtual', name = 'signal-each' },
    input =     { type = "virtual", name = "signal-I" },
    output =    { type = "virtual", name = "signal-O" },
}

constants.behaviour = {
    overflow =  { comparator = '>', first_signal = constants.signal.input,  constant = 80, },
    top_up =    { comparator = '<', first_signal = constants.signal.output, constant = 80, },
    no_return = { comparator = '>', first_signal = constants.signal.input,  second_signal = constants.signal.output, },
}

return constants