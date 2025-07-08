module tb_round_robin;

  parameter N = 4;  // Change this value for different number of requesters

  // Clock and Reset
  logic i_clk;
  logic i_rstn;

  // DUT Inputs
  logic i_en;
  logic [N-1:0] i_req;

  // DUT Outputs
  logic [N-1:0] o_gnt;

  // Clock generation
  initial i_clk = 0;
  always #5 i_clk = ~i_clk;

  // DUT Instantiation
  round_robin #(.N(N)) dut (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_en(i_en),
    .i_req(i_req),
    .o_gnt(o_gnt)
  );

  // Assertion: o_gnt must be one-hot when i_en is high and i_req is non-zero
  property onehot_grant;
    @(posedge i_clk) disable iff (!i_rstn)
      i_en && (i_req != 0) |-> $onehot(o_gnt);
  endproperty

  assert property (onehot_grant)
    else $error("Assertion failed: o_gnt is not one-hot when i_en = 1 and i_req != 0");

  // Stimulus
  initial begin
    i_rstn = 0;
    i_en   = 0;
    i_req  = '0;

    repeat (2) @(posedge i_clk);
    i_rstn = 1;

    @(posedge i_clk);
    i_en = 1;

    // Random requests
    repeat (20) begin
      @(posedge i_clk);
      i_req = $urandom_range(1, (1 << N) - 1);  // Ensure at least one bit set
      $display("Time: %0t | Req: %b | Gnt: %b", $time, i_req, o_gnt);
    end

    $finish;
  end

endmodule
