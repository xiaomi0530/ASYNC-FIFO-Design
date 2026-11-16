module wptr_full #(
    parameter int  DATA_WIDTH = 8,
    parameter int  ADDR_WIDTH = 4,
    localparam int FIFO_DEPTH = 2**ADDR_WIDTH
)(
    input  logic wclk,
    input  logic rst_n,
    input  logic w_en,
    input  logic [ADDR_WIDTH:0] rgray_ptr_q2,
    output logic [ADDR_WIDTH:0] wbin_ptr, 
    output logic [ADDR_WIDTH:0] wgray_ptr, 
    output logic wfull
);

    localparam logic [ADDR_WIDTH:0] FULL_MASK =
            {2'b11, {(ADDR_WIDTH-1){1'b0}}};

    logic [ADDR_WIDTH:0] wbin_ptr_next;
    logic [ADDR_WIDTH:0] wgray_ptr_next;
    logic wfull_next;

    assign wbin_ptr_next  = wbin_ptr + (w_en && !wfull);
    assign wgray_ptr_next = (wbin_ptr_next >> 1) ^ wbin_ptr_next;
    assign wfull_next     = (wgray_ptr_next == (rgray_ptr_q2 ^ FULL_MASK));
    
    always_ff@(posedge wclk or negedge rst_n)begin
        if(!rst_n)begin
            wbin_ptr  <= {(ADDR_WIDTH+1){1'b0}};
            wgray_ptr <= {(ADDR_WIDTH+1){1'b0}};
            wfull     <= 1'b0;
        end else begin
            wbin_ptr  <= wbin_ptr_next;
            wgray_ptr <= wgray_ptr_next;
            wfull     <= wfull_next;
        end
    end

endmodule