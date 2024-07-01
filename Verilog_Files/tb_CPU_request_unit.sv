`timescale 1ms/1ps

module tb;

    //Testbench parameters
    integer tb_test_num;
    string tb_test_case;

    

    // DUT Ports
    logic nRst, clk;

    //From CPU
    logic read_from_CPU;
    logic write_from_CPU;
    logic [3:0] sel_from_CPU;
    logic [31:0] instruction_adr_from_CPU;
    logic [31:0] data_adr_from_CPU;
    logic [31:0] data_from_CPU;

    //To CPU
    logic enable;
    logic [31:0] instruction;
    logic [31:0] data;


    //From Mem
    logic mem_busy;
    logic [31:0] data_from_mem;

    //To Mem
    logic write_to_mem;
    logic read_to_mem;
    logic [3:0] sel_to_mem;
    logic [31:0] adr_to_mem;
    logic [31:0] data_to_mem;



    //Clock generation block
    localparam CLK_PERIOD = 10; // 100 Hz clk
    always begin
        clk = 1'b1;
        #(CLK_PERIOD / 2.0);
        clk = 1'b0;
        #(CLK_PERIOD / 2.0);
    end


    logic current_operation; //DELETE LATER

    // DUT Instance
    CPU_request_unit crHandler(
        .nRst(nRst),
        .clk(clk),

        .read_from_CPU(read_from_CPU),
        .write_from_CPU(write_from_CPU),
        .sel_from_CPU(sel_from_CPU),
        .instruction_adr_from_CPU(instruction_adr_from_CPU),
        .data_adr_from_CPU(data_adr_from_CPU),
        .data_from_CPU(data_from_CPU),

        .enable(enable),
        .instruction(instruction),
        .data(data),

        .mem_busy(mem_busy),
        .data_from_mem(data_from_mem),

        .write_to_mem(write_to_mem),
        .read_to_mem(read_to_mem),
        .sel_to_mem(sel_to_mem),
        .adr_to_mem(adr_to_mem),
        .data_to_mem(data_to_mem),

        .current_operation(current_operation) //DELETE LATER
    );
    

    // Task to Check enable
    task check_enable;
        input logic exp_enable;
    begin
        if (exp_enable != enable) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect enable. Expected: %b, Actual: %b", exp_enable, enable);
        end
    end
    endtask

    // Task to Check instruction
    task check_instruction;
        input logic [31:0] exp_instruction;
    begin
        if (exp_instruction != instruction) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect instruction. Expected: %b, Actual: %b", exp_instruction, instruction);
        end
    end
    endtask

    // Task to Check data
    task check_data;
        input logic [31:0] exp_data;
    begin
        if (exp_data != data) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect data. Expected: %b, Actual: %b", exp_data, data);
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

    // Task to Check sel_to_mem
    task check_sel_to_mem;
        input logic [3:0] exp_sel_to_mem;
    begin
        if (exp_sel_to_mem != sel_to_mem) begin
            $display("Error at test %d: %s", tb_test_num, tb_test_case);
            $display("Incorrect sel_to_mem. Expected: %b, Actual: %b", exp_sel_to_mem, sel_to_mem);
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



    // Task to reset parameters
    task reset;
    begin
        //signals from CPU
        read_from_CPU = 0;
        write_from_CPU = 0;
        sel_from_CPU = 0;
        instruction_adr_from_CPU = 0; 
        data_adr_from_CPU = 0;
        data_from_CPU = 0;

        //signals from mem
        mem_busy = 0;
        data_from_mem = 0;

        //turn reset on and off
        nRst = 0;
        #10;
        nRst = 1;
    end
    endtask


    // Main test bench process
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);


        //TEST 0: Power-on-reset
        tb_test_num = 0;
        tb_test_case = "Power-on-Reset";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset;

        nRst = 0;
        #10;
        check_enable        (0);
        check_instruction   (0);
        check_data          (0);
        check_write_to_mem  (0);
        check_read_to_mem   (1);        //Note: these have values because they are hardwired to be 1 and 1111 when the current_operation is read instruction, which it it
        check_sel_to_mem    (4'b1111);
        check_adr_to_mem    (0);
        check_data_to_mem   (0);
        nRst = 1;


        mem_busy = 1;
        #50;
        mem_busy = 0;
        #10; 
        mem_busy = 1;
        #50;
        mem_busy = 0;
        #10;
        mem_busy = 1;
        #50;
        mem_busy = 0;
        #10;
        mem_busy = 1;
        #50;
        mem_busy = 0;
        #10;
        mem_busy = 1;
        #50;
        mem_busy = 0;
        #10;

        /*
        //TEST 1: CPU not storing/loading (with mem_busy)
        tb_test_num ++;
        tb_test_case = "Not storing/loading";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset;

        //requests instructions
        mem_busy = 1;
        instruction_adr_from_CPU = 32'hAAAA;
        #10;
        check_adr_to_mem(32'hAAAA); //check right instructions are sent
        check_sel_to_mem(4'b1111);
        check_data_to_mem(0);
        #30;
        check_enable(0); //check enable should be off (mem is busy)
        
        //send back instructions
        if(adr_to_mem == 32'hAAAA) begin //simulate mem retrieving instructions
            data_from_mem = 32'hA000;
        end
        mem_busy = 0;
        #10;
        check_instruction(32'hA000);
        check_enable(1);
        //#10;

        //repeat operation
        //requests instructions
        mem_busy = 1;
        instruction_adr_from_CPU = 32'hABBB;
        #10;
        check_adr_to_mem(32'hABBB); //check right instructions are sent
        check_sel_to_mem(4'b1111);
        check_data_to_mem(0);
        #30;
        check_enable(0); //check enable should be off (mem is busy)
        
        //send back instructions
        if(adr_to_mem == 32'hABBB) begin //simulate mem retrieving instructions
            data_from_mem = 32'hA0BB;
        end
        mem_busy = 0;
        #10;
        check_instruction(32'hA0BB);
        check_enable(1);
        #10;




        //TEST 2: CPU storing (with mem_busy)
        tb_test_num ++;
        tb_test_case = "CPU storing";
        $display("\n\nTest %d: %s", tb_test_num, tb_test_case);
        reset;

        //requests instructions
        mem_busy = 1;
        instruction_adr_from_CPU = 32'hAAAA;
        #10;
        check_adr_to_mem(32'hAAAA); //check right instructions are sent
        check_sel_to_mem(4'b1111);
        check_data_to_mem(0);
        #30;
        check_enable(0); //check enable should be off (mem is busy)
        
        //send back instructions
        if(adr_to_mem == 32'hAAAA) begin //simulate mem retrieving instructions
            data_from_mem = 32'hA000;
        end
        mem_busy = 0;

        //simulate store command
        write_from_CPU = 1;
        sel_from_CPU = 4'b0011;
        data_adr_from_CPU = 32'hBBBB;
        data_from_CPU = 32'hFFFF;

        #10;
        check_instruction(32'hA000);
        check_enable(1);

        mem_busy = 1;

        #10;
        //check some stuff
        #30;
        mem_busy = 0;


        #10;*/

        








        $finish;
    end

endmodule
