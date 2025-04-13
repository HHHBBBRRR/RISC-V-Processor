#include <iostream>
#include <iomanip>
#include <fstream>
#include <string_view>
#include <array>
#include <bitset>
#include <stdexcept>
#include <cstdlib>
#include <cassert>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <svdpi.h>
#include "./include/common.h"
#include "Vtop.h"
#include "Vtop__Dpi.h"

extern "C" {
#include <dlfcn.h>
}

std::array<uint8_t, MSIZE> mem;

std::uint32_t load_img(std::string_view filename);

vluint64_t sim_time = 0;

/* diff test */
diff_context_t dut_context;
diff_context_t ref_context;

void init_difftest(char *ref_so_file, std::string_view img, std::uint64_t img_size);
void ref_step();
void get_dut_context();
void pc_display(diff_context_t& context);
void gpr_display(diff_context_t& context);
bool check_dut_ref_regs();

void (*ref_difftest_init)(std::string_view img, std::uint64_t img_size);
void (*ref_difftest_regcpy)(diff_context_t *context, DIRECTION direction);
void (*ref_difftest_exec)(uint64_t n);

void reset(Vtop& dut)
{
    dut.reset = 1;
    dut.clk = 1;    // starting from level low

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

void dut_step(Vtop &dut)
{
    /* set scope */
    const svScope scope = svGetScopeFromName("TOP.top.processor_inst.data_path_inst.DU.GPR");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);

    do
    {
        one_cycle(dut);
    } while (!gpr_is_write());

    get_dut_context();
}

void difftest_step(Vtop& dut)
{
    uint32_t ref_pc;
    uint32_t instr;
    std::bitset<7> opcode;

    do
    {
        ref_step();
        ref_pc = ref_context.pc;
        instr = pmem_read(ref_pc);
        opcode = instr;
    } while (opcode == 0b0100011 || opcode == 0b1100011); // store or branch instr

    dut_step(dut);

    std::cout << "-------------------------------------------------------" << std::endl;
    pc_display(ref_context);
    std::cout << "NPC: " << std::endl;
    gpr_display(dut_context);
    std::cout << "SPIKE: " << std::endl;
    gpr_display(ref_context);
    std::cout << "-------------------------------------------------------" << std::endl;
}

void print_gpr()
{
    int gpr[32];

    /* set scope */
    const svScope scope = svGetScopeFromName("TOP.top.processor_inst.data_path_inst.DU.GPR");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);

    get_gpr(gpr);
    for (std::uint32_t i{}; i < NUM_REGS; ++i)
    {
        if (i == 0)
        {
            gpr[i] = 0;  // x0 register is always 0, but in hardware I use a mux to select from it.
        }
        
        std::cout << std::left << std::setw(3) << regs[i] << ": " << std::setw(10) << std::hex << gpr[i] << "\t";
        if ((i + 1) % 4 == 0)
        {
            std::cout << std::endl;
        }
    }
    std::cout << std::endl;
}

uint32_t get_pc_from_dpi()
{
    int pc_value;

    /* set scope */
    const svScope scope = svGetScopeFromName("TOP.top.processor_inst.data_path_inst.FU");
    assert(scope);  // Check for nullptr if scope not found
    svSetScope(scope);
    get_pc(&pc_value);

    return pc_value;
}

void print_pc()
{
    int pc_value = get_pc_from_dpi();

    std::cout << std::hex << ANSI_FMT("PC: " << pc_value, ANSI_BG_BLUE) << std::endl;
}

bool is_ebreak()
{
    uint32_t pc_value = ref_context.pc;
    uint32_t instr;
  
    instr = pmem_read(pc_value);

    return (instr == 0x00100073);
}

uint32_t get_a0()  // the am will set ra of main to a0 register
{
    int gpr[32];

    /* set scope */
    const svScope scope = svGetScopeFromName("TOP.top.processor_inst.data_path_inst.DU.GPR");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);

    get_gpr(gpr);

    return gpr[10]; // x10 is a0 register
}

/*
* When we get the 'ebreak' instr, it means the program ends.
* But we need to wait for the pipeline to finish.
* So add another 5 cycles.
*/
void finish_pipeline(Vtop& dut)
{   
    uint32_t cycle = 0;

    while (cycle < 5)
    {
        one_cycle(dut);
        cycle++;
        print_pc();
        print_gpr();
    }
}

void hit_good_trap()
{
    uint32_t a0_value = get_a0();
    uint32_t pc_value = get_pc_from_dpi(); 
    
    if (a0_value == 0)
    {
        std::cout << std::hex << ANSI_FMT("Hit good trap at PC = 0x" << pc_value, ANSI_FG_GREEN) << std::endl;
    }
    else
    {
        std::cout << std::hex << ANSI_FMT("Hit bad trap at PC = 0x" << pc_value, ANSI_FG_RED) << std::endl;
    }
}

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        std::cerr << "Usage: " << argv[0] << " <program> [args ...]\n";
        exit(EXIT_FAILURE);
    }

    /* init memory and load img*/
    std::uint32_t img_size = load_img(argv[1]);
    /* init difftest */
    init_difftest(argv[2], argv[1], img_size);

    Vtop dut;
    Verilated::traceEverOn(true);
    VerilatedVcdC tfp;
    dut.trace(&tfp, 5);
    tfp.open("wave.vcd");

    std::cout << "Starting simulation..." << std::endl;
    reset(dut);
    std::cout << "Finished resetting." << std::endl;
    
    while (!is_ebreak())
    {
        difftest_step(dut);
        
        if (!check_dut_ref_regs())
        {
            std::cout << ANSI_FMT("DUT and REF regs are not equal!", ANSI_FG_RED) << std::endl;
            exit(EXIT_FAILURE);
        }
    }

    std::cout << ANSI_FMT("REF hit ebreak", ANSI_FG_YELLOW) << std::endl;
    finish_pipeline(dut);

    hit_good_trap();
    
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
        //std::cout << std::hex << "Invalid address: " << addr << std::endl;
        //throw std::runtime_error("Invalid address");
        return 0;
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
        std::cout << std::hex << "Invalid address: " << addr << std::endl;
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
        std::cout << "Invalid write mask: " << std::bitset<8>(wmask) << std::endl;
        throw std::runtime_error("Invalid write mask");
    }
}

void get_dut_context()
{
    int gpr[32];

    /* set scope */
    const svScope scope = svGetScopeFromName("TOP.top.processor_inst.data_path_inst.DU.GPR");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);

    get_gpr(gpr);

    for (std::uint32_t i{}; i < NUM_REGS; ++i)
    {
        if (i == 0)
        {
            gpr[i] = 0;  // x0 register is always 0, but in hardware I use a mux to select from it.
        }
        
        dut_context.gpr[i] = gpr[i];
    }
    dut_context.pc = get_pc_from_dpi();
}

void pc_display(diff_context_t& context)
{
	std::cout << std::hex << ANSI_FMT("PC: " << context.pc, ANSI_BG_BLUE) << std::endl;
}

void gpr_display(diff_context_t& context)
{
    for (std::uint32_t i{}; i < NUM_REGS; ++i)
    {
        std::cout << std::left << std::setw(3) << regs[i] << ": " << std::setw(10) << std::hex << context.gpr[i] << "\t";
        if ((i + 1) % 4 == 0)
        {
            std::cout << std::endl;
        }
    }
    std::cout << std::endl;
}

bool check_dut_ref_regs()
{
	bool is_ok{ true };

	for (int i{}; i < NUM_REGS; i++)
	{
		if (dut_context.gpr[i] != ref_context.gpr[i])
		{
			is_ok = false;
			break;
		}
	}
	
	if (!is_ok)
	{
        /*std::cout << "DUT and REF regs are not equal!" << std::endl;
		reg_display(dut_context);
        reg_display(ref_context);*/
	}

    return is_ok;
}

void init_difftest(char *ref_so_file, std::string_view img, std::uint64_t img_size)
{
	assert(ref_so_file != NULL);

	void *handle;
	handle = dlopen(ref_so_file, RTLD_LAZY);
	assert(handle);

	ref_difftest_init = dlsym(handle, "difftest_init");
	assert(ref_difftest_init);

	ref_difftest_regcpy = dlsym(handle, "difftest_regcpy");
	assert(ref_difftest_regcpy);

	ref_difftest_exec = dlsym(handle, "difftest_exec");
	assert(ref_difftest_exec);

	ref_difftest_init(img, img_size);
	ref_difftest_regcpy(&ref_context, DIRECTION::DIFFTEST_TO_REF);
}

void ref_step()
{
	ref_difftest_exec(1);
	ref_difftest_regcpy(&ref_context, DIRECTION::DIFFTEST_TO_DUT);
}
