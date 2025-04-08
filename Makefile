MODULE := top
CURRENT_DIR := $(shell pwd)
SRC_DIR := $(CURRENT_DIR)/src

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

.PHONY: clean
clean:
	rm -rf ./obj_dir
	rm -rf wave.vcd
