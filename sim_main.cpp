#include <iostream>
#include <fstream>
#include <string_view>
#include <array>
#include <stdexcept>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"
#include "Vtop__Dpi.h"

#define MBASE 0x8000'0000
#define MSIZE 0x10'0000 // 1MB

std::array<uint8_t, MSIZE> mem;

std::uint32_t load_img(std::string_view filename);

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;

void reset(Vtop& dut)
{
    dut.reset = 1;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        std::cerr << "Usage: " << argv[0] << " <program> [args ...]\n";
        exit(EXIT_FAILURE);
    }

    /* init memory and load img*/
    std::uint32_t img_size = load_img(argv[1]);

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

std::uint32_t load_img(std::string_view filename)
{
    std::ifstream img(filename.data(), std::ios::binary);

    if (!img)
    {
        throw std::runtime_error("Failed to open image file");
    }

    img.seekg(0, std::ios::end);
    auto size = img.tellg();
    img.seekg(0, std::ios::beg);

    if (size > MSIZE)
    {
        throw std::runtime_error("Image file is too large");
    }

    if (!img.read(reinterpret_cast<char*>(mem.data()), size))
    {
        throw std::runtime_error("Failed to read image file");
    }

    img.close();

    return size;
}

int pmem_read(int raddr) 
{
    uint32_t addr = static_cast<uint32_t>(raddr - MBASE);
    uint32_t data{};

    if (addr < 0 || addr >= MSIZE)
    {
        std::cout << "Invalid address: " << addr << std::endl;
        throw std::runtime_error("Invalid address");
    }

    data |= mem[addr];
    data |= mem[addr + 1] << 8;
    data |= mem[addr + 2] << 16;
    data |= mem[addr + 3] << 24;

    return data;
}

void pmem_write(int waddr, int wdata, char wmask)
{
    uint32_t addr = static_cast<uint32_t>(waddr - MBASE);
    
    if (addr < 0 || addr >= MSIZE)
    {
        std::cout << "Invalid address: " << addr << std::endl;
        throw std::runtime_error("Invalid address");
    }

    if (wmask == 0b0001)   // write 1 byte
    {   
        mem[addr] = static_cast<uint8_t>(wdata);
    }
    else if (wmask == 0b0011)  // write 2 bytes
    {
        
        mem[addr] = static_cast<uint8_t>(wdata);
        mem[addr + 1] = static_cast<uint8_t>(wdata >> 8);
    }
    else if (wmask == 0b1111)  // write 4 bytes
    {
        mem[addr] = static_cast<uint8_t>(wdata);
        mem[addr + 1] = static_cast<uint8_t>(wdata >> 8);
        mem[addr + 2] = static_cast<uint8_t>(wdata >> 16);
        mem[addr + 3] = static_cast<uint8_t>(wdata >> 24); 
    }
    else
    {
        std::cout << "Invalid write mask: " << wmask << std::endl;
        throw std::runtime_error("Invalid write mask");
    }
}