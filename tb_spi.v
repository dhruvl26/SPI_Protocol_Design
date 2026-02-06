`timescale 1ns / 1ps

module tb_SPI;

    reg SPI_CLK;
    reg reset;
    wire [59:0] data;
    wire SPI_SDO;

    SPI dut (
        .SPI_CLK(SPI_CLK),
        .reset(reset),
        .data(data),
        .SPI_SDO(SPI_SDO)
    );
    
    always #5 SPI_CLK = ~SPI_CLK;

    initial begin
        SPI_CLK = 0;
        reset = 1'b1;
        #200 reset = 1'b0;
    end

    reg [59:0] sdi_capture;
    integer bit_cnt;
    integer frame_cnt;

    initial begin
        sdi_capture = 0;
        bit_cnt = 0;
        frame_cnt = 0;
    end

    always @(posedge dut.m1.SPI_CLK) begin
        if (!CSB) begin
            sdi_capture[59 - bit_cnt] <= SPI_SDI;
            bit_cnt = bit_cnt + 1;
        end
    end
    
    always @(posedge CSB) begin
        if (bit_cnt == 60) begin
            $display(
              "TIME=%0t | FRAME=%0d | MASTER_TX=%h | SLAVE_RX=%h",
              $time, frame_cnt, sdi_capture, data
            );
            frame_cnt = frame_cnt + 1;
        end

        bit_cnt = 0;
        sdi_capture = 0;
    end

    initial begin
        #100000;
        $finish;
    end

endmodule

