module SPI (
  input wire SPI_CLK
  input wire reset, 
  output wire [59:0] data,
  output wire SPI_SDO
);

wire SPI_CSB; 
wire SDI, SDO, LDB; 

master m1 (
    .SPI_CSB(SPI_CSB),
    .SPI_CLK(SPI_CLK), 
    .SPI_SDI(SDI),
    .reset(reset)
);

slave s1 (
    .SPI_CLK(SPI_CLK), 
    .SPI_CSB(SPI_CSB),
    .SPI_LDB(LDB),
    .SPI_SDI(SDI),
    .SPI_SDO(SDO),
    .reset(reset),
    .data(data)
);

assign SPI_SDO = SDO;

endmodule 
