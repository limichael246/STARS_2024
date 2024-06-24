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
    logic nRst, clk;

    //signals for determining data flow control
    VGA_state_t VGA_state; //0 = inactive, 1 = about to be active, 2 = active
    logic CPU_enable, UART_enable;
    //NOTE: VGA should always have access to memory when it needs it, so VGA_state will dictate memory access

    //signals from CPU
    logic write_from_CPU, read_from_CPU;
    logic [31:0] adr_from_CPU, data_from_CPU;
    logic [3:0] sel_from_CPU;

    //signal to CPU
    logic [31:0] data_to_CPU;


    //signals from VGA
    logic write_from_VGA, read_from_VGA; //NOTE: write_from_VGA and data_from_VGA is probably unnecessary 
    logic [31:0] adr_from_VGA, data_from_VGA;
    logic [3:0] sel_from_VGA;

    //signal to VGA
    logic [31:0] data_to_VGA;


    //signals from UART
    logic write_from_UART, read_from_UART; //NOTE: read_from_UART and data_to_UART is unused (future use might be considered)
    logic [31:0] adr_from_UART, data_from_UART;
    logic [3:0] sel_from_UART;

    //signal to UART
    logic [31:0] data_to_UART;


    //signals to memory
    logic write_to_mem, read_to_mem;
    logic [31:0] adr_to_mem, data_to_mem;
    logic [3:0] sel_to_mem;

    //signals from memory
    logic [31:0] data_from_mem;
    logic mem_busy;



    //Clock generation block
    localparam CLK_PERIOD = 10; // 100 Hz clk
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2.0);
        clk = 1'b1;
        #(CLK_PERIOD / 2.0);
    end



    // DUT Instance
    request_handler rhand (
        .nRst(nRst),
        .clk(clk),
        .VGA_state(VGA_state),
        .CPU_enable(CPU_enable),
        .UART_enable(UART_enable),

        .write_from_CPU(write_from_CPU),
        .read_from_CPU(read_from_CPU),
        .adr_from_CPU(adr_from_CPU),
        .data_from_CPU(data_from_CPU),
        .sel_from_CPU(sel_from_CPU),
        .data_to_CPU(data_to_CPU),

        .write_from_VGA(write_from_VGA),
        .read_from_VGA(read_from_VGA),
        .adr_from_VGA(adr_from_VGA),
        .data_from_VGA(data_from_VGA),
        .sel_from_VGA(sel_from_VGA),
        .data_to_VGA(data_to_VGA),

        .write_from_UART(write_from_UART),
        .read_from_UART(read_from_UART),
        .adr_from_UART(adr_from_UART),
        .data_from_UART(data_from_UART),
        .sel_from_UART(sel_from_UART),
        .data_to_UART(data_to_UART),

        .write_to_mem(write_to_mem),
        .read_to_mem(read_to_mem),
        .adr_to_mem(adr_to_mem),
        .data_to_mem(data_to_mem),
        .sel_to_mem(sel_to_mem),
        .data_from_mem(data_from_mem),
        .mem_busy(mem_busy)

    );

    // Task to Check CPU_enable
    task check_CPU_enable;
        input logic expected_CPU_enable;
    begin
        if (expected_CPU_enable != CPU_enable) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect CPU_enable. Expected: %b, Actual: %b", expected_CPU_enable, CPU_enable);
        end
    end
    endtask

    // Task to Check UART_enable
    task check_UART_enable;
        input logic expected_UART_enable;
    begin
        if (expected_UART_enable != UART_enable) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect UART_enable. Expected: %b, Actual: %b", expected_UART_enable, UART_enable);
        end
    end
    endtask

    // Task to Check data_to_CPU
    task check_data_to_CPU;
        input logic [31:0] exp_data_to_CPU;
    begin
        if (exp_data_to_CPU != data_to_CPU) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_CPU. Expected: %b, Actual: %b", exp_data_to_CPU, data_to_CPU);
        end
    end
    endtask

    // Task to Check data_to_VGA
    task check_data_to_VGA;
        input logic [31:0] exp_data_to_VGA;
    begin
        if (exp_data_to_VGA != data_to_VGA) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_VGA. Expected: %b, Actual: %b", exp_data_to_VGA, data_to_VGA);
        end
    end
    endtask

    // Task to Check data_to_UART
    task check_data_to_UART;
        input logic [31:0] exp_data_to_UART;
    begin
        if (exp_data_to_UART != data_to_UART) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_UART. Expected: %b, Actual: %b", exp_data_to_UART, data_to_UART);
        end
    end
    endtask

    // Task to Check write_to_mem
    task check_write_to_mem;
        input logic exp_write_to_mem;
    begin
        if (exp_write_to_mem != write_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect write_to_mem. Expected: %b, Actual: %b", exp_write_to_mem, write_to_mem);
        end
    end
    endtask

    // Task to Check read_to_mem
    task check_read_to_mem;
        input logic exp_read_to_mem;
    begin
        if (exp_read_to_mem != read_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect read_to_mem. Expected: %b, Actual: %b", exp_read_to_mem, read_to_mem);
        end
    end
    endtask

    // Task to Check adr_to_mem
    task check_adr_to_mem;
        input logic [31:0] exp_adr_to_mem;
    begin
        if (exp_adr_to_mem != adr_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect adr_to_mem. Expected: %b, Actual: %b", exp_adr_to_mem, adr_to_mem);
        end
    end
    endtask

    // Task to Check data_to_mem
    task check_data_to_mem;
        input logic [31:0] exp_data_to_mem;
    begin
        if (exp_data_to_mem != data_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data_to_mem. Expected: %b, Actual: %b", exp_data_to_mem, data_to_mem);
        end
    end
    endtask

    // Task to Check sel_to_mem
    task check_sel_to_mem;
        input logic [3:0]exp_sel_to_mem;
    begin
        if (exp_sel_to_mem != sel_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect sel_to_mem. Expected: %b, Actual: %b", exp_sel_to_mem, sel_to_mem);
        end
    end
    endtask


    // Task to reset parameters
    task reset_parameters;
    begin
        nRst = 0;
        #10;
        nRst = 1;
        VGA_state = INACTIVE;
        
        write_from_CPU = 0;
        read_from_CPU = 0;
        adr_from_CPU = 0;
        data_from_CPU = 0;
        sel_from_CPU = 0;

        write_from_VGA = 0;
        read_from_VGA = 0;
        adr_from_VGA = 0;
        data_from_VGA = 0;
        sel_from_VGA = 0;

        write_from_UART = 0;
        read_from_UART = 0;
        adr_from_UART = 0;
        data_from_UART = 0;
        sel_from_UART = 0;

        data_from_mem = 0;
        mem_busy = 0;
    end
    endtask



    // Main test bench process
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        #5;

        //Test 0: Power-on-Reset
        tb_test_num = 0;
        tb_test_case = "Power-on-Reset";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset_parameters;
        #10;

        nRst = 0;
        #10;
        check_CPU_enable(0);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(0);
        check_read_to_mem(0);
        check_adr_to_mem(0);
        check_data_to_mem(0);
        check_sel_to_mem(0);
        nRst = 1;



        //Test 1: mem_busy
        tb_test_num++;
        tb_test_case = "mem_busy";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset_parameters;

        mem_busy = 1;

        //some test inputs
        write_from_CPU = 1;
        write_from_UART = 1;
        read_from_VGA = 1;
        adr_from_CPU = 32'd123;
        data_from_CPU = 32'hCCCC;
        sel_from_CPU = 4'b1111;
        adr_from_UART = 32'd456;
        data_from_UART = 32'hAAAA;
        sel_from_UART = 4'b1111;
        adr_from_VGA = 32'd789;
        sel_from_VGA = 4'b1111;
        #10;


        check_CPU_enable(0);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(0);
        check_read_to_mem(0);
        check_adr_to_mem(0);
        check_data_to_mem(0);
        check_sel_to_mem(0);
        mem_busy = 0;
        #10;



        //Test 2: Check memory receives appropriate signals when client changes from VGA to UART to CPU to VGA
        tb_test_num++;
        tb_test_case = "Client changes: receiving";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset_parameters;

        //some test inputs - VGA is active
        VGA_state = ACTIVE;
        write_from_CPU = 1;
        write_from_UART = 1;
        read_from_VGA = 1;
        adr_from_CPU = 32'h123;
        data_from_CPU = 32'hCCCC;
        sel_from_CPU = 4'b1111;
        adr_from_UART = 32'h456;
        data_from_UART = 32'hAAAA;
        sel_from_UART = 4'b1111;
        adr_from_VGA = 32'h789;
        sel_from_VGA = 4'b1111;
        #10;
        check_CPU_enable(0);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(0);
        check_read_to_mem(1);
        check_adr_to_mem(32'h789);
        check_data_to_mem(0);
        check_sel_to_mem(4'b1111);

        VGA_state = INACTIVE; //check client change to UART
        #5;
        check_CPU_enable(0);
        check_UART_enable(1);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(1);
        check_read_to_mem(0);
        check_adr_to_mem(32'h456);
        check_data_to_mem(32'hAAAA);
        check_sel_to_mem(4'b1111);

        #10; //check client change to CPU
        check_CPU_enable(1);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(1);
        check_read_to_mem(0);
        check_adr_to_mem(32'h123);
        check_data_to_mem(32'hCCCC);
        check_sel_to_mem(4'b1111);
        
        #5; //check if mem_busy mid-operation works
        mem_busy = 1;
        #10;
        check_CPU_enable(0);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(0);
        check_read_to_mem(0);
        check_adr_to_mem(0);
        check_data_to_mem(0);
        check_sel_to_mem(0);
        mem_busy = 0;
        #10;
        check_CPU_enable(1);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(1);
        check_read_to_mem(0);
        check_adr_to_mem(32'h123);
        check_data_to_mem(32'hCCCC);
        check_sel_to_mem(4'b1111);
        
        //try read request from CPU instead
        write_from_CPU = 0;
        read_from_CPU = 1;
        adr_from_CPU = 32'h111;
        data_from_CPU = 32'hCAB;
        sel_from_CPU = 4'b0111;
        #10;
        check_CPU_enable(1);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(0);
        check_read_to_mem(1);
        check_adr_to_mem(32'h111);
        check_data_to_mem(32'hCAB);
        check_sel_to_mem(4'b0111);

        #30;

        VGA_state = READY; //check client change to VGA
        #10;
        check_CPU_enable(0);
        check_UART_enable(0);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        check_write_to_mem(0);
        check_read_to_mem(1);
        check_adr_to_mem(32'h789);
        check_data_to_mem(0);
        check_sel_to_mem(4'b1111);

        #20;



        //Test 3: Check memory sends appropriate signals when client changes from VGA to UART to CPU to VGA
        tb_test_num++;
        tb_test_case = "Client changes: sending";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset_parameters;

        VGA_state = ACTIVE; //check VGA receives signals
        read_from_CPU = 1;
        write_from_UART = 0;
        read_from_VGA = 1;
        adr_from_CPU = 32'h123;
        sel_from_CPU = 4'b1111;
        adr_from_UART = 32'h456;
        sel_from_UART = 4'b1111;
        adr_from_VGA = 32'h789;
        sel_from_VGA = 4'b1111;
        data_from_mem = 32'h911;
        #10;
        check_CPU_enable(0);
        check_UART_enable(0);
        check_write_to_mem(0);
        check_read_to_mem(1);
        check_adr_to_mem(32'h789);
        check_data_to_mem(0);
        check_sel_to_mem(4'b1111);
        check_data_to_CPU(0);
        check_data_to_VGA(32'h911);
        check_data_to_UART(0);
        
        
        VGA_state = INACTIVE; //check UART "receives" signals
        #5;
        check_CPU_enable(0);
        check_UART_enable(1);
        check_write_to_mem(0);
        check_read_to_mem(0);
        check_adr_to_mem(32'h456);
        check_data_to_mem(0);
        check_sel_to_mem(4'b1111);
        check_data_to_CPU(0);
        check_data_to_VGA(0);
        check_data_to_UART(32'h911);

        #10; //check CPU receives signals
        check_CPU_enable(1);
        check_UART_enable(0);
        check_write_to_mem(0);
        check_read_to_mem(1);
        check_adr_to_mem(32'h123);
        check_data_to_mem(0);
        check_sel_to_mem(4'b1111);
        check_data_to_CPU(32'h911);
        check_data_to_VGA(0);
        check_data_to_UART(0);
        
        #50;


        $finish;
    end

endmodule
