module keycodeReader( input  [31:0] keycode,
							 input [2:0] KEY, 
							 output w_on, s_on, a_on, d_on
                   );

//checks all 32 bits in 4 8 bits segments to see if the key is being pressed
//Button presses are also accounted for						 
	assign w_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A |
					(~KEY[1])); 
 
	assign s_on = (keycode[31:24] == 8'h16 |
               keycode[23:16] == 8'h16 |
               keycode[15: 8] == 8'h16 |
               keycode[ 7: 0] == 8'h16);	
					
	assign a_on = (keycode[31:24] == 8'h04 |
               keycode[23:16] == 8'h04 |
               keycode[15: 8] == 8'h04 |
               keycode[ 7: 0] == 8'h04 |
					 (~KEY[2])); 
	assign d_on = (keycode[31:24] == 8'h07 |
               keycode[23:16] == 8'h07 |
               keycode[15: 8] == 8'h07 |
               keycode[ 7: 0] == 8'h07 |
					(~KEY[0])); 						
						 
			
endmodule 
