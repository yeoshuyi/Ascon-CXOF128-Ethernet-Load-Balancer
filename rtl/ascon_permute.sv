module ascon_permute (
    input logic [319:0] state_in,
    input logic [319:0] state_out
); 
    localparam logic [12*8-1:0] ROUND_CONSTS = {
        8'hf0, 8'he1, 8'hd2, 8'hc3, 
        8'hb4, 8'ha5, 8'h96, 8'h87, 
        8'h78, 8'h69, 8'h5a, 8'h4b
    };

    logic [63:0] s0[0:12], s1[0:12], s2[0:12], s3[0:12], s4[0:12];
    logic [63:0] r0_q4, r1_q4, r2_q4, r3_q4, r4_q4;
    logic [63:0] r0_q8, r1_q8, r2_q8, r3_q8, r4_q8;
    
    assign {s0[0], s1[0], s2[0], s3[0], s4[0]} = state_in;

    genvar i;
    generate
        for (i = 0; i < 12; i++) begin: gen_ascon_rounds

            logic [63:0] cur_x0, cur_x1, cur_x2, cur_x3, cur_x4;

            if (i == 4) begin //Round 4 uses Reg
                assign {cur_x0, cur_x1, cur_x2, cur_x3, cur_x4} = {r0_q4, r1_q4, r2_q4, r3_q4, r4_q4};
            end else if (i == 8) begin //Round 8 uses Reg
                assign {cur_x0, cur_x1, cur_x2, cur_x3, cur_x4} = {r0_q8, r1_q8, r2_q8, r3_q8, r4_q8};
            end else begin
                assign {cur_x0, cur_x1, cur_x2, cur_x3, cur_x4} = {s0[i], s1[i], s2[i], s3[i], s4[i]};
            end

            ascon_round round_inst(
                .x0(s0[i]), .x1(s1[i]), .x2(s2[i]), .x3(s3[i]), .x4(s4[i]),
                .round_const(ROUND_CONSTS[(11-i)*8 +: 8]),
                .y0(s0[i+1]), .y1(s1[i+1]), .y2(s2[i+1]), .y3(s3[i+1]), .y4(s4[i+1])
            );
        end
    endgenerate

    assign state_out = {s0[12], s1[12], s2[12], s3[12], s4[12]};
endmodule