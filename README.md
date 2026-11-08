
# Memory Abstraction Example

This repository demonstrates single-address memory abstraction
for formal verification using Cadence JasperGold.

## Objective

Reduce memory complexity by tracking only one symbolic
memory address rather than modeling every memory location.

## Example memory

- Number of locations: 16
- Address width: 4 bits
- Data width: 8 bits
- Read latency: 2 cycles
- Read-during-write behavior: READ-FIRST

## Repository contents

rtl/memory_concrete.sv
    Concrete 16-location memory implementation.

rtl/memory_abstract.sv
    Abstract memory implementation tracking one location.

formal/memory_abstraction_formal_top.sv
    Formal harness with symbolic address and arbitrary inputs.

scripts/memory_abstraction.tcl
    JasperGold proof and cover script.

## Abstraction strategy

The formal harness declares:

    (* anyconst *) logic [3:0] tracked_addr;

This address is symbolic and remains constant within a formal
trace. Formal analysis can select any legal address value.

### Writes

If:

    wr_en && (wr_addr == tracked_addr)

then the abstract memory updates tracked_data.

Writes to other addresses are not modeled.

### Reads

If:

    rd_en && (rd_addr == tracked_addr)

then the read pipeline receives tracked_data.

For reads to other addresses, the pipeline receives
unconstrained symbolic data.

Untracked reads are not tied to zero.

### Read latency

The abstraction preserves the two-cycle response pipeline
of the example concrete memory.

### Read-during-write

The example uses READ-FIRST behavior: a read and write to
the same tracked address on the same clock edge return
the old stored value.

The abstract model must match the actual memory's
read-during-write semantics.

## Run

From the repository root, launch JasperGold and source:

    source scripts/memory_abstraction.tcl

## Important limitations

This example proves properties of the abstract memory model.
It does not automatically establish equivalence between the
abstract model and the concrete memory.

Before using this technique on a real design:

1. Identify every address relevant to the property.
2. Confirm that one symbolic address is sufficient.
3. Preserve read and write latency.
4. Preserve read-during-write semantics.
5. Do not constrain untracked read data unless justified.
6. Consider whether untracked locations can influence
   the property through other logic.

The symbolic address represents one arbitrary address per
formal trace. It does not mean all addresses are tracked
simultaneously in one trace.

For stronger validation, prove the required correspondence
between the concrete memory and the abstract model, or use
the appropriate JasperGold memory abstraction and cutpoint
methodology for your design.

