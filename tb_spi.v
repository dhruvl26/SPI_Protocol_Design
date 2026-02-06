`timescale 1ns / 1ps

module tb_SPI;

    reg SYSCLK_P;
    reg SYSCLK_N;
    reg reset;

    wire SPI_SDI;
    wire CSB;
    wire SPI_LDB;
    wire [59:0] data;
    wire SPI_SDO;

    SPI dut (
        .SYSCLK_P(SYSCLK_P),
        .SYSCLK_N(SYSCLK_N),
        .reset(reset),
        .SPI_SDI(SPI_SDI),
        .CSB(CSB),
        .SPI_LDB(SPI_LDB),
        .data(data),
        .SPI_SDO(SPI_SDO)
    );

    // ----------------------------------
    // Differential clock (100 MHz)
    // ----------------------------------
    initial begin
        SYSCLK_P = 0;
        SYSCLK_N = 1;
        forever #5 begin
            SYSCLK_P = ~SYSCLK_P;
            SYSCLK_N = ~SYSCLK_N;
        end
    end

    // ----------------------------------
    // Reset
    // ----------------------------------
    initial begin
        reset = 1'b1;
        #200 reset = 1'b0;
    end

    // ----------------------------------
    // Capture SPI SDI
    // ----------------------------------
    reg [59:0] sdi_capture;
    integer bit_cnt;
    integer frame_cnt;

    initial begin
        sdi_capture = 0;
        bit_cnt     = 0;
        frame_cnt   = 0;
    end

    always @(posedge dut.m1.SPI_CLK) begin
        if (!CSB) begin
            sdi_capture[59 - bit_cnt] <= SPI_SDI;
            bit_cnt = bit_cnt + 1;
        end
    end

    // ----------------------------------
    // Display at end of frame
    // ----------------------------------
    always @(posedge CSB) begin
        if (bit_cnt == 60) begin
            $display(
              "TIME=%0t | FRAME=%0d | MASTER_TX=%h | SLAVE_RX=%h",
              $time, frame_cnt, sdi_capture, data
            );
            frame_cnt = frame_cnt + 1;
        end

        bit_cnt     = 0;
        sdi_capture = 0;
    end

    // ----------------------------------
    // End simulation
    // ----------------------------------
    initial begin
        #100000;
        $display("---- SIMULATION FINISHED ----");
        $finish;
    end

endmodule
