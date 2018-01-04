module spritetile
(
		input [10:0] tile_address,
		input Clk,
		output logic [7:0] VGA_R, VGA_G, VGA_B ,
		output logic [3:0] data_Out
);

logic [3:0] mem [0:1785];
logic [3:0] palatteVal;
logic [3:0] data_Out_;
logic [7:0] Red, Green, Blue;

initial
begin
	 $readmemh("images/1x4_tile.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out <= mem[tile_address];
end

assign palatteVal = data_Out;
assign VGA_R = Red;
assign VGA_G = Green;
assign VGA_B = Blue; 

//Palette for platform
always_comb begin

	unique case(palatteVal)
		4'h00:
			begin
			//0x000000
				Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h00;
			end
		
		4'h01:
			begin
			//0xFCE6D4
				Red = 8'hfc; 
            Green = 8'he6;
            Blue = 8'hd4;
			end	
		4'h02:
			begin
			//0xFFFFFFF
				Red = 8'hff; 
            Green = 8'hff;
            Blue = 8'hff;
			end		
		4'h03:
			begin
			//0x241A16
				Red = 8'h24; 
            Green = 8'h1a;
            Blue = 8'h16;
			end		
		4'h04:
			begin
			//0x786660
				Red = 8'h78; 
            Green = 8'h66;
            Blue = 8'h60;
			end		
		4'h05:
			begin
			//0xCE200E
				Red = 8'hce; 
            Green = 8'h20;
            Blue = 8'h0e;
			end		
		4'h06:
			begin
			//0xAE8468
				Red = 8'hae; 
            Green = 8'h84;
            Blue = 8'h68;
			end		
		4'h07:
				begin
				//0x5A2406
				Red = 8'h5a; 
            Green = 8'h24;
            Blue = 8'h06;
			end
		4'h08:
				begin
				//0x2B3136
				Red = 8'h2b; 
            Green = 8'h31;
            Blue = 8'h36;
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
