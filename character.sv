//Significant portions of this module were taken from lab 8's ball.sv, so I'll only commment on our significant changes


module  character ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY, 
					input [10:0] enemyX, enemyY, enemyXmotion,      // Current pixel coordinates
					input			  w_on, s_on, a_on, d_on, above_platform1, bellow_platform1,
               output logic  is_character,        //Signal the says character should be drawn   
					                      dead,        //Triggers end game logic, where charcter and enemy will stop moving
					output logic [10:0]   characterX, characterY, progress
              );
    
    parameter [9:0] Ball_X_Center=120;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Ball_X_Max=1189;   // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=402;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=2;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=20;     // Step size on the Y axis
	//height and width of the character												
    parameter [9:0] Ball_Width=16;        // character Width
	 parameter [9:0] Ball_Height=24;        // character Height 
	 
	 //These logic elements were 10 bits before, but were changed to 11 bits, because scroll caused overflow
    logic [10:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [10:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in, progress_in;
	 
	 //Used to keep track of the scroll
	 logic [12:0] DrawX_plus_progress;
	 logic dead_;
	 
	 //scroll position updated
	 assign DrawX_plus_progress = DrawX + progress;
	// logic [1:0] character_dir_;
    
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */

	 int SizeW, SizeH;

    assign SizeW = Ball_Width;
	 assign SizeH = Ball_Height;
	 
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    logic frame_clk_rising_edge;
	 
// initial
// begin
// character_dir = 2'd1;
// end
	 
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
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				progress <= 10'd0;
				dead <= 10'd0;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				progress <= progress_in;
				dead <= dead_;
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
		  progress_in = progress;
		  
		  //platform collision (bottom)
		  if(bellow_platform1 && (Ball_Y_Motion >0))
				Ball_Y_Motion_in = 3'd5;
        //platform collision (top)
		  else if(above_platform1 && (Ball_Y_Motion >0) /*&& (Ball_Y_Pos >= 9'd180) */&& (Ball_Y_Pos <= 9'd200))
				begin
			   Ball_Y_Motion_in = 1'b0;
				Ball_X_Motion_in = 1'b0;
				end
			//platform collision (top)	
		  else if(above_platform1 && (Ball_Y_Motion == 0))
			  begin
			  //If a is being pressed and d is not, move left
				if(a_on && (!d_on))
					Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
			  //If d is being pressed and a is not, move left
			    else if((!a_on) && d_on )
					Ball_X_Motion_in = Ball_X_Step;			
				//handels if both and a and d are being pressed	
			    else
					Ball_X_Motion_in = 1'b0;
			
            //If w is pressed, and there hasn't been a collision with the enemy
			    if(w_on && !dead)
					Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
					
				 else
					Ball_Y_Motion_in = Ball_Y_Motion;
			   end
       //Gravity code. If the enemy isn't touching the ground or on tile, then gravity will apply
			else if(Ball_Y_Pos + Ball_Height != Ball_Y_Max)
				Ball_Y_Motion_in = Ball_Y_Motion + 1;
			else
				Ball_Y_Motion_in = Ball_Y_Motion;

		 //Scroll determined based on character movement
		 //(Scroll right)
		  if(Ball_X_Pos >= (10'd550 + progress) && /*Ball_X_Motion >= 0*/ (d_on))
					begin
						if(progress < 10'd640)
						 begin
							progress_in = progress + Ball_X_Step;
							//Ball_X_Motion_in = 1'd0;
						 end
						else
						begin
							progress_in = progress;
							//Ball_X_Motion_in = Ball_X_Motion;
						end
					end
		//(Scoll left)		
		  if(Ball_X_Pos <= (9'd50 + progress) && (a_on))
				begin
						if(progress > 10'd0)
						 begin
							progress_in = progress + (~(Ball_X_Step) + 1'b1);
							//Ball_X_Motion_in = 1'd0;
						 end
						else
						begin
							progress_in = progress;
							//Ball_X_Motion_in = Ball_X_Motion;
						end
				end
		 

		
//Handles collsion with the ground				
 if( Ball_Y_Pos + Ball_Height >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
		begin
			if(Ball_Y_Pos + Ball_Height == Ball_Y_Max)
			 begin
			 //If a is being pressed and d is not, move left
				if(a_on && (!d_on) /*&& Ball_X_Pos >= 9'd50*/)
					begin
						//if(Ball_X_Pos <= 4'd10 + progress)
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
						//character_dir = 2'd2;
					end
			 //If d is being pressed and a is not, move left
			  else if((!a_on) && d_on /*&& Ball_X_Pos <= 10'd550*/)
					begin
					/*if(Ball_X_Pos >= 9'd500)
					begin
							progress_in = progress + Ball_X_Step;
							Ball_X_Motion_in = 1'd0;
					end
					else*/
						Ball_X_Motion_in = Ball_X_Step;
					//character_dir = 2'd1;
					end
			 //handels if both and a and d are being pressed	
			  else
					Ball_X_Motion_in = 1'b0;
		
          //If w is pressed, and there hasn't been a collision with the enemy
			  if(w_on && !dead)
			  begin
					Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
			  end
				
			end
				else
				  begin
					Ball_Y_Pos_in = Ball_Y_Max - Ball_Height;
					Ball_Y_Motion_in = 1'b0;
				  end
		end

	  if (Ball_X_Pos + Ball_Width >= Ball_X_Max )// Ball is at the right edge, BOUNCE!
		begin
			Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); //2's complement.
		end
	  else if (Ball_X_Pos <= Ball_X_Min + Ball_Width ) // Ball is at the left edge, BOUNCE!
		begin
			Ball_X_Motion_in = Ball_X_Step;
			//character_dir = 2'd1;
		end
			
        
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
        
        //if ( (!((DistX <= SizeW)^((DistX * -1) <= SizeW))) && (!((DistY <= SizeH)^((DistY * -1) <= SizeH))) )
		  
		  // Compute whether the character should be drawn based on the scroll and the position of the platform
		  if(DrawX_plus_progress >= Ball_X_Pos && DrawX_plus_progress < Ball_X_Pos + SizeW && DrawY >= Ball_Y_Pos && DrawY < Ball_Y_Pos + SizeH )
			begin
            is_character = 1'b1;

			end
        else
			begin
            is_character = 1'b0;
			end

			  
			//Detects enemy and character collsion based on the motion and position of each object
			if( ((Ball_X_Pos + Ball_X_Motion) <= (4'd10 + enemyX + progress + enemyXmotion)) && ((Ball_X_Pos + Ball_X_Motion+4'd10) >= (enemyX + progress + enemyXmotion)) && ((Ball_Y_Pos + Ball_Y_Motion) <= (4'd10 + enemyY)) && ((Ball_Y_Pos + Ball_Y_Motion+4'd10) >= enemyY))
			dead_ = 1'b1;
		  else
			dead_ = 1'b0;
    end
	 	 
//used in color_mapper	 
assign characterX = Ball_X_Pos - progress;
assign characterY = Ball_Y_Pos;
 

    
endmodule
