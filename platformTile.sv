//Significant portions of this module were taken from lab 8's ball.sv, so I'll only commment on our significant changes


module  platform ( input     Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,      // Current pixel 
					input [10:0]  characterX, characterY, progress,
               output logic  is_platform,             // Whether current pixel belongs to platform or background
					
					output [10:0] platformX, platformY,    //Made to be 11 bits because of scolling woul cause overflow otherwise
					output logic  above_platform, bellow_platform //Used in the character module to detect platform collisions
              );
    
    parameter [9:0] Ball_X_Center=320;  //X Position of platform
    parameter [9:0] Ball_Y_Center=220;  //Y Position of platform
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
	 parameter [10:0] Ball_X_Max=1189;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=469;     // Bottommost point on the Y axis
    parameter [9:0] Ball_Width=85;        // Platform Width
	 parameter [9:0] Ball_Height=21;        // platform Height 
    
    logic [9:0] Ball_X_Pos, Ball_Y_Pos;
    logic [9:0] Ball_X_Pos_in, Ball_Y_Pos_in;
	 //Used to keep track of the progress of the scroll
	 logic [12:0] DrawX_plus_progress;
    
	 //scroll position updated
	 assign DrawX_plus_progress = DrawX + progress;
	 
	 int SizeW, SizeH;
	 
	 assign SizeW = Ball_Width;
	 assign SizeH = Ball_Height;
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    logic frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
    end
    assign frame_clk_rising_edge = (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    // Update ball position and motion
	 initial
	 begin
		      Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
	 end
	 
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
        end
        // By defualt, keep the register values.
    end
    
    // You need to modify always_comb block.
    always_comb
    begin
        // Update the ball's position with its motion
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
    
        // By default, keep motion unchanged
        // Be careful when using comparators with "logic" datatype because compiler treats 
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.

		  //Bouncing conditions of lab 8 taken out because they are not appicable to platform logic
        
        // Compute whether the platform should be drawn based on the scroll and the position of the platform
		  if(DrawX_plus_progress >= Ball_X_Pos && DrawX_plus_progress < Ball_X_Pos + SizeW && DrawY >= Ball_Y_Pos && DrawY < Ball_Y_Pos + SizeH )
            is_platform = 1'b1;
        else
            is_platform	= 1'b0;
		  
		  //Computes a "catch box" to determine is the character is about to land on the platform, this box was determined by the character's dimensions and some general approximation 
		  if((characterY <= (Ball_Y_Pos + 9'd30)) && (characterY >= Ball_Y_Pos) && (characterX + progress + 9'd10>= (Ball_X_Pos)) && ((characterX + progress + 9'd10)<= (Ball_X_Pos + Ball_Width)))
            bellow_platform = 1'b1;
        else
            bellow_platform = 1'b0;
		
		  //Computes a "catch box" to determine is the character is about to hit the bottom of the platform, this box was determined by the character's dimensions and some general approximation 
		  if((characterY <= (Ball_Y_Pos)) && (characterY + 9'd30 >= Ball_Y_Pos) && (characterX + progress + 9'd10>= (Ball_X_Pos)) && ((characterX + progress + 9'd10)<= (Ball_X_Pos + Ball_Width)))
            above_platform = 1'b1;
				
        else
            above_platform	= 1'b0;
		 
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
	
    end

//Sends these signals out to be used in color_mapper	 
assign platformX = Ball_X_Pos - progress;
assign platformY = Ball_Y_Pos;
    
endmodule
