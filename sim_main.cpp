#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

void reset(Vtop& dut)
{
    dut.reset = 1;
}

int main(void)
{
    Vtop dut;
    Verilated::traceEverOn(true);
    VerilatedVcdC tfp;
    dut.trace(&tfp, 5);
    tfp.open("wave.vcd");

    dut.clk = 1;
    
    while (sim_time < MAX_SIM_TIME) 
    {
        dut.clk ^= 1;

        if (sim_time < 5)
        {
            reset(dut);
        }
        else
        {
            dut.reset = 0;
        }

        dut.eval();
        tfp.dump(sim_time);
        sim_time++;
    }
    
    tfp.close();
    std::cout << "Simulation finished." << std::endl;

    return 0;
}