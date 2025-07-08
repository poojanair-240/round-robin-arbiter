module round_robin #(parameter N = 4) (
    input  logic             i_clk,
    input  logic             i_rstn,
    input  logic             i_en,
    input  logic [N-1:0]     i_req,
    output logic [N-1:0]     o_gnt
);

    localparam M = $clog2(N);

    logic [M-1:0] ptr;
    logic [M-1:0] ptr_arb;

    logic [N-1:0] tmp_r, tmp_l, rotate_r;
    logic [N-1:0] priority_out;
    logic [N-1:0] gnt;

    // Rotate right
    assign {tmp_r, rotate_r} = {2{i_req}} >> ptr;

    // Priority encoder logic (one-hot for lowest 1)
    assign priority_out = rotate_r & ~(rotate_r - 1);

    // Rotate left to restore grant position
    assign {gnt, tmp_l} = {2{priority_out}} << ptr;

    // Get the granted index
    always_comb begin
        ptr_arb = ptr;
        for (int i = 0; i < N; i++) begin
            if (gnt[i])
                ptr_arb = i;
        end
    end

    // Sequential logic
    always_ff @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            ptr    <= '0;
            o_gnt  <= '0;
        end else if (i_en) begin
            ptr    <= (ptr_arb == N-1) ? '0 : ptr_arb + 1;
            o_gnt  <= gnt;
        end
    end

endmodule
