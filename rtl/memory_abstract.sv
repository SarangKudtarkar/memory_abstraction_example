
module memory_abstract #(
    parameter ADDR_W = 4,
    parameter DATA_W = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  wr_en,
    input  logic [ADDR_W-1:0]     wr_addr,
    input  logic [DATA_W-1:0]     wr_data,

    input  logic                  rd_en,
    input  logic [ADDR_W-1:0]     rd_addr,

    input  logic [ADDR_W-1:0]     tracked_addr,

    // Arbitrary data for reads to untracked locations.
    input  logic [DATA_W-1:0]     untracked_read_data,

    output logic [DATA_W-1:0]     rd_data,
    output logic                  rd_valid
);

    // Only ONE memory location is modeled.
    logic [DATA_W-1:0] tracked_data;

    // Two-cycle read pipeline.
    logic [DATA_W-1:0] read_stage0;
    logic [DATA_W-1:0] read_stage1;

    logic valid_stage0;
    logic valid_stage1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tracked_data <= '0;

            read_stage0 <= '0;
            read_stage1 <= '0;
            rd_data     <= '0;

            valid_stage0 <= 1'b0;
            valid_stage1 <= 1'b0;
            rd_valid     <= 1'b0;
        end
        else begin

            // Track writes only to the symbolic address.
            if (wr_en && (wr_addr == tracked_addr))
                tracked_data <= wr_data;

            // Read behavior:
            // Tracked address -> tracked memory data.
            // Other addresses -> unconstrained data.
            if (rd_en) begin
                if (rd_addr == tracked_addr)
                    read_stage0 <= tracked_data;
                else
                    read_stage0 <= untracked_read_data;
            end

            // Preserve the two-cycle read pipeline.
            read_stage1 <= read_stage0;
            rd_data     <= read_stage1;

            valid_stage0 <= rd_en;
            valid_stage1 <= valid_stage0;
            rd_valid     <= valid_stage1;
        end
    end

endmodule

