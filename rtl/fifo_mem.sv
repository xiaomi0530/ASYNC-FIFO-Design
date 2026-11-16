module fifo_mem #(
    parameter int  DATA_WIDTH = 8,
    parameter int  ADDR_WIDTH = 4,
    localparam int FIFO_DEPTH = 2**ADDR_WIDTH
)(
    input  logic wclk,
    input  logic rclk,
    input  logic w_en,
    input  logic r_en,
    input  logic [ADDR_WIDTH-1:0] w_addr,
    input  logic [ADDR_WIDTH-1:0] r_addr,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data
);

    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    always_ff@(posedge wclk) begin
        if(w_en)begin
            mem[w_addr] <= w_data;
        end
    end

    always_ff@(posedge rclk) begin
        if(r_en)begin
            r_data <= mem[r_addr];
        end
    end

endmodule