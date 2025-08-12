`timescale 1ns/1ps

module tb_round_robin;

    // Parameters
    parameter N = 4;

    // DUT signals
    logic             clk;
    logic             rstn;
    logic [N-1:0]     req;
    logic [N-1:0]     gnt;

    // Instantiate DUT
    round_robin #(N) dut (
        .i_clk(clk),
        .i_rstn(rstn),
        .i_req(req),
        .o_gnt(gnt)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // VCD dump for waveform viewing
        $dumpfile("round_robin_tb.vcd");
        $dumpvars(0, tb_round_robin);

        // Reset
        rstn = 0;
        req  = 0;
        repeat (2) @(posedge clk);
        rstn = 1;

        // Test 1: Multiple requests active (not one-hot)
        req = 4'b1011;  // Requests from 0,1,3 are active
        repeat (8) @(posedge clk);

        // Test 2: Single request active
        req = 4'b0100;  // Only request 2 active
        repeat (4) @(posedge clk);

        // Test 3: All requests active
        req = 4'b1111;
        repeat (8) @(posedge clk);

        // Test 4: No request active
        req = 4'b0000;
        repeat (4) @(posedge clk);

        // Test 5: Changing request pattern dynamically
        req = 4'b0011;
        repeat (4) @(posedge clk);
        req = 4'b1100;
        repeat (4) @(posedge clk);

        $finish;
    end

endmodule
