module backgroundROM
(
		input [19:0] background_address,
		input Clk,
		output logic [7:0] VGA_R, VGA_G, VGA_B ,
		output logic [3:0] data_Out
);

//
logic [3:0] mem [0:307199];
logic [3:0] palatteVal;
logic [3:0] data_Out_;
logic [7:0] Red, Green, Blue;

initial
begin
	 $readmemh("images/background.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out <= mem[background_address];
end

assign palatteVal = data_Out;
assign VGA_R = Red;
assign VGA_G = Green;
assign VGA_B = Blue; 

//Palette for background
always_comb begin

	unique case(palatteVal)
		4'h00:
			begin
				Red = 8'h80; 
            Green = 8'h00;
            Blue = 8'h80;
			end
		
		4'h01:
			begin
				Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
			end	
		4'h02:
			begin
				Red = 8'hff; 
            Green = 8'hff;
            Blue = 8'hff;
			end		
		4'h03:
			begin
				Red = 8'h20; 
            Green = 8'h20;
            Blue = 8'h20;
			end		
		4'h04:
			begin
				Red = 8'h33; 
            Green = 8'h33;
            Blue = 8'h33;
			end		
		4'h05:
			begin
				Red = 8'h82; 
            Green = 8'h82;
            Blue = 8'h82;
			end		
		4'h06:
			begin
				Red = 8'h91; 
            Green = 8'h91;
            Blue = 8'h91;
			end		
		4'h07:
				begin
				Red = 8'he7; 
            Green = 8'h5b;
            Blue = 8'h11;
			end
		4'h08:
				begin
				Red = 8'hec; 
            Green = 8'h7c;
            Blue = 8'h41;
			end	
		4'h09:
				begin
				Red = 8'hf7; 
            Green = 8'hd6;
            Blue = 8'hb5;
			end
		4'h0a:
				begin
				Red = 8'hf9; 
            Green = 8'hde;
            Blue = 8'hc4;
			end	
		4'h0b:
				begin
				Red = 8'hbd; 
            Green = 8'hff;
            Blue = 8'h18;
			end
		4'h0c:
				begin
				Red = 8'h00; 
            Green = 8'had;
            Blue = 8'h00;
			end	
		4'h0d:
				begin
				Red = 8'h39; 
            Green = 8'hbd;
            Blue = 8'hff;
			end
		4'h0e:
				begin
				Red = 8'h6b; 
            Green = 8'h8c;
            Blue = 8'hff;
			end	
		4'h0f:
				begin
				Red = 8'h89; 
            Green = 8'ha3;
            Blue = 8'hff;
			end	
		default:
		//These are just some garabage values
			begin
				Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f;
			end
	endcase

end

endmodule
