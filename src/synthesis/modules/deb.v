module deb #( parameter WIDTH = 8 ) (
    input clk,
    input rst_n,
    input in,
    output out
);

reg out_reg, out_next;
reg in_curr_reg, in_curr_next;
reg in_prev_reg, in_prev_next;
reg [WIDTH - 1 : 0] cnt_reg, cnt_next;

assign out = out_reg;
assign in_changed = in_curr_reg ^ in_prev_reg;
assign in_stable = (cnt_reg == { WIDTH{1'b1} }) ? 1'b1 : 1'b0;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_reg     <= 1'b0;
        in_curr_reg <= 1'b0;
        in_prev_reg <= 1'b0;
        cnt_reg     <= { WIDTH{1'b0} };
    end else begin
        out_reg     <= out_next;
        in_curr_reg <= in_curr_next;
        in_prev_reg <= in_prev_next;
        cnt_reg     <= cnt_next;
    end   
end

always @(*) begin
    in_curr_next = in;
    in_prev_next = in_curr_reg;

    cnt_next = in_changed ? { WIDTH{1'b0} } : (cnt_reg + 1'b1);
    out_next = in_stable ? in_prev_reg : out_reg;
end

endmodule
