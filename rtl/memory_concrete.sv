
module memory_concrete #(
    parameter ADDR_W = 4,
    parameter DATA_W = 8,
    parameter DEPTH  = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  wr_en,
    input  logic [ADDR_W-1:0]     wr_addr,
    input  logic [DATA_W-1:0]     wr_data,

    input  logic                  rd_en,
    input  logic [ADDR_W-1:0]     rd_addr,

    output logic [DATA_W-1:0]     rd_data,
    output logic                  rd_valid
);

    logic [DATA_W-1:0] mem [0:DEPTH-1];

    logic [DATA_W-1:0] read_stage0;
    logic [DATA_W-1:0] read_stage1;

    logic valid_stage0;
    logic valid_stage1;

    // Memory write and two-cycle read pipeline.
    // Read-during-write to the same address is READ-FIRST.

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_stage0 <= '0;
            read_stage1 <= '0;
            rd_data     <= '0;

            valid_stage0 <= 1'b0;
            valid_stage1 <= 1'b0;
            rd_valid     <= 1'b0;
        end
        else begin

            if (wr_en)
                mem[wr_addr] <= wr_data;

            if (rd_en)
                read_stage0 <= mem[rd_addr];

            read_stage1 <= read_stage0;
            rd_data      <= read_stage1;

            valid_stage0 <= rd_en;
            valid_stage1 <= valid_stage0;
            rd_valid     <= valid_stage1;
        end
    end

endmodule

