

`timescale 1ms / 100us

module tb_alu();

//enum for operation type
typedef enum logic [3:0] {
    ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9,
    //ADDI=10, XORI=13, ORI=14, ANDI=15, SLLI=16, SLTI=11, SRLI=17, SRAI=18, SLTIU=12, 
    BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15, ERR=4'bx
    //LB=16, LH=17, LW=18, LBU=19, LHU=20, LW=21, SB=22, SH=23, SW=24 (just add)
    } operation_t;

    // testbench parameters
    integer tb_test_num;
    string tb_test_case;

    // DUT ports
    logic [6:0] tb_opcode;
    logic [2:0] tb_alu_op;
    logic [6:0] tb_func7;
    logic tb_ctrl_err; //alu ctrl unit err
    logic [31:0] tb_opA;
    logic [31:0] tb_opB;
    //logic [4:0] tb_alu_control_input;
    logic [31:0] tb_alu_result;
    logic tb_zero_flag, tb_eq_flag, tb_less_flag, tb_err_flag; //alu op err
    
    logic exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag;
    logic [31:0] exp_alu_out;
    logic exp_ctrl_err;

    
    //task to check operation
    task check_op_o(
    input logic [31:0] expected_op,
    input logic expected_err,
    input logic exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, 
    input string string_op
    );

        if(tb_alu_result === expected_op) //triple equalto symbol
            $info("Correct op: %s.", string_op);
        else
            $error("Incorrect mode. Expected: %b. Actual: %b.", expected_op, tb_alu_result); 
        if(tb_ctrl_err == expected_err)
             $info("Correct error: %b.", expected_err);
        else
            $error("Incorrect error. Expected: %b. Actual: %b.", expected_err, tb_ctrl_err); 
        
        if(tb_zero_flag === exp_zero_flag)
            $info("Correct zf: %b.", exp_zero_flag);
        else
            $error("Incorrect zf. Expected: %b. Actual: %b.", exp_zero_flag, tb_zero_flag); 

        if(tb_eq_flag == exp_eq_flag)
            $info("Correct eqf: %b.", exp_eq_flag);
        else
            $error("Incorrect eqf. Expected: %b. Actual: %b.", exp_eq_flag, tb_eq_flag); 
        
        if(tb_less_flag == exp_less_flag)
            $info("Correct lf: %b.", exp_less_flag);
        else
            $error("Incorrect lf. Expected: %b. Actual: %b.", exp_less_flag, tb_less_flag); 
        
        if(tb_err_flag == exp_err_flag)
            $info("Correct erf: %b.", exp_err_flag);
        else
            $error("Incorrect erf. Expected: %b. Actual: %b.", exp_err_flag, tb_err_flag); 

    endtask

    //DUT portmap
    alu DUT(.opcode(tb_opcode), 
            .alu_op(tb_alu_op), 
            .func7(tb_func7), 
            .opA(tb_opA), 
            .opB(tb_opB),
            //.alu_control_input(tb_alu_control_input), 
            .alu_result(tb_alu_result),
            .ctrl_err(tb_ctrl_err),
            .zero_flag(tb_zero_flag),
            .eq_flag(tb_eq_flag),
            .less_flag(tb_less_flag),
            .err_flag(tb_err_flag));

  // Main Test Bench Process
    initial begin
        // Signal dump
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu); 

        tb_opcode = 7'b0;
        tb_alu_op = 3'b0;
        tb_func7 = 7'b0;
        tb_opA = 32'b0;
        tb_opB = 32'b0;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;

        tb_test_num = 0;
        tb_test_case = "Initializing";

        // ************************************************************************
        // Test Case 1: testing for ADD operation
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 1: testing for ADD alu result";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b000;
        tb_func7 = 7'b0;
        tb_opA = 32'd1;
        tb_opB = 32'd2;
        exp_alu_out = 32'd3;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out, exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "ADD 1+2");
        // ************************************************************************
        // Test Case 2: testing for invalid control input (func7 ADD/SUB)
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 2: testing for ERR control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b000;
        tb_func7 = 7'b0110000; //err
        tb_opA = 32'd1;
        tb_opB = 32'd2;
        exp_alu_out = 'bx; //extends without prefix 
        exp_ctrl_err = 1'b1;
        exp_zero_flag = 1'bx; //implementation decision
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b1; //used for stuff like divide by 0
        #10
        check_op_o(exp_alu_out,exp_ctrl_err, exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "ERR");
        // ************************************************************************
        // Test Case 3: testing for SUB control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 3: testing for SUB control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b000;
        tb_func7 = 7'b0100000;
        tb_opA = 32'd3;
        tb_opB = 32'd1;
        exp_alu_out = 32'd2;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SUB 3-1");
        // ************************************************************************
        // Test Case 4: testing for SLL control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 4: testing for SLL control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b001;
        tb_func7 = 0000000;
        tb_opA = 32'h12345678;
        tb_opB = 32'h08;
        exp_alu_out = 32'h34567800;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err, exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SLL");
        // ************************************************************************
        // Test Case 5: testing for SLT control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 5: testing for SLT control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b010;
        tb_func7 = 0000000;
        tb_opA = 32'h12345678;
        tb_opB = 32'h0000ffff;
        exp_alu_out = 32'h0;  //0 value output
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b1;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SLT");


        // ************************************************************************
        // Test Case 6: testing for SLT2 control input                                                                 //FIXME NOT RECOGNIZING SIGNED VALUE (alu?)
                                                                                                                          //could be a testcase for top
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 6: testing for SLT2 control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b010;

        tb_func7 = 0000000;
        tb_opA = 32'h82345678;
        tb_opB = 32'h0000ffff;
        exp_alu_out = 32'h00000001; //non 0 value output
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SLT2");


        // ************************************************************************
        // Test Case 7: testing for SLTU control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 7: testing for SLTU control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b011;
        tb_func7 = 0000000;
        tb_opA = 32'h12345678;
        tb_opB = 32'h0000ffff;
        exp_alu_out = 32'h0;  //0 value output
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b1;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SLTU");
        // ************************************************************************
        // Test Case 8: testing for SLTU2 control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 8: testing for SLTU2 control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b011;
        tb_func7 = 0000000;
        tb_opA = 32'h12345678;
        tb_opB = 32'h8000ffff;
        exp_alu_out = 32'h00000001; //non 0 value output
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SLTU2");

        // ************************************************************************
        // Test Case 9: testing for XOR control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 9: testing for XOR control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b100;
        tb_func7 = 0000000;
        tb_opA = 32'h55551111;
        tb_opB = 32'hff00ff00;
        exp_alu_out = 32'haa55ee11;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "XOR");
      
        // ************************************************************************
        // Test Case 10: testing for SRL control input                                          
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 10: testing for SRL control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b101;
        tb_func7 = 0000000;
        tb_opA = 32'h87654321;
        tb_opB = 32'h08;
        exp_alu_out = 32'h00876543;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SRL");

        // ************************************************************************
        // Test Case 11: testing for SRL2 control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 11: testing for SRL2 control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b101;
        tb_func7 = 0000000;
        tb_opA = 32'h76543210;
        tb_opB = 32'h08;
        exp_alu_out = 32'h00765432;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SRL2");

        // ************************************************************************
        // Test Case 12: testing for SRA control input                                      //FIXME   padding with zeors instead of ones                         
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 12: testing for SRA control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b101;
        tb_func7 = 7'b0100000;
        tb_opA = 32'h87654321;
        tb_opB = 32'h08;
        exp_alu_out = 32'hff876543;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SRA");

        // ************************************************************************
        // Test Case 13: testing for SRA2 control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 13: testing for SRA2 control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b101;
        tb_func7 = 7'b0100000;
        tb_opA = 32'h76543210;
        tb_opB = 32'h08;
        exp_alu_out = 32'h00765432;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "SRA2");

        // ************************************************************************
        // Test Case 14: testing for OR control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 14: testing for OR control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b110;
        tb_func7 = 7'b0000000;
        tb_opA = 32'h55551111;
        tb_opB = 32'hff00ff00;
        exp_alu_out = 32'hff55ff11;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "OR");

        // ************************************************************************
        // Test Case 15: testing for AND control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 15: testing for AND control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b0110011;
        tb_alu_op = 3'b111;
        tb_func7 = 7'b0000000;
        tb_opA = 32'h55551111;
        tb_opB = 32'hff00ff00;
        exp_alu_out = 32'h55001100;
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'b0;
        exp_eq_flag = 1'b0;
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "AND");

        // ************************************************************************
        // Test Case 16: testing for BEQ control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 16: testing for BEQ control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b1100011;
        tb_alu_op = 3'b000;
        tb_opA = 32'h55551111;
        tb_opB = 32'h55551111;
        exp_alu_out = 32'hx;  // don't care alu_result
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'bx;
        exp_eq_flag = 1'b1;  //asserted
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "BEQ");

        // ************************************************************************
        // Test Case 17: testing for BNE control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 17: testing for BNE control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b1100011;
        tb_alu_op = 3'b001;
        tb_opA = 32'h55551111;
        tb_opB = 32'hff00ff00;
        exp_alu_out = 32'hx;  //unequal operands
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'bx;
        exp_eq_flag = 1'b0;  //eq_flag not asserted
        exp_less_flag = 1'b0;
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "BNE");

        // ************************************************************************
        // Test Case 18: testing for BLT control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 18: testing for BLT control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b1100011;
        tb_alu_op = 3'b100;
        tb_opA = 32'h55551111;
        tb_opB = 32'hff00ff00;
        exp_alu_out = 32'hx;  
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'bx;
        exp_eq_flag = 1'b0;  
        exp_less_flag = 1'b1; //asserted
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "BLT");

        // ************************************************************************
        // Test Case 19: testing for BGE control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 19: testing for BGE control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b1100011;
        tb_alu_op = 3'b101;
        tb_opA = 32'hff00ff00;
        tb_opB = 32'h55551111;
        exp_alu_out = 32'hx;  
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'bx;
        exp_eq_flag = 1'b0;   //maybe asserted
        exp_less_flag = 1'b0; //maybe asserted
        exp_err_flag = 1'b0; 
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "BGE");

        // ************************************************************************
        // Test Case 20: testing for BLTU control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 20: testing for BLTU control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b1100011;
        tb_alu_op = 3'b110;
        tb_opA = 32'h55551111;
        tb_opB = 32'hff00ff00;
        exp_alu_out = 32'hx;  
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'bx;
        exp_eq_flag = 1'b0;  
        exp_less_flag = 1'b1; //asserted
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "BLTU");

        // ************************************************************************
        // Test Case 21: testing for BGEU control input
        // ************************************************************************
        #10
        tb_test_num += 1;
        tb_test_case = "Test Case 21: testing for BGEU control input";
        $display("\n\n%s", tb_test_case);

        tb_opcode = 7'b1100011;
        tb_alu_op = 3'b001;
        tb_opA = 32'h55551111;
        tb_opB = 32'h55551111;
        exp_alu_out = 32'hx;  
        exp_ctrl_err = 1'b0;
        exp_zero_flag = 1'bx;
        exp_eq_flag = 1'b1;  //maybe asserted
        exp_less_flag = 1'b0;  //maybe asserted
        exp_err_flag = 1'b0;
        #10
        check_op_o(exp_alu_out,exp_ctrl_err,exp_zero_flag, exp_eq_flag, exp_less_flag, exp_err_flag, "BGEU");


      
    $finish;
    end
endmodule
