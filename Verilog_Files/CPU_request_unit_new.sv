module CPU_request_unit (
    input logic nRst, clk,

    //From CPU
    input logic read_from_CPU,
    input logic write_from_CPU,
    input logic [3:0] sel_from_CPU,
    input logic [31:0] instruction_adr_from_CPU,
    input logic [31:0] data_adr_from_CPU,
    input logic [31:0] data_from_CPU,

    //To CPU
    output logic enable,
    output logic [31:0] instruction,
    output logic [31:0] data,


    //From Mem
    input logic mem_busy,
    input logic [31:0] data_from_mem,

    //To Mem
    output logic write_to_mem,
    output logic read_to_mem,
    output logic [3:0] sel_to_mem,
    output logic [31:0] adr_to_mem,
    output logic [31:0] data_to_mem

);
    logic current_operation; //0 for reading instruction, 1 for loading/storing data with memory
    logic [31:0] next_instruction; //this is for holding instructions for multiple cycles

    always_ff @( posedge clk, negedge nRst ) begin 
        if(~nRst) begin
            current_operation <= 0;

            instruction <= 32'b0;
        end else begin
            if (mem_busy) begin //if mem busy stay on current operation
                current_operation <= current_operation;
            end else begin //if mem not busy, switch operation
                current_operation <= ~current_operation;
            end

            instruction <= next_instruction;
        end
    end

    always_comb begin
        if (current_operation == 0) begin // get instruction from mem
            //Mem signals
            read_to_mem         = 1'b1;
            write_to_mem        = 1'b0;
            sel_to_mem          = 4'b1111;
            adr_to_mem          = instruction_adr_from_CPU;
            data_to_mem         = 32'b0;
            
            //CPU signals
            enable              = 1'b0;
            next_instruction    = data_from_mem;
            data                = 32'b0;
        end else begin // store/load data to mem
            //Mem signals
            read_to_mem         = read_from_CPU;
            write_to_mem        = write_from_CPU;
            sel_to_mem          = sel_from_CPU;
            adr_to_mem          = data_adr_from_CPU;
            data_to_mem         = data_from_CPU;
            
            //CPU signals
            enable              = ~mem_busy;
            next_instruction    = instruction;
            data                = data_from_mem;
        end
    end

endmodule