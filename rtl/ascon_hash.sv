module ascon_hash (
    input logic clk,
    input logic reset,
    input logic [103:0] tuple_in, //IPv4 MAC Header + IP Payload
    input logic start,

    output logic [63:0] digest,
    output logic done
);

    //localparam logic [63:0] ASCON_HASH_IV = 64'h00400c0000000100;
    localparam logic [319:0] INIT_PRECOMPUTE = 320'hee9398aadb67f03d8bb21831c60f1002b48a92db98d5da6243189921b8f8e3e8348fa5c9d525e140;
    
    typedef enum logic [4:0] { //1-Hot
        IDLE     = 5'b00001,
        INIT     = 5'b00010,
        ABSORB_0 = 5'b00100,
        ABSORB_1 = 5'b01000,
        SQUEEZE  = 5'b10000
    } state_t;
    
    state_t state;

    logic [319:0] state_reg;
    logic [319:0] perm_in, perm_out;
    logic [2:0]   delay_cnt;
    
    logic [63:0] block0, block1;
    assign block0 = tuple_in[103:40];
    assign block1 = {tuple_in[39:0], 1'b1, 23'h0};

    ascon_permute ascon_core (
        .clk(clk),
        .reset(reset),
        .state_in(perm_in),
        .state_out(perm_out)
    );

   always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            state_reg <= INIT_PRECOMPUTE;
            delay_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= ABSORB_1;
                        delay_cnt <= 0;
                    end
                end

                ABSORB_1: begin
                    if (delay_cnt == 3) begin
                        state_reg <= perm_out;
                        state <= SQUEEZE;
                        delay_cnt <= 0;
                    end else begin
                        delay_cnt <= delay_cnt + 1;
                    end
                end

                SQUEEZE: begin
                    if (delay_cnt == 3) begin                    
                        if (start) begin
                            state <= ABSORB_1;
                            delay_cnt <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        delay_cnt <= delay_cnt + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    always_comb begin
        if (state == IDLE ||
            (state == ABSORB_1 && delay_cnt < 3) ||
            (state == SQUEEZE && delay_cnt == 3 && start == 1)) begin
            perm_in = INIT_PRECOMPUTE ^ {block0, 256'b0};
        end
        else if (state == ABSORB_1 && delay_cnt == 3) begin
            perm_in = perm_out ^ {block1, 256'b0};
        end
        else begin
            perm_in = state_reg ^ {block1, 256'b0};
        end
    end

    assign done   = (state == SQUEEZE && delay_cnt == 3);
    assign digest = (state == SQUEEZE && delay_cnt == 3) ? perm_out[319:256] : 64'h0;

endmodule