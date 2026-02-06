module master (
    input  wire SPI_CLK,
    input  wire reset,
    output reg  SPI_CSB,
    output reg  SPI_SDI
);

    reg [59:0] shift_reg;
    reg [5:0]  bit_count;
    reg [2:0]  rom_addr;

    wire [59:0] rom_data;
    spi_rom rom_inst (.addr(rom_addr), .data(rom_data));

    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SHIFT = 2'd2;

    reg [1:0] state;

    always @(negedge SPI_CLK or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            SPI_CSB   <= 1'b1;
            SPI_SDI   <= 1'b0;
            bit_count <= 6'd0;
            rom_addr  <= 3'd0;
            shift_reg <= 60'd0;
        end else begin
            case (state)

            IDLE: begin
                SPI_CSB <= 1'b1;
                state   <= LOAD;
            end

            LOAD: begin
                shift_reg <= rom_data;
                bit_count <= 6'd59;
                SPI_CSB   <= 1'b0;
                SPI_SDI   <= rom_data[59]; 
                state     <= SHIFT;
            end

            SHIFT: begin
                if (bit_count != 0) begin
                    bit_count <= bit_count - 1'b1;
                    SPI_SDI   <= shift_reg[bit_count - 1'b1];
                end else begin
                    SPI_CSB  <= 1'b1;      
                    rom_addr <= rom_addr + 1'b1;
                    state    <= IDLE;
                end
            end

            default: state <= IDLE;
            endcase
        end
    end
endmodule


module spi_rom (
    input  wire [2:0] addr,
    output reg  [59:0] data
);

always @(*) begin
    case (addr)
        3'd0: data = 60'hAA5_123456789ABC;
        3'd1: data = 60'h123_000000000001;
        3'd2: data = 60'h456_000000000002;
        3'd3: data = 60'h789_000000000003;
        3'd4: data = 60'hABC_000000000004;
        3'd5: data = 60'hDEF_000000000005;
        3'd6: data = 60'h111_222233334444;
        3'd7: data = 60'hFFF_FFFFFFFFFFFF;
        default: data = 60'd0;
    endcase
end

endmodule
