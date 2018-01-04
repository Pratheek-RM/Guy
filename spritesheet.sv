module spritesheet
(
		input [11:0] character_address,
		input Clk,
		output logic [7:0] VGA_R, VGA_G, VGA_B ,
		output logic [3:0] data_Out
);


logic [3:0] mem [0:3071];
logic [3:0] palatteVal;
logic [3:0] data_Out_;
logic [7:0] Red, Green, Blue;

initial
begin
	 $readmemh("images/guy.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out <= mem[character_address];
end

assign palatteVal = data_Out;
assign VGA_R = Red;
assign VGA_G = Green;
assign VGA_B = Blue; 

//Palette for character
always_comb begin

	unique case(palatteVal)
		4'h00:
			begin
			//0xC529A8
				Red = 8'hf9; 
            Green = 8'h06;
            Blue = 8'h06;
			end
		
		4'h01:
			begin
			//0x252121
				Red = 8'h25; 
            Green = 8'h21;
            Blue = 8'h21;
			end	
		4'h02:
			begin
			//0xF4C8C2
				Red = 8'hf4; 
            Green = 8'hc8;
            Blue = 8'hc2;
			end		
		4'h03:
			begin
			//0x5C3C0D
				Red = 8'h5c; 
            Green = 8'h3c;
            Blue = 8'h0d;
			end		
		4'h04:
			begin
			//0xAE6C37
				Red = 8'hae; 
            Green = 8'h6c;
            Blue = 8'h37;
			end		
		4'h05:
			begin
			//0xD89402
				Red = 8'hd8; 
            Green = 8'h94;
            Blue = 8'h02;
			end		
		4'h06:
			begin
			//0xFFBB31
				Red = 8'hff; 
            Green = 8'hbb;
            Blue = 8'h31;
			end		
		4'h07:
				begin
				//0x6AB417
				Red = 8'h6a; 
            Green = 8'hb4;
            Blue = 8'h17;
			end
		4'h08:
				begin
				//0x8CD612
				Red = 8'h8c; 
            Green = 8'hd6;
            Blue = 8'h12;
			end	
		4'h09:
				begin
				//0x2C5418
				Red = 8'h2c; 
            Green = 8'h54;
            Blue = 8'h18;
			end
		4'h0a:
				begin
				//0x398FDF
				Red = 8'h39; 
            Green = 8'h8f;
            Blue = 8'hdf;
			end	
		4'h0b:
				begin
				//0x182B7F
				Red = 8'h18; 
            Green = 8'h2b;
            Blue = 8'h7f;
			end
		4'h0c:
				begin
				//0x4168BF
				Red = 8'h41; 
            Green = 8'h68;
            Blue = 8'hbf;
			end	
		4'h0d:
				begin
				//0x215BC1
				Red = 8'h21; 
            Green = 8'h5b;
            Blue = 8'hc1;
			end

		default:
		//These are just some garabage values
			begin
				Red = 8'hff; 
            Green = 8'hff;
            Blue = 8'hff;
			end
	endcase

end

endmodule
