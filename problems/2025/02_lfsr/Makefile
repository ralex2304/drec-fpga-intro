TB_LIST := lfsr.v

RTL_LIST := lfsr_tb.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd

.PHONY: clean sim waves
