# ============================================================================ #
#                                   Variables                                  #
# ============================================================================ #
CPPFLAGS =#                 Flags for the C preprocessor
CXX      = g++#             Program for compiling C++ programs; default g++
CC       = gcc#             Program for compiling C programs; default cc
CXXFLAGS = -Wall\
           -std=c++17\
           -march=native\
           -fno-diagnostics-show-caret\
           -fdiagnostics-color=always\
           -I com/\
           -g#                               Flags for the C++ compiler
LDFLAGS  =#                                  Flags for compilers when they invoke the linker

BUILD_DIR = build#                           Build directory
SRC_DIR   = src#                             Source files directory
COM_DIR   = com#                             Common files directory
VPATH     = $(SRC_DIR):$(COM_DIR):$(TESTS_DIR)
TESTS_DIR = tests#                           Test files directory
SRC_CPP   = $(wildcard $(SRC_DIR)/*.cpp)#    Match all .cpp files in ./src/
COM_CPP   = $(wildcard $(COM_DIR)/*.cpp)#    Match all .cpp files in ./com/
TESTS_CPP = $(wildcard $(TESTS_DIR)/*.cpp)#  Match all .cpp files in ./tests/

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
EXEC_BASE = ProjectName
EXEC      = $(BUILD_DIR)/$(EXEC_BASE)$(EXT)
TEST_EXEC = $(BUILD_DIR)/$(EXEC_BASE)_Tests$(EXT)
# ============================================================================ #
#                                 Build Targets                                #
# ============================================================================ #
.PHONY: all Prologue Program UnitTests
all: Prologue UnitTests Program

Program: $(EXEC)

UnitTests: $(TEST_EXEC)

Prologue:
	@printf "$(RED)CXXFLAGS: $(CXXFLAGS)\nLDFLAGS: $(LDFLAGS)\n"

# ------------------------------ Program Linkage ----------------------------- #
$(EXEC): $(SRC_OBJS) $(COM_OBJS)
	@$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)
	@printf "$(GREEN)Linking $(@F): $(^F)\n"

# ----------------------------- Unit Test Linkage ---------------------------- #
$(TEST_EXEC): $(TESTS_OBJS) $(COM_OBJS)
	@$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)
	@printf "$(GREEN)Linking $(@F): $(^F)\n"

# ---------------------------- Compile Source Code --------------------------- #
# Compile .cpp files into .obj files and create .d files to trigger
# recompilation if headers change
# ---------------------------------------------------------------------------- #
$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	@$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@
	@printf "$(YELLOW)Compiling $(<F)\n"

# ----------------------------------- Debug ---------------------------------- #
.PHONY: debug
debug:
	@printf "OS: %s\n" $(OS)
	@printf "EXE: %s\n" $(EXEC)

	@printf "CXXFLAGS: "
	@printf "%s" $(CXXFLAGS)

	@printf "\nLDFLAGS: "
	@printf "%s\n" $(LDFLAGS)

	@printf "\nSRC_CPP:\n"
	@printf "%s\n" $(SRC_CPP)

	@printf "\nCOM_CPP:\n"
	@printf "%s\n" $(COM_CPP)

	@printf "\nTESTS_CPP:\n"
	@printf "%s\n" $(TESTS_CPP)

	@printf "\nSRC_OBJS:\n"
	@printf "%s\n" $(SRC_OBJS)

	@printf "\nCOM_OBJS:\n"
	@printf "%s\n" $(COM_OBJS)

	@printf "\nTESTS_OBJS:\n"
	@printf "%s\n" $(TESTS_OBJS)

	@printf "\nSRC_DEPS:\n"
	@printf "%s\n" $(SRC_DEPS)

# ---------------------------------- Utility --------------------------------- #
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*

# -------------------------- Generated Dependencies -------------------------- #
# Include .d files. The - in front mutes errors of missing makefiles. At first,
# all .d files are missing and we don't want those errors to pop up
# ---------------------------------------------------------------------------- #
-include $(SRC_DEPS)
-include $(COM_DEPS)
-include $(TESTS_DEPS)
