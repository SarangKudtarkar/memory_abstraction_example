
module memory_abstraction_formal_top (
    input logic clk,
    input logic rst_n
);

    localparam ADDR_W = 4;
    localparam DATA_W = 8;

    // Symbolic memory interface inputs.
    (* anyseq *) logic                  wr_en;
    (* anyseq *) logic [ADDR_W-1:0]     wr_addr;
    (* anyseq *) logic [DATA_W-1:0]     wr_data;

    (* anyseq *) logic                  rd_en;
    (* anyseq *) logic [ADDR_W-1:0]     rd_addr;

    // One arbitrary symbolic address.
    // It is selected freely by formal analysis.
    (* anyconst *) logic [ADDR_W-1:0] tracked_addr;

    // Arbitrary data for all untracked memory reads.
    (* anyseq *) logic [DATA_W-1:0] untracked_read_data;

    logic [DATA_W-1:0] rd_data;
    logic              rd_valid;

    memory_abstract #(
        .ADDR_W (ADDR_W),
        .DATA_W (DATA_W)
    ) u_memory_abstract (
        .clk                 (clk),
        .rst_n               (rst_n),

        .wr_en               (wr_en),
        .wr_addr             (wr_addr),
        .wr_data             (wr_data),

        .rd_en               (rd_en),
        .rd_addr             (rd_addr),

        .tracked_addr        (tracked_addr),
        .untracked_read_data (untracked_read_data),

        .rd_data             (rd_data),
        .rd_valid            (rd_valid)
    );

    // ------------------------------------------------
    // PROPERTY 1:
    // A read request eventually produces a valid response
    // after the modeled two-cycle latency.
    // ------------------------------------------------
    P_READ_RESPONSE:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            rd_en |-> ##2 rd_valid
        );

    // ------------------------------------------------
    // PROPERTY 2:
    // A response must correspond to a read request
    // from two cycles earlier.
    // ------------------------------------------------
    P_READ_VALID_ALIGNMENT:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            rd_valid |-> $past(rd_en, 2)
        );

    // ------------------------------------------------
    // COVERAGE
    // ------------------------------------------------

    // Write to the tracked address.
    C_TRACKED_WRITE:
        cover property (@(posedge clk)
            disable iff (!rst_n)
            wr_en && (wr_addr == tracked_addr)
        );

    // Read from the tracked address.
    C_TRACKED_READ:
        cover property (@(posedge clk)
            disable iff (!rst_n)
            rd_en && (rd_addr == tracked_addr)
        );

    // Read from an untracked address.
    C_UNTRACKED_READ:
        cover property (@(posedge clk)
            disable iff (!rst_n)
            rd_en && (rd_addr != tracked_addr)
        );

    // Simultaneous tracked read and write.
    C_TRACKED_READ_WRITE:
        cover property (@(posedge clk)
            disable iff (!rst_n)
            wr_en && rd_en &&
            (wr_addr == tracked_addr) &&
            (rd_addr == tracked_addr)
        );

endmodule

