module ps2(
    input clk,
    input rst_n,
    input kb_data,
    input kb_clk,
    output [15:0] buffer_out,
    output error
);


// STATE constants
localparam IDLE_STATE       =    2'b00;     // waiting for start bit
localparam RECEIVING_STATE  =    2'b01;     // receiving data
localparam CHECK_STATE      =    2'b10;     // receiving & checking parity bit
localparam STOP_STATE       =    2'b11;     // receiving stop bit & returning to idle state


// variables
reg [15:0] received_data_reg, received_data_next;
reg [1:0] state_reg, state_next;
reg [3:0] cnt_reg, cnt_next;
reg error_reg, error_next;
reg parity_reg, parity_next;


// output assigns
assign buffer_out = received_data_reg;
assign error = error_reg;


always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin 
        // reset
        received_data_reg <= 16'h0000;
        state_reg <= IDLE_STATE;
        cnt_reg <= 4'h0;
        error_reg <= 1'b0;
        parity_reg <= 1'b0;
    end else begin
        received_data_reg <= received_data_next;
        state_reg <= state_next;
        cnt_reg <= cnt_next;
        error_reg <= error_next;
        parity_reg <= parity_next;
    end
end

always @(negedge kb_clk) begin

    // buffer for receiving data from keyboard
    received_data_next = received_data_reg;

    // state machine registers
    state_next = state_reg;

    // counter of received bits (from keyboard)
    cnt_next = cnt_reg;

    // error flag ==> indicates that error occurred while receiving data from keyboard
    error_next = error_reg;

    // parity bit ==> result of XOR-ing all 9 bits (8bit of DATA and 1bit PARITY)
    parity_next = parity_reg;

    case(state_reg) 
        IDLE_STATE: begin
            if(kb_data == 1'b0) begin
                // START bit received
                error_next = 1'b0;  // reset error flag
                state_next = RECEIVING_STATE;
            end
        end

        RECEIVING_STATE: begin
            if(cnt_reg % 8 == 0) begin
                // write first bit as start value
                parity_next = kb_data;
            end else begin
                // do XOR operation with all remaining bits
                parity_next = parity_reg ^ kb_data;
            end
            

            // receiving 8 bits of data
            received_data_next[cnt_reg] = kb_data;
            cnt_next = cnt_reg + 1'b1;


            if(cnt_next % 8 == 0) begin
                state_next = CHECK_STATE;
            end
        end

        CHECK_STATE: begin
            // receive parity bit, do XOR operation & check result
            if(parity_reg ^ kb_data == 1'b0) begin
                // if result of XOR-ing all 9 bits is 0 ==> error occurred (odd parity)
                error_next = 1'b1;
            end else begin
                error_next = 1'b0;
            end

            state_next = STOP_STATE;
        end

        STOP_STATE: begin
            if(kb_data == 1'b1) begin
                // STOP bit received
                state_next = IDLE_STATE;
            end else begin
                // error occurred ==> STOP bit not received on falling edge of keyboard clk
                error_next = 1'b1;
                state_next = IDLE_STATE;
            end
        end
    endcase
    
end

endmodule
