
# ================================================
# MEMORY ABSTRACTION EXAMPLE
# Cadence JasperGold
# ================================================

clear -all

# The formal run uses the abstract memory model.
# The concrete memory RTL is provided for comparison
# and is intentionally not instantiated in this run.

analyze -sv12 \
    ../rtl/memory_abstract.sv \
    ../formal/memory_abstraction_formal_top.sv

# Specify the formal top.
elaborate -top memory_abstraction_formal_top

clock clk
reset -expression {!rst_n}

# Run proofs and reachability checks.
prove -all
cover -all

report -summary
report -results

exit

