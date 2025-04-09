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
#define NUM_REGS 32

std::array<uint8_t, MSIZE> mem;

std::uint32_t load_img(std::string_view filename);

vluint64_t sim_time = 0;

void reset(Vtop& dut)
{
    dut.reset = 1;
    dut.clk = 1;    // starting from low level

    while (sim_time < 10)
    {
        dut.clk ^= 1;
        dut.eval();
        sim_time++;
    }
    
    dut.reset = 0;
}

void one_cycle(Vtop& dut)
{
    /* level low */
    dut.clk ^= 1;
    dut.eval();
    sim_time++;

    /* level high */
    dut.clk ^= 1;
    dut.eval();
    sim_time++;
}

void print_gpr()
{
    int gpr[32];
    get_gpr(gpr);
    for (int i = 0; i < NUM_REGS; i++)
    {
        std::cout << "x" << i << ": " << gpr[i] << std::endl;
    }
}

void print_pc()
{
    int pc_value;
    get_pc(&pc_value);
    std::cout << "PC: " << pc_value << std::endl;
}

bool is_ebreak()
{
    int pc_value;
    uint32_t instr;
    get_pc(&pc_value);
    
    instr = pmem_read(pc_value);

    return (instr == 0x00100073);
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

    reset(dut);
    
    while (!is_ebreak())
    {
        one_cycle(dut);
        print_pc();
        print_gpr();
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