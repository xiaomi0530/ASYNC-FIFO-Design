module sync_ptr #(
    parameter int  DATA_WIDTH = 8,
    parameter int  ADDR_WIDTH = 4,
    localparam int FIFO_DEPTH = 2**ADDR_WIDTH
)(
    input  logic qclk,
    input  logic rst_n,
    input  logic [ADDR_WIDTH:0] ptr,
    output logic [ADDR_WIDTH:0] ptr_q2   
);

    logic [ADDR_WIDTH:0] ptr_q1;

    always_ff@(posedge qclk or negedge rst_n)begin
        if(!rst_n)begin
            ptr_q1 <= {(ADDR_WIDTH+1){1'b0}};
            ptr_q2 <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            ptr_q1 <= ptr;
            ptr_q2 <= ptr_q1;
        end
    end

endmodule