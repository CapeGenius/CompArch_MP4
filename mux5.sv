module mux5 #(parameter WIDTH=32)
    (
        // Five data lines
        input logic [WIDTH - 1: 0] d0,
        input logic [WIDTH - 1: 0] d1,
        input logic [WIDTH - 1: 0] d2,
        input logic [WIDTH - 1: 0] d3,
        input logic [WIDTH - 1: 0] d4,
        
        // Select channel (3 bits to support 5 options)
        input logic [2:0] s,

        // Output selected data
        output logic [WIDTH - 1: 0] y
    );

    always_comb begin
        case(s)
            3'b000: y = d0;
            3'b001: y = d1;
            3'b010: y = d2;
            3'b011: y = d3;
            3'b100: y = d4;
            default: y = d0;
        endcase
    end
endmodule
