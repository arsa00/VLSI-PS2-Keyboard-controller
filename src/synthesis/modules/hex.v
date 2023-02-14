module hex(
    input [15:0] input_data,
    input error,
    output reg [6:0] display0,
    output reg [6:0] display1,
    output reg [6:0] display2,
    output reg [6:0] display3
);


// few 7seg display constants
localparam SEG7_EMPTY_SCREEN = ~7'h00;
localparam SEG7_LETTER_E = ~7'h79;
localparam SEG7_LETTER_R = ~7'h50;

// returns codes for representing every hex number on 7seg display
function [6:0] hex_to_code;
    input [3:0] hex_number;

    begin
        case (hex_number)
            4'b0000: hex_to_code = ~7'h3F;  // 0
            4'b0001: hex_to_code = ~7'h06;  // 1
            4'b0010: hex_to_code = ~7'h5B;  // 2
            4'b0011: hex_to_code = ~7'h4F;  // 3
            4'b0100: hex_to_code = ~7'h66;  // 4
            4'b0101: hex_to_code = ~7'h6D;  // 5
            4'b0110: hex_to_code = ~7'h7D;  // 6
            4'b0111: hex_to_code = ~7'h07;  // 7
            4'b1000: hex_to_code = ~7'h7F;  // 8
            4'b1001: hex_to_code = ~7'h6F;  // 9
            4'b1010: hex_to_code = ~7'h77;  // A
            4'b1011: hex_to_code = ~7'h7C;  // B
            4'b1100: hex_to_code = ~7'h39;  // C
            4'b1101: hex_to_code = ~7'h5E;  // D
            4'b1110: hex_to_code = ~7'h79;  // E
            4'b1111: hex_to_code = ~7'h71;  // F 
        endcase
    end
    
endfunction


// code
always @(*) begin
    if(error == 1'b1) begin
        // write Err to 7seg displays (left to right)
        display3 = SEG7_EMPTY_SCREEN;
        display2 = SEG7_LETTER_E;
        display1 = SEG7_LETTER_R;
        display0 = SEG7_LETTER_R;
    end else begin
        // write 16 bit number to 7seg displays (right to left)
        display0 = hex_to_code(input_data[3:0]);
        display1 = hex_to_code(input_data[7:4]);
        display2 = hex_to_code(input_data[11:8]);
        display3 = hex_to_code(input_data[15:12]);
    end
end


endmodule
