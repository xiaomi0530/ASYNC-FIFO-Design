module sync_rstn (
    input  logic clk,
    input  logic rst_n,
    output logic rst_n_q2
);

    logic rst_n_q1;

    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            rst_n_q1 <= 1'b0;
            rst_n_q2 <= 1'b0;
        end else begin
            rst_n_q1 <= rst_n;
            rst_n_q2 <= rst_n_q1;
        end
    end

endmodule