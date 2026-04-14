create_clock -period "120.0 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from [get_ports i_a[*]] -to [all_clocks]
set_false_path -from [get_ports i_b[*]] -to [all_clocks]
set_false_path -from * -to [get_ports o_res[*]]
