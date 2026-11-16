//GPT-6-Astra生成临时验证tb喵~
`timescale 1ns/1ps

module tb_async_fifo;
    parameter int ADDR_WIDTH = 4;
    localparam int DEPTH = 2**ADDR_WIDTH;

    logic wclk = 0, rclk = 0, rst_n = 1;
    logic w_en = 0, r_en = 0;
    logic [7:0] w_data = 0;
    wire [7:0] r_data;
    wire wfull, rempty, r_valid;

    async_fifo_top #(.DATA_WIDTH(8), .ADDR_WIDTH(ADDR_WIDTH)) dut (.*);
    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;

    // Reference FIFO: only accepted writes/reads advance these indices.
    logic [7:0] expected [0:65535];
    int wr = 0, rd = 0;
    bit take_read;
    logic [7:0] want;

    // Drive data away from the sampling edge.
    always @(negedge wclk) w_data = $urandom;

    always @(posedge wclk) begin
        if (dut.wrst_n_q2 && w_en && !wfull) begin
            if (wr >= 65536) $fatal(1, "Reference buffer exhausted");
            expected[wr] = w_data;
            wr++;
        end
    end

    always @(posedge rclk) begin
        take_read = dut.rrst_n_q2 && r_en && !rempty;
        if (take_read) begin
            if (rd >= wr) $fatal(1, "Read from empty reference FIFO");
            want = expected[rd];
            rd++;
        end
        #1; // Wait for DUT nonblocking assignments.
        if (r_valid !== take_read) $fatal(1, "r_valid mismatch");
        if (take_read && r_data !== want)
            $fatal(1, "Data mismatch: got=%h expected=%h", r_data, want);
    end

    task automatic reset_fifo;
        // Assert between clock edges; reset must act without a new edge.
        @(negedge rclk);
        w_en = 0; r_en = 0;
        #2; rst_n = 0;
        #1;
        if ({dut.wrst_n_q2, dut.rrst_n_q2, wfull, rempty, r_valid}
            !== 5'b00010)
            $fatal(1, "Asynchronous reset failed");
        wr = 0; rd = 0;
        #30; rst_n = 1;
        fork
            begin
                @(posedge wclk); #1;
                if (dut.wrst_n_q2 !== 0) $fatal(1, "Write reset released early");
                @(posedge wclk); #1;
                if (dut.wrst_n_q2 !== 1) $fatal(1, "Write reset not released");
            end
            begin
                @(posedge rclk); #1;
                if (dut.rrst_n_q2 !== 0) $fatal(1, "Read reset released early");
                @(posedge rclk); #1;
                if (dut.rrst_n_q2 !== 1) $fatal(1, "Read reset not released");
            end
        join
    endtask

    task automatic fill_fifo;
        @(negedge wclk); w_en = 1;
        repeat (DEPTH + 8) @(negedge wclk);
        w_en = 0;
        if (wfull !== 1 || wr-rd != DEPTH)
            $fatal(1, "Full/overflow check failed");
    endtask

    task automatic drain_fifo;
        @(negedge rclk); r_en = 1;
        repeat (DEPTH + 8) @(negedge rclk);
        r_en = 0;
        if (rempty !== 1 || wr != rd)
            $fatal(1, "Empty/drain check failed");
    endtask

    initial begin
        reset_fifo();
        drain_fifo(); // Read requests while empty.
        fill_fifo();  // Extra write requests while full.
        drain_fifo();

        // Concurrent reads/writes exercise repeated pointer wraparound.
        @(negedge wclk); w_en = 1;
        @(negedge rclk); r_en = 1;
        repeat (1000) @(negedge wclk);
        w_en = 0;
        drain_fifo();

        fill_fifo();
        reset_fifo(); // Discard pending data, then verify fresh traffic.
        fill_fifo();
        drain_fifo();
        $display("PASS: depth=%0d reset/full/empty/wrap/data/r_valid", DEPTH);
        $finish;
    end

    initial begin
        #1000000;
        $fatal(1, "Simulation timeout");
    end
endmodule
