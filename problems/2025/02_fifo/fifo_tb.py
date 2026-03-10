import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.types import LogicArray
from queue import Queue
import random

class TB:
    def __init__(self, dut):
        self.dut = dut
        self.dut.i_wr_vld.value = 0
        self.dut.i_rd_en.value = 0

        self.queue = Queue(maxsize=int(self.dut.DEPTH.value))

    async def generate_clock(self):
        while True:
            self.dut.clk.value = 0
            await Timer(1, unit="ns")
            self.dut.clk.value = 1
            await Timer(1, unit="ns")

    async def reset(self):
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1;
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 0;
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1;

    async def process(self):
        while True:
            await RisingEdge(self.dut.clk)

            assert self.queue.empty() == self.dut.o_empty.value
            assert self.queue.full() == self.dut.o_full.value

            if self.dut.i_rd_en.value and not self.dut.o_empty.value:
                assert self.queue.get() == self.dut.o_rd_data.value

            if self.dut.i_wr_vld.value and (not self.dut.o_full.value or (self.dut.i_rd_en.value and not self.dut.o_empty.value)):
                assert not self.queue.full()
                self.queue.put(int(self.dut.i_wr_data.value))


            if not int(self.dut.o_full.value) and random.randint(0, 3) != 0:
                self.dut.i_wr_vld.value  = 1
                self.dut.i_wr_data.value = random.randint(0, 2**int(self.dut.WIDTH.value)-1)
            else:
                self.dut.i_wr_vld.value = 0
                self.dut.i_wr_data.value = LogicArray("X" * int(self.dut.WIDTH.value))

            self.dut.i_rd_en.value = int(random.randint(0, 3) != 0)


@cocotb.test()
async def fifo_test(dut):
    tb = TB(dut)

    cocotb.start_soon(tb.generate_clock())
    await tb.reset()

    cocotb.start_soon(tb.process())

    await Timer(10**5, unit="ns")

