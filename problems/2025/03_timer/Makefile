gui:
	quartus fpga &

syn:
	quartus_sh --flow compile fpga_top

fpga:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output_files/fpga_top.sof"

drc:
	quartus_drc fpga

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output fpga.qws greybox_tmp *.bak

.PHONY: syn fpga clean gui drc
