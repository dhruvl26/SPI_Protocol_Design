module slave (
    input wire SPI_CSB,
    input wire SPI_CLK,
    input wire SPI_SDI,
    input wire reset,
    output wire SPI_SDO,
    output wire SPI_LDB,
    output reg [59:0] data
);

    reg [59:0] shift_reg;
    reg [5:0] bit_count;
    reg sdo_reg;
    reg ldb_reg;

    // -----------------------------
    // Bit counter reset on CSB
    // -----------------------------
   /* always @(posedge SPI_CSB or posedge reset) begin
        if (reset)
            bit_count <= 6'd59;
        else
            bit_count <= 6'd59;
    end */

    // -----------------------------
    // Receive data (SDI)
    // -----------------------------
    always @(posedge SPI_CLK or posedge reset) begin
        if (reset) begin
            shift_reg <= 60'd0;
            bit_count <= 6'd59;
        end else if (!SPI_CSB) begin
            shift_reg[bit_count] <= SPI_SDI;

            if (bit_count == 0)
                bit_count <= 6'd59;
            else
                bit_count <= bit_count - 1'b1;
        end
    end

    // -----------------------------
    // Transmit data (SDO)
    // -----------------------------
    always @(negedge SPI_CLK or posedge reset) begin
        if (reset)
            sdo_reg <= 1'b0;
        else if (!SPI_CSB)
            sdo_reg <= shift_reg[bit_count];
    end

    // -----------------------------
    // Latch output data (LDB)
    // -----------------------------
    always @(posedge SPI_CSB or posedge SPI_CLK or posedge reset) begin
        if (reset) begin
            data <= 60'd0;
            ldb_reg <= 1'b1;
        end else if (SPI_CSB) begin
            data <= shift_reg;
            ldb_reg <= 1'b0; // pulse low at end of frame
        end else if (SPI_CLK) begin
        ldb_reg <= 1'b1;
    end
end

    assign SPI_SDO = (!SPI_CSB) ? sdo_reg : 1'bz;
    assign SPI_LDB = ldb_reg;

endmodule