//Significant portions of this module were taken from lab 8's ball.sv, so I'll only commment on our significant changes


module  enemy ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
									  dead,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [10:0]  progress,
               output logic  is_enemy,           // Whether current pixel belongs to enemy or background
									  enemyDir,           //Signals the direction the enemy is facing  
					output logic [10:0] enemyX, enemyY, // used in color_mapper and collsion detection
					                     enemyXmotion   //used in collsion detection
              );
    
    parameter [10:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [10:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Ball_X_Max=1189;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=402;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=2;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=20;     // Step size on the Y axis
	//height and width of the character												
    parameter [9:0] Ball_Width=16;        // enemy Width
	 parameter [9:0] Ball_Height=24;        // enemy Height 
    
	 //These logic elements were 10 bits before, but were changed to 11 bits, because scroll caused overflow
    logic [10:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [10:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 //Tells color mapper the direction the enemy is facing
	 logic enemyDir_;
	 //Used to keep track of the scroll
	 logic [12:0] DrawX_plus_progress;
	 
	 //scroll position updated
	 assign DrawX_plus_progress = DrawX + progress;
	 //This is sent to the character module to use for collsion detection
	 assign enemyXmotion = Ball_X_Motion;
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
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
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd1;
            Ball_Y_Motion <= 10'd0;
				enemyDir <= 1'b1;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				enemyDir <= enemyDir_;
        end
        // By defualt, keep the register values.
    end
    
    // You need to modify always_comb block.
    always_comb
    begin
        // If the enemy and character have collided, they will stop moving
		  if(dead)
		  begin
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
		  end
		  else
		  begin
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
		  end
    
        
        Ball_X_Motion_in = Ball_X_Motion;
		  enemyDir_ = enemyDir;
		  
		  //Gravity code. If the enemy isn't touching the ground, then gravity will apply
		  if(Ball_Y_Pos + Ball_Height != Ball_Y_Max)
			Ball_Y_Motion_in = Ball_Y_Motion + 1;
		  else
			Ball_Y_Motion_in = Ball_Y_Motion;
		 

		
	  //Handles collsion with the ground	
	  if( Ball_Y_Pos + Ball_Height >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
			begin
			if(Ball_Y_Pos + Ball_Height != Ball_Y_Max)
				begin
				Ball_Y_Pos_in = Ball_Y_Max - Ball_Height;
				Ball_Y_Motion_in = 1'b0;
				end
			end

     else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Height )  // Ball is at the top edge, BOUNCE!
         Ball_Y_Motion_in = Ball_Y_Step; 

	  if (Ball_X_Pos + Ball_Width >= 10'd700 )// Ball is at the right edge, BOUNCE!
	  begin
			Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); //2's complement.
			enemyDir_ = 1'b0;
		end

	  else if (Ball_X_Pos <= Ball_X_Min + Ball_Width ) // Ball is at the left edge, BOUNCE!
	  begin
			Ball_X_Motion_in = Ball_X_Step;
			enemyDir_ = 1'b1;
		end
	  		  
        
        // TODO: Add other boundary conditions and handle keypress here.
        
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #2/2:
          Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
          Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
          What is the difference between writing
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
          How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
          Give an answer in your Post-Lab.
    **************************************************************************************/
        
        // Compute whether the enemy should be drawn based on the scroll and the position of the platform
		  if(DrawX_plus_progress >= Ball_X_Pos && DrawX_plus_progress < Ball_X_Pos + SizeW && DrawY >= Ball_Y_Pos && DrawY < Ball_Y_Pos + SizeH )
			begin
            is_enemy = 1'b1;
			end
        else
			begin
            is_enemy = 1'b0;
			end
        
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */

    end

//Sends these signals out to be used in color_mapper		 
assign enemyX = Ball_X_Pos - progress;
assign enemyY = Ball_Y_Pos;
    
endmodule
