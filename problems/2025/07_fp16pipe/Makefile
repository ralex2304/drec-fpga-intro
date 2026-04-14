TEST_SIZE ?= 4096
DEBUG     ?= 0

TEST_OP   = add

TB_LIST := fp16pipe_tb.v

RTL_LIST := fp16add_pipe0.v fp16add_pipe1.v fp16add_pipe2.v

sim: $(TB_LIST) $(RTL_LIST)
	python3 test.py $(TEST_SIZE) $(TEST_OP) > test.txt
	iverilog -g2012 $^ -o sim -DTEST_SIZE=$(TEST_SIZE) -DTEST_OP=$(TEST_OP) -DDEBUG=$(DEBUG)
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

clean:
	rm -rf sim dump.vcd test.txt

.PHONY: clean sim waves
