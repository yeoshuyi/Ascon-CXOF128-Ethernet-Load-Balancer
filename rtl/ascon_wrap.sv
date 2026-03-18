module ascon_top ( //WIP
	input logic clk,
	input logic reset,

	input logic data_rdy,
	input logic [103:0] tuple_in,
	
	output logic [63:0]
);

	localparam SECRET_KEY = 64'hABCDEF0123456972; //Temp

	typedef enum logic [3:0] {
		SEND0 = 4'b0001,
		SEND1 = 4'b0010,
		SEND2 = 4'b0100,
		SEND4 = 4'b1000
	} state_t;
	state_t state, next_state;

	logic [63:0] cur_tuple[0:3];
	logic [63:0] cur_digest[0:3];

	logic c0_start, c1_start, c2_start, c3_start;
	logic c0_done, c1_done, c2_done, c3_done;

	ascon_cxof128 core0 (
		.clk(clk),
		.reset(reset),
		.tuple_in(cur_tuple[0]),
		.secret_key(SECRET_KEY),
		.start(c0_start),
		.digest(cur_digest[0]),
		.done(c0_done)
	);
	
	ascon_cxof128 core1 (
		.clk(clk),
		.reset(reset),
		.tuple_in(cur_tuple[1]),
		.secret_key(SECRET_KEY),
		.start(c1_start),
		.digest(cur_digest[1]),
		.done(c1_done)
	);

	ascon_cxof128 core2 (
		.clk(clk),
		.reset(reset),
		.tuple_in(cur_tuple[2]),
		.secret_key(SECRET_KEY),
		.start(c2_start),
		.digest(cur_digest[2]),
		.done(c2_done)
	);

	ascon_cxof128 core3 (
		.clk(clk),
		.reset(reset),
		.tuple_in(cur_tuple[3]),
		.secret_key(SECRET_KEY),
		.start(c3_start),
		.digest(cur_digest[3]),
		.done(c3_done)
	);	

	always_ff @(posedge clk) begin
		if (reset) begin
			state <= SEND0;
			cur_tuple[0] <= 104'b0;
			cur_tuple[1] <= 104'b0;
			cur_tuple[2] <= 104'b0;
			cur_tuple[3] <= 104'b0;
		end else begin
			case (state)
				SEND0: begin

				end

				SEND1: begin

				end

				SEND2: begin

				end

				SEND3: begin

				end
			endcase
		end
	end
endmodule
