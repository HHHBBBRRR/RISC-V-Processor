MODULE := top
CURRENT_DIR := $(shell pwd)
SRC_DIR := $(CURRENT_DIR)/src

# Spike Variables
SPIKE_SRC_DIR = $(CURRENT_DIR)/spike
SPIKE_BUILD_DIR = $(CURRENT_DIR)/spike_build
SPIKE_MAKEFILE = $(SPIKE_BUILD_DIR)/Makefile
SPIKE_LIBS = libspike_main.a libriscv.a libdisasm.a libsoftfloat.a libfesvr.a libfdt.a
SPIKE_INC_LIBS = $(addprefix $(SPIKE_BUILD_DIR)/, $(SPIKE_LIBS))
SPIKE_IMG = $(SPIKE_BUILD_DIR)/riscv32-spikes-so

.PHONY: verilate
verilate:
	@echo "### VERILATING ###"
	verilator --cc $(SRC_DIR)/$(MODULE).sv -I$(SRC_DIR)

.PHONY: build
build:
	@echo "### BUILDING ###"
	verilator --cc $(SRC_DIR)/$(MODULE).sv -I$(SRC_DIR) \
		--exe sim_main.cpp \
		--trace \
		--build \
		-CFLAGS -std=c++20 \
		-CFLAGS -fpermissive \
		-j 0

.PHONY:lint
lint:
	@echo "### LINTING ###"
	verilator --lint-only $(SRC_DIR)/$(MODULE).sv -I$(SRC_DIR)

.PHONY: run
run:
	@echo "### RUNNING ###"
	./obj_dir/V$(MODULE)

.PHONY: wave
wave:
	@echo "### WAVE ###"
	gtkwave wave.vcd

#########
# Spike
#########
.PHONY: spike
spike: $(SPIKE_MAKEFILE)
	$(MAKE) -C $(SPIKE_BUILD_DIR) O=$(SPIKE_BUILD_DIR) -j 4 \
	CXXFLAGS="-fvisibility=hidden"
	$(CXX) -std=c++20 -O2 -shared -fPIC -fvisibility=hidden $(SPIKE_BUILD_DIR)/difftest.o $(SPIKE_INC_LIBS) -o $(SPIKE_IMG)

$(SPIKE_MAKEFILE):
	mkdir -p $(@D)
	cd $(SPIKE_BUILD_DIR) && $(SPIKE_SRC_DIR)/configure

.PHONY: clean spike-clean
clean:
	rm -rf ./obj_dir
	rm -rf wave.vcd

spike-clean:
	rm -rf $(SPIKE_BUILD_DIR)