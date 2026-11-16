module rptr_empty #(
    parameter int  DATA_WIDTH = 8,
    parameter int  ADDR_WIDTH = 4,
    localparam int FIFO_DEPTH = 2**ADDR_WIDTH
)(
    input  logic rclk,
    input  logic rst_n,
    input  logic r_en,
    input  logic [ADDR_WIDTH:0] wgray_ptr_q2,
    output logic [ADDR_WIDTH:0] rbin_ptr, 
    output logic [ADDR_WIDTH:0] rgray_ptr, 
    output logic rempty
);

    logic [ADDR_WIDTH:0] rbin_ptr_next;
    logic [ADDR_WIDTH:0] rgray_ptr_next;
    logic rempty_next;

    assign rbin_ptr_next  = rbin_ptr + (r_en && !rempty);
    assign rgray_ptr_next = (rbin_ptr_next >> 1) ^ rbin_ptr_next;
    assign rempty_next    = rgray_ptr_next == wgray_ptr_q2;
    
    always_ff@(posedge rclk or negedge rst_n)begin
        if(!rst_n)begin
            rbin_ptr  <= {(ADDR_WIDTH+1){1'b0}};
            rgray_ptr <= {(ADDR_WIDTH+1){1'b0}};
            rempty    <= 1'b1;
        end else begin
            rbin_ptr  <= rbin_ptr_next;
            rgray_ptr <= rgray_ptr_next;
            rempty    <= rempty_next;
        end
    end

endmodule