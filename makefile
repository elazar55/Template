# ============================================================================ #
#                                   Variables                                  #
# ============================================================================ #
CPPFLAGS =#     Flags for the C preprocessor
CXX      = g++# Program for compiling C++ programs; default g++
CC       = gcc# Program for compiling C programs; default cc

# Flags for the C++ compiler
CXXFLAGS = -g\
           -Wall\
           -std=c++17\
           -march=native\
           -fdiagnostics-color=always\
           -fno-diagnostics-show-caret\
           -Icom

# Flags for the linker
LDFLAGS  =

BUILD_DIR = build#                              Build directory
SRC_DIR   = src#                                Source files directory
COM_DIR   = com#                                Common files directory
TESTS_DIR = tests#                              Test files directory
SRC_CPP   = $(wildcard $(SRC_DIR)/*.cpp)#       Match all .cpp files in ./src/
COM_CPP   = $(wildcard $(COM_DIR)/*.cpp)#       Match all .cpp files in ./com/
TESTS_CPP = $(wildcard $(TESTS_DIR)/*.cpp)#     Match all .cpp files in ./tests/
VPATH     = $(SRC_DIR):$(COM_DIR):$(TESTS_DIR)# Search path for Prerequisites

# Generate build file list with string substitution
SRC_OBJS   = $(SRC_CPP:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)
COM_OBJS   = $(COM_CPP:$(COM_DIR)/%.cpp=$(BUILD_DIR)/%.o)
TESTS_OBJS = $(TESTS_CPP:$(TESTS_DIR)/%.cpp=$(BUILD_DIR)/%.o)
SRC_DEPS   = $(SRC_CPP:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.d)
COM_DEPS   = $(COM_CPP:$(COM_DIR)/%.cpp=$(BUILD_DIR)/%.d)
TESTS_DEPS = $(TESTS_CPP:$(TESTS_DIR)/%.cpp=$(BUILD_DIR)/%.d)

# Append executable extension for Windows
ifeq ($(OS),Windows_NT)
	EXT = .exe
endif

# Colors
COLOR_OFF = \033[0m
RED		  = \033[0;31m
GREEN	  = \033[0;32m
YELLOW	  = \033[0;33m
BLUE	  = \033[0;34m
PURPLE	  = \033[0;35m
CYAN	  = \033[0;36m

# Executable names
EXEC_BASE = App
EXEC      = $(BUILD_DIR)/$(EXEC_BASE)$(EXT)
TEST_EXEC = $(BUILD_DIR)/$(EXEC_BASE)Tests$(EXT)

# ============================================================================ #
#                                 Build Targets                                #
# ============================================================================ #
.PHONY: all prologue unitTests program debug clean
all: prologue unitTests program

unitTests: $(TEST_EXEC)

program: $(EXEC)

prologue:
	@clear
	@printf "$(CYAN)CXXFLAGS: $(CXXFLAGS)\n"
	@printf "$(CYAN)LDFLAGS : $(LDFLAGS)\n"

# ----------------------------- Unit Test Linkage ---------------------------- #
$(TEST_EXEC): $(TESTS_OBJS) $(COM_OBJS)
	@$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)
	@printf "$(GREEN)Linking $(^F) => $(@F)\n"

# ------------------------------ Program Linkage ----------------------------- #
$(EXEC): $(SRC_OBJS) $(COM_OBJS)
	@$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)
	@printf "$(GREEN)Linking $(^F) => $(@F)\n"

# ---------------------------- Compile Source Code --------------------------- #
# Compile .cpp files into .obj files and create .d files to trigger
# recompilation if headers change
# ---------------------------------------------------------------------------- #
$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	@$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@
	@printf "$(YELLOW)Compiling $(<F)\n"

# ----------------------------------- Debug ---------------------------------- #
debug:
	@printf "$(BLUE)"
	@printf "%-10s: $(OS)\n" OS
	@printf "%-10s: $(EXEC)\n" EXE
	@printf "%-10s: $(CXXFLAGS)\n" CXXFLAGS
	@printf "%-10s: $(LDFLAGS)\n" LDFLAGS
	@printf "%-10s: $(SRC_CPP)\n" SRC_CPP
	@printf "%-10s: $(COM_CPP)\n" COM_CPP
	@printf "%-10s: $(TESTS_CPP)\n" TESTS_CPP
	@printf "%-10s: $(SRC_OBJS)\n" SRC_OBJS
	@printf "%-10s: $(COM_OBJS)\n" COM_OBJS
	@printf "%-10s: $(TESTS_OBJS)\n" TESTS_OBJS
	@printf "%-10s: $(SRC_DEPS)\n" SRC_DEPS

# ---------------------------------- Utility --------------------------------- #
clean:
	rm -rf $(BUILD_DIR)/*

# -------------------------- Generated Dependencies -------------------------- #
# Include .d files. The - in front mutes errors of missing makefiles. At first,
# all .d files are missing and we don't want those errors to pop up
# ---------------------------------------------------------------------------- #
-include $(SRC_DEPS)
-include $(COM_DEPS)
-include $(TESTS_DEPS)
