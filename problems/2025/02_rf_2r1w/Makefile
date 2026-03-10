TB_LIST := rf_2r1w.v

RTL_LIST := rf_2r1w_tb.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves
