module ascon (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    output logic [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    logic [63:0] x0_s [0:8];
    logic [63:0] x1_s [0:8];
    logic [63:0] x2_s [0:8];
    logic [63:0] x3_s [0:8];
    logic [63:0] x4_s [0:8];

    always_comb begin
        x0_s[0] = x0_in;
        x1_s[0] = x1_in;
        x2_s[0] = x2_in;
        x3_s[0] = x3_in;
        x4_s[0] = x4_in;
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_ascon_pipeline
            logic [63:0] r_out [0:4];
            
            ascon_permute round_inst (
                .x0_in(x0_s[i]), .x1_in(x1_s[i]), .x2_in(x2_s[i]), .x3_in(x3_s[i]), .x4_in(x4_s[i]),
                .round_constant(4'h4 + i[3:0]), 
                .x0_out(r_out[0]), .x1_out(r_out[1]), .x2_out(r_out[2]), .x3_out(r_out[3]), .x4_out(r_out[4])
            );

            if ((i + 1) % 2 == 0) begin : stage_reg
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        x0_s[i+1] <= 64'b0; x1_s[i+1] <= 64'b0; x2_s[i+1] <= 64'b0;
                        x3_s[i+1] <= 64'b0; x4_s[i+1] <= 64'b0;
                    end else begin
                        x0_s[i+1] <= r_out[0]; x1_s[i+1] <= r_out[1]; x2_s[i+1] <= r_out[2];
                        x3_s[i+1] <= r_out[3]; x4_s[i+1] <= r_out[4];
                    end
                end
            end else begin : stage_wire
                always_comb begin
                    x0_s[i+1] = r_out[0]; x1_s[i+1] = r_out[1]; x2_s[i+1] = r_out[2];
                    x3_s[i+1] = r_out[3]; x4_s[i+1] = r_out[4];
                end
            end
        end
    endgenerate

    assign x0_out = x0_s[8];
    assign x1_out = x1_s[8];
    assign x2_out = x2_s[8];
    assign x3_out = x3_s[8];
    assign x4_out = x4_s[8];

endmodule