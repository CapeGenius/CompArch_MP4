`include "memory/memory_array.sv"

module data_mem #(
    parameter DMEM_INIT_FILE_PREFIX = "", 
    parameter CLK_FREQ = 12000000
)(
    input logic     clk,
    input logic     [2:0] funct3, 
    input logic     dmem_wren,
    input logic     [31:0] dmem_address, 
    input logic     [31:0] dmem_data_in,
    output logic    [31:0] dmem_data_out,
    output logic    reset, 
    output logic    led,                    // Active-high PWM output for user LED
    output logic    red,                    // Active-high PWM output for red LED
    output logic    green,                  // Active-high PWM output for green LED
    output logic    blue                    // Active-high PWM output for blue LED
);
    // ticks per ms and us 
    localparam TICKS_PER_MILLISECOND = CLK_FREQ / 1000;
    localparam TICKS_PER_MICROSECOND = CLK_FREQ / 1000000;

    // total counter
    logic [31:0] leds = 32'd0;              // Address 0xFFFFFFFC, R/W, four 8-bit PWM duty-cycle values for the user LED and the RGB LEDs
    logic [31:0] millis = 32'd0;            // Address 0xFFFFFFF8, R, count of milliseconds since processor started (mod 2^32)
    logic [31:0] micros = 32'd0;            // Address 0xFFFFFFF4, R, count of microseconds since processor started (mod 2^32)

    // modular counter
    logic [7:0] pwm_counter = 8'd0;
    logic [$clog2(TICKS_PER_MILLISECOND) - 1:0] millis_counter = '0;
    logic [$clog2(TICKS_PER_MICROSECOND) - 1:0] micros_counter = '0;


    // Declare variables associated with reading instruction memory
    logic [7:0] imem_data_out0;
    logic [7:0] imem_data_out1;
    logic [7:0] imem_data_out2;
    logic [7:0] imem_data_out3;

    // Declare variables associated with reading / writing data memory
    logic dmem_wren0;
    logic dmem_wren1;
    logic dmem_wren2;
    logic dmem_wren3;

    logic [7:0] dmem_data_in0;
    logic [7:0] dmem_data_in1;
    logic [7:0] dmem_data_in2;
    logic [7:0] dmem_data_in3;

    logic [7:0] dmem_data_out0;
    logic [7:0] dmem_data_out1;
    logic [7:0] dmem_data_out2;
    logic [7:0] dmem_data_out3;

    logic dmem_address0 = 1'b0;
    logic dmem_address1 = 1'b0;
    logic dmem_word = 1'b1;
    logic dmem_halfword = 1'b0;
    logic dmem_unsigned = 1'b0;

    logic is_leds;
    logic is_millis;
    logic is_micros;
    logic is_dmem;

    logic [31:0] dmem_data_value;
    logic [31:0] dmem_dout;

    logic [15:0] dmem_dout10;
    logic [15:0] dmem_dout32;

    logic [7:0] dmem_dout0;
    logic [7:0] dmem_dout1;
    logic [7:0] dmem_dout2;
    logic [7:0] dmem_dout3;

    logic sign_bit0;
    logic sign_bit1;
    logic sign_bit2;
    logic sign_bit3;

    logic [7:0] dmem_din0;
    logic [7:0] dmem_din1;
    logic [7:0] dmem_din2;
    logic [7:0] dmem_din3;

    logic dmem_addr0;
    logic dmem_addr1;

    logic dmem_write_enable;
    logic dmem_write_word;
    logic dmem_write_halfword;

// Instaniate data memory arrays
    memory_array #(
        .INIT_FILE      ((DMEM_INIT_FILE_PREFIX != "") ? { DMEM_INIT_FILE_PREFIX, "0.txt" } : "")
    ) dmem0 (
        .clk            (clk), 
        .write_enable   (dmem_wren0), 
        .address        (dmem_address), 
        .data_in        (dmem_data_in0), 
        .data_out       (dmem_data_out0)
    );

    memory_array #(
        .INIT_FILE      ((DMEM_INIT_FILE_PREFIX != "") ? { DMEM_INIT_FILE_PREFIX, "1.txt" } : "")
    ) dmem1 (
        .clk            (clk), 
        .write_enable   (dmem_wren1), 
        .address        (dmem_address), 
        .data_in        (dmem_data_in1), 
        .data_out       (dmem_data_out1)
    );

    memory_array #(
        .INIT_FILE      ((DMEM_INIT_FILE_PREFIX != "") ? { DMEM_INIT_FILE_PREFIX, "2.txt" } : "")
    ) dmem2 (
        .clk            (clk), 
        .write_enable   (dmem_wren2), 
        .address        (dmem_address), 
        .data_in        (dmem_data_in2), 
        .data_out       (dmem_data_out2)
    );

    memory_array #(
        .INIT_FILE      ((DMEM_INIT_FILE_PREFIX != "") ? { DMEM_INIT_FILE_PREFIX, "3.txt" } : "")
    ) dmem3 (
        .clk            (clk), 
        .write_enable   (dmem_wren3), 
        .address        (dmem_address), 
        .data_in        (dmem_data_in3), 
        .data_out       (dmem_data_out3)
    );

    // Handle data memory reads / writes
    assign is_leds = (dmem_address[31:2] == 30'h3FFFFFFF);
    assign is_millis = (dmem_address[31:2] == 30'h3FFFFFFE);
    assign is_micros = (dmem_address[31:2] == 30'h3FFFFFFD);
    assign is_dmem = (dmem_address[31:12] == 20'd0);

    // Register funct3 and two lsbs of dmem address to preserve data out even 
    // if funct3 and the dmem address change in the middle of the clock cycle.
    always_ff @(posedge clk) begin
        dmem_address1 <= dmem_address[1];
        dmem_address0 <= dmem_address[0];
        dmem_word <= funct3[1];
        dmem_halfword <= funct3[0];
        dmem_unsigned <= funct3[2];
    end

    always_comb begin
        if (is_leds) begin
            dmem_data_value = leds;
        end
        else if (is_millis) begin
            dmem_data_value = millis;
        end
        else if (is_micros) begin
            dmem_data_value = micros;
        end
        else begin
            dmem_data_value = 32'd0;
        end
    end

    assign dmem_dout = is_dmem ? { dmem_data_out3, dmem_data_out2, dmem_data_out1, dmem_data_out0 } : dmem_data_value;

    assign dmem_dout10 = dmem_dout[15:0];
    assign dmem_dout32 = dmem_dout[31:16];

    assign dmem_dout0 = dmem_dout[7:0];
    assign dmem_dout1 = dmem_dout[15:8];
    assign dmem_dout2 = dmem_dout[23:16];
    assign dmem_dout3 = dmem_dout[31:24];

    assign sign_bit0 = dmem_dout[7];
    assign sign_bit1 = dmem_dout[15];
    assign sign_bit2 = dmem_dout[23];
    assign sign_bit3 = dmem_dout[31];

    // Handle word, half word, and byte reads (signed and unsigned)
    always_comb begin
        if (dmem_word) begin
            dmem_data_out = dmem_dout;
        end
        else if (dmem_halfword && !dmem_unsigned) begin
            dmem_data_out = dmem_address1 ? { {16{sign_bit3}}, dmem_dout32 } : { {16{sign_bit1}}, dmem_dout10 };
        end
        else if (dmem_halfword && dmem_unsigned) begin
            dmem_data_out = dmem_address1 ? { 16'd0, dmem_dout32 } : { 16'd0, dmem_dout10 };
        end
        else if (!dmem_halfword && !dmem_unsigned) begin
            unique case ({ dmem_address1, dmem_address0 })
                2'b00: dmem_data_out = { {24{sign_bit0}}, dmem_dout0 };
                2'b01: dmem_data_out = { {24{sign_bit1}}, dmem_dout1 };
                2'b10: dmem_data_out = { {24{sign_bit2}}, dmem_dout2 };
                2'b11: dmem_data_out = { {24{sign_bit3}}, dmem_dout3 };
            endcase
        end
        else begin
            unique case ({ dmem_address1, dmem_address0 })
                2'b00: dmem_data_out = { 24'd0, dmem_dout0 };
                2'b01: dmem_data_out = { 24'd0, dmem_dout1 };
                2'b10: dmem_data_out = { 24'd0, dmem_dout2 };
                2'b11: dmem_data_out = { 24'd0, dmem_dout3 };
            endcase
        end
    end

    assign dmem_din0 = dmem_data_in[7:0];
    assign dmem_din1 = dmem_data_in[15:8];
    assign dmem_din2 = dmem_data_in[23:16];
    assign dmem_din3 = dmem_data_in[31:24];

    assign dmem_addr0 = dmem_address[0];
    assign dmem_addr1 = dmem_address[1];

    assign dmem_write_enable = (is_dmem && dmem_wren);
    assign dmem_write_word = funct3[1];
    assign dmem_write_halfword = funct3[0];

    // Handle word, half word, and byte writes to data memory
    always_comb begin
        if (dmem_write_word) begin
            dmem_wren0 = dmem_write_enable;
            dmem_wren1 = dmem_write_enable;
            dmem_wren2 = dmem_write_enable;
            dmem_wren3 = dmem_write_enable;
            dmem_data_in0 = dmem_din0;
            dmem_data_in1 = dmem_din1;
            dmem_data_in2 = dmem_din2;
            dmem_data_in3 = dmem_din3;
        end
        else if (dmem_write_halfword & ~dmem_addr1) begin
            dmem_wren0 = dmem_write_enable;
            dmem_wren1 = dmem_write_enable;
            dmem_wren2 = 1'b0;
            dmem_wren3 = 1'b0;
            dmem_data_in0 = dmem_din0;
            dmem_data_in1 = dmem_din1;
            dmem_data_in2 = 8'd0;
            dmem_data_in3 = 8'd0;
        end
        else if (dmem_write_halfword & dmem_addr1) begin
            dmem_wren0 = 1'b0;
            dmem_wren1 = 1'b0;
            dmem_wren2 = dmem_write_enable;
            dmem_wren3 = dmem_write_enable;
            dmem_data_in0 = 8'd0;
            dmem_data_in1 = 8'd0;
            dmem_data_in2 = dmem_din0;
            dmem_data_in3 = dmem_din1;
        end
        else begin
            unique case ({ dmem_addr1, dmem_addr0 })
                2'b00: begin
                    dmem_wren0 = dmem_write_enable;
                    dmem_wren1 = 1'b0;
                    dmem_wren2 = 1'b0;
                    dmem_wren3 = 1'b0;
                    dmem_data_in0 = dmem_din0;
                    dmem_data_in1 = 8'd0;
                    dmem_data_in2 = 8'd0;
                    dmem_data_in3 = 8'd0;
                end
                2'b01: begin
                    dmem_wren0 = 1'b0;
                    dmem_wren1 = dmem_write_enable;
                    dmem_wren2 = 1'b0;
                    dmem_wren3 = 1'b0;
                    dmem_data_in0 = 8'd0;
                    dmem_data_in1 = dmem_din0;
                    dmem_data_in2 = 8'd0;
                    dmem_data_in3 = 8'd0;
                end
                2'b10: begin
                    dmem_wren0 = 1'b0;
                    dmem_wren1 = 1'b0;
                    dmem_wren2 = dmem_write_enable;
                    dmem_wren3 = 1'b0;
                    dmem_data_in0 = 8'd0;
                    dmem_data_in1 = 8'd0;
                    dmem_data_in2 = dmem_din0;
                    dmem_data_in3 = 8'd0;
                end
                2'b11: begin
                    dmem_wren0 = 1'b0;
                    dmem_wren1 = 1'b0;
                    dmem_wren2 = 1'b0;
                    dmem_wren3 = dmem_write_enable;
                    dmem_data_in0 = 8'd0;
                    dmem_data_in1 = 8'd0;
                    dmem_data_in2 = 8'd0;
                    dmem_data_in3 = dmem_din0;
                end
            endcase
        end
    end

    // Handle word, half word, and byte writes to the LEDs peripheral register
    always_ff @(posedge clk) begin
        if (dmem_wren && is_leds) begin
            if (funct3[1]) begin
                leds <= dmem_data_in;
            end
            else if (funct3[0]) begin
                if (dmem_address[1])
                    leds[31:16] <= dmem_data_in[15:0];
                else
                    leds[15:0] <= dmem_data_in[15:0];
            end
            else begin
                unique case (dmem_address[1:0])
                    2'b00: leds[7:0] <= dmem_data_in[7:0];
                    2'b01: leds[15:8] <= dmem_data_in[7:0];
                    2'b10: leds[23:16] <= dmem_data_in[7:0];
                    2'b11: leds[31:24] <= dmem_data_in[7:0];
                endcase
            end
        end
    end

    // Implement PWM control for LED / RGB outputs
    always_ff @(posedge clk) begin
        pwm_counter <= pwm_counter + 1;
    end

    assign led = (pwm_counter < leds[31:24]);
    assign red = (pwm_counter < leds[23:16]);
    assign green = (pwm_counter < leds[15:8]);
    assign blue = (pwm_counter < leds[7:0]);

    // Implement millis counter
    always_ff @(posedge clk) begin
        if (millis_counter == TICKS_PER_MILLISECOND - 1) begin
            millis_counter <= '0;
            millis <= millis + 1;
        end
        else begin
            millis_counter <= millis_counter + 1;
        end
    end

    // Implement micros counter
    always_ff @(posedge clk) begin
        if (micros_counter == TICKS_PER_MICROSECOND - 1) begin
            micros_counter <= '0;
            micros <= micros + 1;
        end
        else begin
            micros_counter <= micros_counter + 1;
        end
    end

    assign reset = 1'b0;

endmodule
