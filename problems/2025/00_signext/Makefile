TB_LIST := sign_ext_tb.v

RTL_LIST := sign_ext_bit.v sign_ext.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves
