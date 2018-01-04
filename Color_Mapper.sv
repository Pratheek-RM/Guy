//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_character,	Clk, enemy1,			  // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
							  input 					frame_clk, dead,
							  input 			[10:0] characterX, characterY, enemy1X, enemy1Y, progress, platform1X, platform1Y,
							//  input        [1:0] character_dir,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
							  input					a_on, d_on, enemyDir1, platform1,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue, Back_R, Back_G, Back_B, Back_R_, Back_G_, Back_B_, Char_R_, Char_G_, Char_B_, Char_R, Char_G, Char_B, 
						Enemy_B_1_, Enemy_R_1_, Enemy_G_1_, Enemy_B_1, Enemy_R_1, Enemy_G_1, Tile_R_1, Tile_G_1, Tile_B_1, Tile_R_1_,
						Tile_G_1_, Tile_B_1_, is_transperent, enemy1_Transperent;
	 //used to index into each ROM
	 logic [19:0] background_address;
	 logic [11:0] character_address, enemy_address, offset, offset_;
	 logic [10:0] tile_address;
	 //used to determine which frame to display, used for animations
	 logic [2:0]  characterFrame, characterFrame_, enemy1Frame, enemy1Frame_;
	 //Used for non-rectangular shapes are displayed properly
	 logic [3:0]  is_Transperent;
	 //used for animations
	 logic [3:0] characterCounter, characterCounter_; 
	 logic [3:0] enemyCounter_, enemyCounter;
	 
	 logic frame_clk_delayed;
    logic frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
    end
    assign frame_clk_rising_edge = (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
	 
	 
    initial
	 begin
	 offset = 1'b0;
 	 characterCounter = 1'b0;
	 characterFrame = 0;
	 
 	 enemyCounter = 1'b0;
	 enemy1Frame = 0;
	// enemy1offset = 1'b0;
	 end
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 //ROM indexes calculared
	 assign background_address = DrawX + progress + (DrawY * 10'd640);
	 assign character_address = (DrawX - characterX) + ((DrawY - characterY) * 7'd64)+ offset + (characterFrame * 10'd16); 
	 assign enemy_address = (DrawX - enemy1X) + ((DrawY - enemy1Y) * 7'd64) + (enemyDir1 * 11'd1536) + (enemy1Frame * 10'd16);
	 assign tile_address = (DrawX - platform1X) + ((DrawY - platform1Y) * 7'd85);
	 
	 backgroundROM background(.background_address, 
								  	.Clk, 
									.VGA_B(Back_B_), 
									.VGA_G(Back_G_), 
									.VGA_R(Back_R_)
	 
	 );
	 
	 spritesheet s_character(.character_address,
								    .Clk,
									 .VGA_B(Char_B_),
									 .VGA_G(Char_G_),
									 .VGA_R(Char_R_),
									 .data_Out(is_Transperent)
									 );

	 spriteenemy enemy1sprite(.enemy_address,
									  .Clk,
									  .VGA_B(Enemy_B_1_),
									  .VGA_G(Enemy_G_1_),
									  .VGA_R(Enemy_R_1_),
									  .data_Out(enemy1_Transperent)
									 );
	 
	 spritetile tile1sprite(.tile_address,
									  .Clk,
									  .VGA_B(Tile_B_1_),
									  .VGA_G(Tile_G_1_),
									  .VGA_R(Tile_R_1_)
								);
	always_ff @ (posedge Clk) begin
	//	if(d_on && DrawX - currentpositionX >= 0 && DrawX - currentpositionX < 10d'16 && DrawY - currentpositionY >= 0 && DrawY - currentpositionY < 10d'16)
	//		character_address = (DrawX - currentpositionX) + (DrawY - currentpositionY) * 10'd24 + spritenum * 10d'16; 
	//	else if(a_on&& DrawX - currentpositionX >= 0 && DrawX - currentpositionX < 10d'16 && DrawY - currentpositionY >= 0 && DrawY - currentpositionY < 10d'16)
	//		character_address = (DrawX - currentpositionX) + (DrawY - currentpositionY) * 10'd24 + spritenum * 10d'16 + 10d'1536; 
			
		Back_R <= Back_R_; 
		Back_G <= Back_G_; 
		Back_B <= Back_B_; 
		
		Char_R <= Char_R_; 
		Char_G <= Char_G_; 
		Char_B <= Char_B_;
		
		Enemy_R_1 <= Enemy_R_1_;
		Enemy_G_1 <= Enemy_G_1_;
		Enemy_B_1 <= Enemy_B_1_;
		
		Tile_R_1 <= Tile_R_1_;
		Tile_G_1 <= Tile_G_1_;
		Tile_B_1 <= Tile_B_1_;
	
		if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            characterCounter <= characterCounter_ + 1;
				enemyCounter <= enemyCounter_ + 1;
        end
		  
		characterFrame <= characterFrame_;
		enemy1Frame <= enemy1Frame_;

		offset <= offset_;
		//enemy1offset <= enemy1offset_;
	end
    // Assign color based on is_ball signal
    always_comb
    begin
	 
			characterCounter_ = characterCounter;
			enemyCounter_ = enemyCounter;

			//Counters for both enemy and character's animations are 32 bits long, so the frame is determined by where the counter is
			//And the counters do not need to be reset due to overflow
			
			if(enemyCounter < 4'd8 || dead)
			begin
				enemy1Frame_ = 3'd0;
			end
			else if(enemyCounter < 4'd16)
			begin
				enemy1Frame_ = 3'd1;
			end
			else if(enemyCounter < 4'd24)
			begin
				enemy1Frame_ = 3'd2;
			end
			else
			begin
				enemy1Frame_ = 3'd3;
			end			
			
			if(characterCounter < 4'd8)
			begin
				characterFrame_ = 3'd0;
			end
			else if(characterCounter < 4'd16)
			begin
				characterFrame_ = 3'd1;
			end
			else if(characterCounter < 4'd24)
			begin
				characterFrame_ = 3'd2;
			end
			else
			begin
				characterFrame_ = 3'd3;
			end

				
//Offset based on the direction of the character				
			if(d_on && (!a_on))
				begin
				offset_ = 1'b0;
				//characterCounter_ = characterCounter + 1;
				characterFrame_ = characterFrame_;
				//characterCounter_ = characterCounter + 1;
				end
			else if(a_on && (!d_on))
				begin
				offset_ = 11'd1536;
				characterFrame_ = characterFrame_;
				//characterCounter_ = characterCounter + 1;
				end
			else
				begin
				offset_ = offset;
				characterFrame_ = 0;
				characterCounter_ = 0;
				end
			
		 
		 if (platform1)
		  begin
				Red = Tile_R_1;
				Green = Tile_G_1;
				Blue = Tile_B_1;
		  end
        else if (is_character == 1'b1 && is_Transperent != 4'h00) 
        begin
            // White ball
            Red =   Char_R;
            Green = Char_G;
            Blue =  Char_B;
        end
		  else if (enemy1 == 1'b1 && enemy1_Transperent != 4'h00)
		  begin
				Red = Enemy_R_1;
				Green = Enemy_G_1;
				Blue = Enemy_B_1;				
			end
        else 
        begin
            // Background with nice color gradient
            //Red = 8'h3f; 
            //Green = 8'h00;
            //Blue = 8'h7f - {1'b0, DrawX[9:3]};
				Red = Back_R; 
            Green = Back_G;
            Blue = Back_B;
        end
    end 
    
endmodule
