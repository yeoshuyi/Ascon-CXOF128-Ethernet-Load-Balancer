SIM ?= icarus
TOPLEVEL_LANG ?= verilog

RTL_DIR = $(PWD)/../../rtl
VERILOG_SOURCES += $(RTL_DIR)/ascon_round.sv
VERILOG_SOURCES += $(RTL_DIR)/ascon_permute.sv

TOPLEVEL = ascon_permute

MODULE = verify

export WAVES = 1
include $(shell cocotb-config --makefiles)/Makefile.sim