module debug_dout_unit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] opcode,
    input  wire [7:0] rdata0,        // dữ liệu từ regfile (ST)
    input  wire [7:0] dmem_rdata,    // dữ liệu đọc từ RAM (LD)
    output reg  [7:0] debug_dout
);


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            debug_dout <= 8'd0;
        end else begin
            case (opcode)
                4'h6: debug_dout <= rdata0;      // ST: ghi RAM
                4'h5: debug_dout <= dmem_rdata;  // LD: đọc RAM
                default: debug_dout <= debug_dout; // giữ nguyên
            endcase
        end
    end


endmodule

