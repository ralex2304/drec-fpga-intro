SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/fifo.v $(PWD)/fifo_stub.v

TOPLEVEL = fifo_stub

MODULE = fifo_tb

include $(shell cocotb-config --makefiles)/Makefile.sim
