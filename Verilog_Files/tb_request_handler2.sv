`timescale 1ms/1ps

typedef enum logic [1:0] {
    INACTIVE = 2'b00,
    READY = 2'b01,
    ACTIVE = 2'b10
} VGA_state_t;

module tb;

    //Testbench parameters
    integer tb_test_num;
    string tb_test_case;


    // DUT Ports
    logic clk;
    logic nRst;

    //signals for controlling inputs/outputs
    logic mem_busy;
    VGA_state_t VGA_state;
    logic CPU_enable;

    //signals to/from VGA
    logic VGA_read;
    logic [31:0] VGA_adr;
    logic [31:0] data_to_VGA;

    //signals to/from UART
    logic UART_write;
    logic [31:0] UART_adr;
    logic [31:0] data_from_UART;

    //signals to/from CPU
    logic [31:0] CPU_instr_adr;
    logic [31:0] CPU_data_adr;
    logic CPU_read;
    logic CPU_write;
    logic [31:0] data_from_CPU;
    logic [3:0] CPU_sel;
    logic [31:0] instr_data_to_CPU;
    logic [31:0] data_to_CPU;

    //signals to/from memory/Wishbone
    logic [31:0] data_from_mem;
    logic mem_read;
    logic mem_write;
    logic [31:0] adr_to_mem;
    logic [31:0] data_to_mem;
    logic [3:0] sel_to_me;



    //Clock generation block
    localparam CLK_PERIOD = 10; // 100 Hz clk
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2.0);
        clk = 1'b1;
        #(CLK_PERIOD / 2.0);
    end



    // DUT Instance
    request_handler2 reqhand (
        .clk(clk),
        .nRst(nRst),

        //signals for controlling inputs/outputs
        .mem_busy(mem_busy),
        .VGA_state(VGA_state),
        .CPU_enable(CPU_enable),

        //signals to/from VGA
        .VGA_read(VGA_read),
        .VGA_adr(VGA_adr),
        .data_to_VGA(data_to_VGA),

        //signals to/from UART
        .UART_write(UART_write),
        .UART_adr(UART_adr),
        .data_from_UART(data_to_UART),

        //signals to/from CPU
        .CPU_instr_adr(CPU_instr_adr),
        .CPU_data_adr(CPU_data_adr),
        .CPU_read(CPU_read),
        .CPU_write(CPU_write),
        .data_from_CPU(data_from_CPU),
        .CPU_sel(CPU_sel),
        .instr_data_to_CPU(instr_data_to_CPU),
        .data_to_CPU(data_to_CPU),

        //signals to/from memory/Wishbone
        .data_from_mem(data_from_mem),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .adr_to_mem(adr_to_mem),
        .data_to_mem(data_to_mem),
        .sel_to_mem(sel_to_mem)
    );

    task check_CPU_enable;
        input logic expected_CPU_enable;
    begin
        if (expected_CPU_enable != CPU_enable) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect CPU_enable. Expected: %b, Actual: %b", expected_CPU_enable, CPU_enable);
        end
    end
    endtask

    task check_data_to_VGA;
        input logic [31:0] expected_data_to_VGA;
    begin
        if (expected_data_to_VGA != data_to_VGA) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_VGA. Expected: %b, Actual: %b", expected_data_to_VGA, data_to_VGA);
        end
    end
    endtask

    task check_instr_data_to_CPU;
        input logic [31:0] expected_instr_data_to_CPU;
    begin
        if (expected_instr_data_to_CPU != instr_data_to_CPU) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect instr_data_to_CPU. Expected: %b, Actual: %b", expected_instr_data_to_CPU, instr_data_to_CPU);
        end
    end
    endtask

    task check_data_to_CPU;
        input logic [31:0] expected_data_to_CPU;
    begin
        if (expected_data_to_CPU != data_to_CPU) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_CPU. Expected: %b, Actual: %b", expected_data_to_CPU, data_to_CPU);
        end
    end
    endtask

    task check_mem_read;
        input logic expected_mem_read;
    begin
        if (expected_mem_read != mem_read) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect mem_read. Expected: %b, Actual: %b", expected_mem_read, mem_read);
        end
    end
    endtask

    task check_mem_write;
        input logic expected_mem_write;
    begin
        if (expected_mem_write != mem_write) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect mem_write. Expected: %b, Actual: %b", expected_mem_write, mem_write);
        end
    end
    endtask

    task check_adr_to_mem;
        input logic [31:0] expected_adr_to_mem;
    begin
        if (expected_adr_to_mem != adr_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect adr_to_mem. Expected: %b, Actual: %b", expected_adr_to_mem, adr_to_mem);
        end
    end
    endtask

    task check_data_to_mem;
        input logic [31:0] expected_data_to_mem;
    begin
        if (expected_data_to_mem != data_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_mem. Expected: %b, Actual: %b", expected_data_to_mem, data_to_mem);
        end
    end
    endtask

    task check_sel_to_mem;
        input logic [3:0] expected_sel_to_mem;
    begin
        if (expected_sel_to_mem != sel_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect sel_to_mem. Expected: %b, Actual: %b", expected_sel_to_mem, sel_to_mem);
        end
    end
    endtask


    // Task to reset parameters
    task reset_parameters;
    begin
        nRst = 0;
        #10;
        nRst = 1;

        mem_busy = 0;
        VGA_state = INACTIVE;
        UART_write = 0;
        UART_adr = 0;
        data_from_UART = 0;
        CPU_instr_adr = 0;
        CPU_data_adr = 0;
        CPU_read = 0;
        CPU_write = 0;
        data_from_CPU = 0;
        CPU_sel = 0;
        data_from_mem = 0;
        
    end
    endtask



    // Main test bench process
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        //Test 0: Power-on-Reset
        tb_test_num = 0;
        tb_test_case = "Power-on-Reset";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset_parameters;
        #10;

        nRst = 0;
        #10;
        check_CPU_enable(0);
        check_data_to_VGA(0);
        check_instr_data_to_CPU(0);
        check_data_to_CPU(0);
        check_mem_read(0);
        check_mem_write(0);
        check_adr_to_mem(0);
        check_data_to_mem(0);
        check_sel_to_mem(0);
        nRst = 1;

        //Test 1: mem_busy
        tb_test_num++;
        tb_test_case = "mem_busy";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset_parameters;


        $finish;
    end

endmodule
