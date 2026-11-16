module async_fifo_top #(
    parameter int  DATA_WIDTH = 8,
    parameter int  ADDR_WIDTH = 4,
    localparam int FIFO_DEPTH = 2**ADDR_WIDTH
)(
    input  logic wclk,
    input  logic rclk,
    input  logic rst_n,
    input  logic w_en,
    input  logic r_en,
    output logic r_valid,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic wfull,
    output logic rempty
);

    logic [ADDR_WIDTH:0] rbin_ptr;
    logic [ADDR_WIDTH:0] rgray_ptr;
    logic [ADDR_WIDTH:0] rgray_ptr_q2;

    logic [ADDR_WIDTH:0] wbin_ptr;
    logic [ADDR_WIDTH:0] wgray_ptr;
    logic [ADDR_WIDTH:0] wgray_ptr_q2;

    logic rrst_n_q2;
    logic wrst_n_q2;

    fifo_mem 
    #(
        .DATA_WIDTH (DATA_WIDTH ),
        .ADDR_WIDTH (ADDR_WIDTH )
    )
    u_fifo_mem(
        .wclk   (wclk                           ),
        .rclk   (rclk                           ),
        .w_en   (wrst_n_q2 && w_en && !wfull    ),  
        .r_en   (rrst_n_q2 && r_en && !rempty   ),
        .w_addr (wbin_ptr[ADDR_WIDTH-1:0]       ),
        .r_addr (rbin_ptr[ADDR_WIDTH-1:0]       ),
        .w_data (w_data                         ),
        .r_data (r_data                         )
    );

    sync_ptr 
    #(
        .DATA_WIDTH (DATA_WIDTH ),
        .ADDR_WIDTH (ADDR_WIDTH )
    )
    u_sync_rptr(
        .qclk   (wclk           ),
        .rst_n  (wrst_n_q2      ),
        .ptr    (rgray_ptr      ),
        .ptr_q2 (rgray_ptr_q2   )
    );

    sync_ptr 
    #(
        .DATA_WIDTH (DATA_WIDTH ),
        .ADDR_WIDTH (ADDR_WIDTH )
    )
    u_sync_wptr(
        .qclk   (rclk           ),
        .rst_n  (rrst_n_q2      ),
        .ptr    (wgray_ptr      ),
        .ptr_q2 (wgray_ptr_q2   )
    );

    sync_rstn u_sync_wrstn(
        .clk      (wclk      ),
        .rst_n    (rst_n    ),
        .rst_n_q2 (wrst_n_q2 )
    );

    sync_rstn u_sync_rrstn(
        .clk      (rclk      ),
        .rst_n    (rst_n    ),
        .rst_n_q2 (rrst_n_q2 )
    );
    
    wptr_full 
    #(
        .DATA_WIDTH (DATA_WIDTH ),
        .ADDR_WIDTH (ADDR_WIDTH )
    )
    u_wptr_full(
        .wclk         (wclk         ),
        .rst_n        (wrst_n_q2    ),
        .w_en         (w_en         ),
        .rgray_ptr_q2 (rgray_ptr_q2 ),
        .wbin_ptr     (wbin_ptr     ),
        .wgray_ptr    (wgray_ptr    ),
        .wfull        (wfull        )
    );
    
    rptr_empty 
    #(
        .DATA_WIDTH (DATA_WIDTH ),
        .ADDR_WIDTH (ADDR_WIDTH )
    )
    u_rptr_empty(
        .rclk         (rclk         ),
        .rst_n        (rrst_n_q2    ),
        .r_en         (r_en         ),
        .wgray_ptr_q2 (wgray_ptr_q2 ),
        .rbin_ptr     (rbin_ptr     ),
        .rgray_ptr    (rgray_ptr    ),
        .rempty       (rempty       )
    );
    
    
    always_ff@(posedge rclk or negedge rrst_n_q2)begin
        if(!rrst_n_q2)begin
            r_valid <= 1'b0;
        end else begin
            r_valid <= r_en && !rempty;
        end
    end

endmodule 