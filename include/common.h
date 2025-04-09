#ifndef COMMON_H
#define COMMON_H

#include <cstdint>
#include <array>
#include <string>

using byte_t = std::uint8_t;
using half_t = std::uint16_t;
using word_t = std::uint32_t;
using sword_t = std::int32_t;
using paddr_t = std::uint32_t;

constexpr std::uint32_t MBASE{ 0x8000'0000 };
constexpr std::uint32_t MSIZE{ 1024 * 1024 }; // 1MB

constexpr std::uint32_t NUM_REGS{ 32 };

constexpr std::uint32_t XLEN{ 32 };

// ----------- regs -----------

const std::array<std::string, NUM_REGS> regs{
    "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

// ----------- log -----------

#define ANSI_FG_BLACK   "\33[1;30m"
#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_YELLOW  "\33[1;33m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_FG_MAGENTA "\33[1;35m"
#define ANSI_FG_CYAN    "\33[1;36m"
#define ANSI_FG_WHITE   "\33[1;37m"
#define ANSI_BG_BLACK   "\33[1;40m"
#define ANSI_BG_RED     "\33[1;41m"
#define ANSI_BG_GREEN   "\33[1;42m"
#define ANSI_BG_YELLOW  "\33[1;43m"
#define ANSI_BG_BLUE    "\33[1;44m"
#define ANSI_BG_MAGENTA "\33[1;45m"
#define ANSI_BG_CYAN    "\33[1;46m"
#define ANSI_BG_WHITE   "\33[1;47m"
#define ANSI_NONE       "\33[0m"

#define ANSI_FMT(str, fmt) fmt str << ANSI_NONE

#define CONFIG_DIFFTEST

#define __EXPORT __attribute__((visibility("default")))

enum DIRECTION {
    DIFFTEST_TO_DUT,
    DIFFTEST_TO_REF,
};

struct diff_context_t
{
	word_t gpr[32];
	word_t pc{ MBASE };
};

#endif // !COMMON_H