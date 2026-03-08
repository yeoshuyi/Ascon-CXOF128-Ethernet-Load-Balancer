SIM ?= icarus
TOPLEVEL_LANG ?= verilog

RTL_DIR = $(PWD)/../../rtl

VERILOG_SOURCES += $(RTL_DIR)/ascon_permute.sv
VERILOG_SOURCES += $(RTL_DIR)/ascon.sv

TOPLEVEL = ascon
MODULE = ascon

export WAVES = 1

ifeq ($(SIM),icarus)
    PLUSARGS += -fst
endif

include $(shell cocotb-config --makefiles)/Makefile.sim