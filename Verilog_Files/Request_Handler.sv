`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...

  
  
endmodule

// Add more modules down here...

module ssdec (
  input logic [3:0] in,
  input logic enable,
  output logic [7:0] out
);

  always_comb begin

    case(enable)

    1'b0 : begin out = 8'b00000000; end
    1'b1 : begin
      case(in)
        4'b0000 : begin out = 8'b00111111; end //0
        4'b0001 : begin out = 8'b00000110; end //1
        4'b0010 : begin out = 8'b01011011; end //2
        4'b0011 : begin out = 8'b01001111; end //3

        4'b0100 : begin out = 8'b01100110; end //4
        4'b0101 : begin out = 8'b01101101; end //5
        4'b0110 : begin out = 8'b01111101; end //6
        4'b0111 : begin out = 8'b00000111; end //7

        4'b1000 : begin out = 8'b01111111; end //8
        4'b1001 : begin out = 8'b01100111; end //9
        4'b1010 : begin out = 8'b01110111; end //A
        4'b1011 : begin out = 8'b01111100; end //B
        
        4'b1100 : begin out = 8'b00111001; end //C
        4'b1101 : begin out = 8'b01011110; end //D
        4'b1110 : begin out = 8'b01111001; end //E
        4'b1111 : begin out = 8'b01110001; end //F

      endcase
    end

    endcase

  end

endmodule

module synckey ( //one button only
  input logic clk, rst,
  
  input logic in,
  output logic strobe
);

  logic middle;

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      middle <= 0;
    end
    else begin
      middle <= in;
    end
  end

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      strobe <= 0;
    end
    else begin
      strobe <= middle;
    end
  end

endmodule



typedef enum logic [1:0] {
  CPU = 2'b00,
  VGA = 2'b01,
  UART = 2'b10
} current_client_t;

typedef enum logic [1:0] {
  INACTIVE = 2'b0,
  READY = 2'b1,
  ACTIVE = 2'b10
} VGA_state_t;

module request_handler (
  input logic nRst, clk,

  //signals for determining data flow control
  input VGA_state_t VGA_state, //0 = inactive, 1 = about to be active, 2 = active
  output logic CPU_enable, UART_enable,
  //NOTE: VGA should always have access to memory when it needs it, so VGA_state will dictate memory access

  //signals from CPU
  input logic write_from_CPU, read_from_CPU,
  input logic [31:0] adr_from_CPU, data_from_CPU,
  input logic [3:0] sel_from_CPU,

  //signal to CPU
  output logic [31:0] data_to_CPU,


  //signals from VGA
  input logic write_from_VGA, read_from_VGA, //NOTE: write_from_VGA and data_from_VGA is probably unnecessary 
  input logic [31:0] adr_from_VGA, data_from_VGA,
  input logic [3:0] sel_from_VGA,

  //signal to VGA
  output logic [31:0] data_to_VGA,


  //signals from UART
  input logic write_from_UART, read_from_UART, //NOTE: read_from_UART and data_to_UART is unused (future use might be considered)
  input logic [31:0] adr_from_UART, data_from_UART,
  input logic [3:0] sel_from_UART,

  //signal to UART
  output logic [31:0] data_to_UART,


  //signals to memory
  output logic write_to_mem, read_to_mem,
  output logic [31:0] adr_to_mem, data_to_mem,
  output logic [3:0] sel_to_mem,

  //signals from memory
  input logic [31:0] data_from_mem,
  input logic mem_busy
);

  current_client_t current_client; //00 for CPU, 01 for VGA, 10 for UART
  logic [31:0] CPU_UART_cycle_counter;

  always_ff @( posedge clk, negedge nRst ) begin //current client control
    if(~nRst) begin
      current_client <= VGA;
    end else begin
      if (VGA_state == READY | VGA_state == ACTIVE) begin
        current_client <= VGA;
      end else begin
        if(current_client == VGA) begin
          current_client <= UART;
        end else begin
          current_client <= CPU;
        end
      end
    end
  end

  always_comb begin  //make connects based on current client
    case (current_client)
      VGA: begin
        CPU_enable = 1'b0;
        UART_enable = 1'b0;
        data_to_CPU = 32'b0;
        data_to_VGA = data_from_mem;
        data_to_UART = 32'b0;

        write_to_mem = write_from_VGA;
        read_to_mem = read_from_VGA;
        adr_to_mem = adr_from_VGA;
        data_to_mem = data_from_VGA;
        sel_to_mem = sel_from_VGA;
      end

      CPU: begin
        CPU_enable = 1'b1;
        UART_enable = 1'b0;
        data_to_CPU = data_from_mem;
        data_to_VGA = 32'b0;
        data_to_UART = 32'b0;

        write_to_mem = write_from_CPU;
        read_to_mem = read_from_CPU;
        adr_to_mem = adr_from_CPU;
        data_to_mem = data_from_CPU;
        sel_to_mem = sel_from_CPU;
      end

      UART: begin
        CPU_enable = 1'b0;
        UART_enable = 1'b1;
        data_to_CPU = 32'b0;
        data_to_VGA = 32'b0;
        data_to_UART = data_from_mem;

        write_to_mem = write_from_UART;
        read_to_mem = read_from_UART;
        adr_to_mem = adr_from_UART;
        data_to_mem = data_from_UART;
        sel_to_mem = sel_from_UART;
      end

      default: begin
        CPU_enable = 1'b0;
        UART_enable = 1'b0;
        data_to_CPU = 32'b0;
        data_to_VGA = data_from_mem;
        data_to_UART = 32'b0;

        write_to_mem = write_from_VGA;
        read_to_mem = read_from_VGA;
        adr_to_mem = adr_from_VGA;
        data_to_mem = data_from_VGA;
        sel_to_mem = sel_from_VGA;
      end
    endcase
  end

endmodule

// Old module
// module request_handler #(
//   parameter [31:0] UART_BAUD_RATE = 9600,
//   parameter [31:0] CLOCK_FREQ = 50000000,
//   parameter [31:0] CPU_UART_CYCLE_RATIO = ((CLOCK_FREQ / UART_BAUD_RATE) / 2) //cycles CPU is active : cycles UART is active
// )(
//   input logic nRst, clk,

//   //signals for determining data flow control
//   input VGA_state_t VGA_state, //0 = inactive, 1 = about to be active, 2 = active
//   output logic CPU_enable, UART_enable,
//   //NOTE: VGA should always have access to memory when it needs it, so VGA_state will dictate memory access

//   //signals from CPU
//   input logic write_from_CPU, read_from_CPU,
//   input logic [31:0] adr_from_CPU, data_from_CPU,
//   input logic [3:0] sel_from_CPU,

//   //signal to CPU
//   output logic [31:0] data_to_CPU,


//   //signals from VGA
//   input logic write_from_VGA, read_from_VGA, //NOTE: write_from_VGA and data_from_VGA is probably unnecessary 
//   input logic [31:0] adr_from_VGA, data_from_VGA,
//   input logic [3:0] sel_from_VGA,

//   //signal to VGA
//   output logic [31:0] data_to_VGA,


//   //signals from UART
//   input logic write_from_UART, read_from_UART, //NOTE: read_from_UART and data_to_UART is unused (future use might be considered)
//   input logic [31:0] adr_from_UART, data_from_UART,
//   input logic [3:0] sel_from_UART,

//   //signal to UART
//   output logic [31:0] data_to_UART,


//   //signals to memory
//   output logic write_to_mem, read_to_mem,
//   output logic [31:0] adr_to_mem, data_to_mem,
//   output logic [3:0] sel_to_mem,

//   //signals from memory
//   input logic [31:0] data_from_mem,
//   input logic mem_busy
// );

//   current_client_t current_client; //00 for CPU, 01 for VGA, 10 for UART
//   logic [31:0] CPU_UART_cycle_counter;

//   always_ff @( posedge clk, negedge nRst ) begin //current client control
//     if(~nRst) begin
//       current_client <= VGA;
//     end else begin
//       if (VGA_state == READY | VGA_state == ACTIVE) begin
//         current_client <= VGA;
//       end else begin
//         if (CPU_UART_cycle_counter == CPU_UART_CYCLE_RATIO) begin
//           current_client <= UART;
//         end else begin
//           current_client <= CPU;
//         end
//       end
//     end
//   end

//   always_ff @( posedge clk, negedge nRst ) begin //CPU_UART_cycle_counter logic
//     if (~nRst) begin
//       CPU_UART_cycle_counter <= 0;
//     end else begin
//       if(current_client == CPU | current_client == UART) begin
//         if(CPU_UART_cycle_counter == CPU_UART_CYCLE_RATIO) begin
//           CPU_UART_cycle_counter <= 0;
//         end else begin
//           CPU_UART_cycle_counter <= CPU_UART_cycle_counter + 1;
//         end
//       end else begin
//         CPU_UART_cycle_counter <= CPU_UART_cycle_counter;
//       end
//     end
//   end

//   always_comb begin  //make connects based on current client
//     case (current_client)
//       VGA: begin
//         CPU_enable = 1'b0;
//         UART_enable = 1'b0;
//         data_to_CPU = 32'b0;
//         data_to_VGA = data_from_mem;
//         data_to_UART = 32'b0;

//         write_to_mem = write_from_VGA;
//         read_to_mem = read_from_VGA;
//         adr_to_mem = adr_from_VGA;
//         data_to_mem = data_from_VGA;
//         sel_to_mem = sel_from_VGA;
//       end

//       CPU: begin
//         CPU_enable = 1'b1;
//         UART_enable = 1'b0;
//         data_to_CPU = data_from_mem;
//         data_to_VGA = 32'b0;
//         data_to_UART = 32'b0;

//         write_to_mem = write_from_CPU;
//         read_to_mem = read_from_CPU;
//         adr_to_mem = adr_from_CPU;
//         data_to_mem = data_from_CPU;
//         sel_to_mem = sel_from_CPU;
//       end

//       UART: begin
//         CPU_enable = 1'b0;
//         UART_enable = 1'b1;
//         data_to_CPU = 32'b0;
//         data_to_VGA = 32'b0;
//         data_to_UART = data_from_mem;

//         write_to_mem = write_from_UART;
//         read_to_mem = read_from_UART;
//         adr_to_mem = adr_from_UART;
//         data_to_mem = data_from_UART;
//         sel_to_mem = sel_from_UART;
//       end

//       default: begin
//         CPU_enable = 1'b0;
//         UART_enable = 1'b0;
//         data_to_CPU = 32'b0;
//         data_to_VGA = data_from_mem;
//         data_to_UART = 32'b0;

//         write_to_mem = write_from_VGA;
//         read_to_mem = read_from_VGA;
//         adr_to_mem = adr_from_VGA;
//         data_to_mem = data_from_VGA;
//         sel_to_mem = sel_from_VGA;
//       end
//     endcase
//   end

// endmodule