module round_robin #(parameter N = 4) (
    input  logic             i_clk,
    input  logic             i_rstn,
    input  logic [N-1:0]     i_req,
    output logic [N-1:0]     o_gnt
);

    // State register (current grant) and next-state variable
    logic [N-1:0] current_gnt, next_gnt;
    logic [$clog2(N)-1:0] index;
integer idx;
    // Sequential: update current grant on clock edge
    always_ff @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn)
            current_gnt <= '0;
        else
            current_gnt <= next_gnt;
    end

    // Output assignment
    assign o_gnt = current_gnt;

    // Combinational: decide next grant
    always_comb begin
        next_gnt = '0; // default
        if (i_req != 0) begin
            if (current_gnt == 0) begin
                // No current grant, pick first active request
                for (int i = 0; i < N; i++) begin
                    if (i_req[i]) begin
                        next_gnt[i] = 1'b1;
                        break;
                    end
                end
            end else begin
                // Round-robin: start from next index after current grant
                for (int k = 1; k <= N; k++) begin
                     idx = (index + k) % N;
                    if (i_req[idx]) begin
                        next_gnt[idx] = 1'b1;
                        break;
                    end
                end
            end
        end
    end

    // Combinational: find current grant index
    always_comb begin
        index = '0;
        for (int i = 0; i < N; i++) begin
            if (current_gnt[i])
                index = i[$clog2(N)-1:0];
        end
    end

endmodule
