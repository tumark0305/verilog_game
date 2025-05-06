
module main (clk,reset,	LCD_DATA,	LCD_RW,	LCD_EN,	LCD_RS,	LCD_RST,upB,dwB);	

input	clk;
input	reset;
input	upB;
input	dwB;

output	[7:0]	LCD_DATA;
output	LCD_RW;
output	LCD_EN;
output	LCD_RS;
output	LCD_RST;

reg		[7:0]	LCD_DATA;
reg		LCD_RW;
reg		LCD_EN;
reg		LCD_RS;
reg		LCD_RST;

reg		[3:0]	state;
reg		[17:0]	counter;
reg		[4:0]	DATA_INDEX;
reg		[4:0]	stone0;
reg		[4:0]	cursor;
reg		[1:0]game_state;
reg		[4:0]	stone_speed_counter;



wire		[7:0]	DATA;

//LCDM_table	M1(DATA_INDEX,DATA);
gamingLCD	M1(DATA_INDEX,DATA,game_state,cursor,stone0);

always	@(posedge	clk or negedge	reset)begin
	if(reset)begin//reset state
		LCD_DATA	<= 8'd0;
		LCD_RW	<= 1'b1;
		LCD_EN	<= 1'b1;
		LCD_RS	<= 1'b0;
		state		<= 4'd0;
		counter	<= 18'd0;
		DATA_INDEX	<= 6'd0;
		LCD_RST		<= 1'b1;
		game_state		<= 2'd0;
		stone0				<= 5'd31;
	end
	else begin
		case(state)
			4'd0:begin//begin
				if(DATA_INDEX == 6'd32)
					state	<= 4'd4;
				else begin
					state	<= 4'd1;
				end
				LCD_RST		<= 1'b0;
			end
			// set RS,EN,RW,DATA
			4'd1:begin//sent data
				LCD_EN	<= 1'b1;
				LCD_RS	<= 1'b1;
				LCD_RW	<= 1'b0;
				LCD_RST	<= 1'b0;
				LCD_DATA <= DATA[7:0];
				state		<= 4'd2;
			end
			4'd2:begin// delay
				if(counter	< 18'd1)//
					counter	<= counter+18'd1;
				else
					state		<= 4'd3;
			end
			4'd3:begin//data_index++
				LCD_EN	<= 1'b0;
				counter	<= 18'd0;	
				DATA_INDEX		<= DATA_INDEX+6'd1;
				state		<= 4'd0;
			end
			4'd4:begin//input and proc pos
				state		<= 4'd1;
				LCD_RST		<= 1'b1;
				if(game_state==0 || game_state==3)begin//gaming
					if(upB || dwB)	game_state		<= 2'd1;
				end
				else if(game_state==1)begin//gaming
					if(upB)	cursor[4] = 0;
					if(dwB)	cursor[4] = 1;
					if(stone0==cursor)game_state		<= 2'd3;
					if(stone_speed_counter==0) stone0 = stone0 - 1;
					stone_speed_counter  = stone_speed_counter + 1 ;
				end
			end
			4'd10:begin//died
				state		<= 4'd10;
			end
			default:;
		endcase
	end
end
endmodule

module 	LCDM_table (table_index,data_out);
input		[4:0]table_index;
output	reg	[7:0]data_out;

always@(table_index)begin
	case(table_index)
		//display 1st page
		5'd0: data_out = 8'h2E; // first row   ܲĤ@  q o 䥴~~
		5'd1: data_out = 8'h54; 
		5'd2: data_out = 8'h55;
		5'd3: data_out = 8'h53;
		5'd4: data_out = 8'h54;
		5'd5: data_out = 8'h5F;
		5'd6: data_out = 8'h25;
		5'd7: data_out = 8'h25;
		5'd8: data_out = 8'h5F;
		5'd9: data_out = 8'h5F;
		5'd10: data_out = 8'h5F;
		5'd11: data_out = 8'h5F;
		5'd12: data_out = 8'h5F;
		5'd13: data_out = 8'h5F;
		5'd14: data_out = 8'h5F;
		5'd15: data_out = 8'h5F;
		5'd16: data_out = 8'h26; // second row  ܲĤG  q o 䥴~~
		5'd17: data_out = 8'h30;
		5'd18: data_out = 8'h27;
		5'd19: data_out = 8'h21;
		5'd20: data_out = 8'h5F;
		5'd21: data_out = 8'h43;
		5'd22: data_out = 8'h4F;
		5'd23: data_out = 8'h55;
		5'd24: data_out = 8'h52;
		5'd25: data_out = 8'h53;
		5'd26: data_out = 8'h45;
		5'd27: data_out = 8'h5F;
		5'd28: data_out = 8'h5F;
		5'd29: data_out = 8'h5F;
		5'd30: data_out = 8'h5F;
		5'd31: data_out = 8'h5F; // finish	
		//default:data_out = 8'h000;
	endcase
end
endmodule

module 	gamingLCD (selected_index,data_out,game_state,cursor_index,stone_index);
input		[1:0]game_state;
input		[4:0]stone_index;
input		[4:0]cursor_index;
input		[4:0]selected_index;
output	reg	[7:0]data_out;

always@(selected_index)begin
	case(game_state)
		2'd0 : begin//start animate
			case(selected_index)
				5'd0 : data_out = 8'h52; // R
				5'd1 : data_out = 8'h75; // u
				5'd2 : data_out = 8'h6E; // n
				5'd3 : data_out = 8'h20; // space
				5'd4 : data_out = 8'h74; // t
				5'd5 : data_out = 8'h6F; // o
				5'd6 : data_out = 8'h20; // space
				5'd7 : data_out = 8'h74; // t
				5'd8 : data_out = 8'h65; // e
				5'd9 : data_out = 8'h72; // r
				5'd10: data_out = 8'h6D; // m
				5'd11: data_out = 8'h69; // i
				5'd12: data_out = 8'h6E; // n
				5'd13: data_out = 8'h61; // a
				5'd14: data_out = 8'h6C; // l
				5'd15: data_out = 8'h20; // space
				5'd16: data_out = 8'h70; // p
				5'd17: data_out = 8'h72; // r
				5'd18: data_out = 8'h65; // e
				5'd19: data_out = 8'h73; // s
				5'd20: data_out = 8'h73; // s
				5'd21: data_out = 8'h20; // space
				5'd22: data_out = 8'h61; // a
				5'd23: data_out = 8'h6E; // n
				5'd24: data_out = 8'h79; // y
				5'd25: data_out = 8'h20; // space
				5'd26: data_out = 8'h73; // s
				5'd27: data_out = 8'h74; // t
				5'd28: data_out = 8'h61; // a
				5'd29: data_out = 8'h72; // r
				5'd30: data_out = 8'h74; // t
				5'd31: data_out = 8'h20; // space
				//default:data_out = 8'h000;
			endcase
		end
		//display 1st page
		2'd1:begin//gaming
			if(selected_index==cursor_index)
				begin
					data_out = 8'h3E;//<
				end
			else if(selected_index==stone_index)
				begin
					data_out = 8'h7C; //|
				end
			else
				begin
					data_out = 8'h20; // space
				end
		end
		2'd3 : begin//end animate
			case(selected_index)
				5'd0  : data_out = 8'h20; // space
				5'd1  : data_out = 8'h20; // space
				5'd2  : data_out = 8'h59; // Y
				5'd3  : data_out = 8'h6F; // o
				5'd4  : data_out = 8'h75; // u
				5'd5  : data_out = 8'h20; // space
				5'd6  : data_out = 8'h20; // space
				5'd7  : data_out = 8'h2A; // * (ASCII for '*')
				5'd8  : data_out = 8'h20; // space
				5'd9  : data_out = 8'h20; // space
				5'd10 : data_out = 8'h44; // D
				5'd11 : data_out = 8'h69; // i
				5'd12 : data_out = 8'h65; // e
				5'd13 : data_out = 8'h64; // d
				5'd14 : data_out = 8'h20; // space
				5'd15 : data_out = 8'h20; // space
				5'd16 : data_out = 8'h70; // p
				5'd17 : data_out = 8'h72; // r
				5'd18 : data_out = 8'h65; // e
				5'd19 : data_out = 8'h73; // s
				5'd20 : data_out = 8'h73; // s
				5'd21 : data_out = 8'h20; // space
				5'd22 : data_out = 8'h61; // a
				5'd23 : data_out = 8'h6E; // n
				5'd24 : data_out = 8'h79; // y
				5'd25 : data_out = 8'h20; // space
				5'd26 : data_out = 8'h73; // s
				5'd27 : data_out = 8'h74; // t
				5'd28 : data_out = 8'h61; // a
				5'd29 : data_out = 8'h72; // r
				5'd30 : data_out = 8'h74; // t
				5'd31 : data_out = 8'h20; // space
				//default:data_out = 8'h000;
			endcase
		end
		//default:data_out = 8'h000;
	endcase
	
end
endmodule

