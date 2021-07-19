module	LCD_TEST (	
	//	Host Side
	input iCLK,
	input iRST_N,
	input [9:0] Percent,
	input [11:0] Score,
	//	LCD Side
	output [7:0] LCD_DATA,
	output LCD_RW,
	output LCD_EN,
	output LCD_RS	
);

//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
wire		mLCD_Done;
wire [3:0] percent_dec0;
wire [3:0] percent_dec1;
wire [3:0] percent_dec2;
wire [3:0] percent_dec3;
wire [3:0] score_dec0;
wire [3:0] score_dec1;
wire [3:0] score_dec2;
wire [3:0] score_dec3;

parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;

assign percent_dec0 = Percent % 10;
assign percent_dec1 = ( Percent / 10 ) % 10;
assign percent_dec2 = ( Percent / 100 ) % 10;
assign percent_dec3 = Percent / 1000;
assign score_dec0 = Score % 10;
assign score_dec1 = ( Score / 10 ) % 10; 
assign score_dec2 = ( Score / 100 ) % 10;
assign score_dec3 = Score / 1000;

always@(posedge iCLK or negedge iRST_N) begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY+1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mLCD_ST	<=	0;
				end
			endcase
		end
		else if(LUT_INDEX == LUT_SIZE)
			LUT_INDEX = 3;
	end
end

always@(*) begin
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;//function set
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;//display on/off control
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;//clear display
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;//entry mode set
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;//write data into internal ram
	//  Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h120;//space
	LCD_LINE1+1:	LUT_DATA	<=	9'b101010011;//S
	LCD_LINE1+2:	LUT_DATA	<=	9'b101100011;//c
	LCD_LINE1+3:	LUT_DATA	<=	9'b101101111;//o
	LCD_LINE1+4:	LUT_DATA	<=	9'b101110010;//r
	LCD_LINE1+5:	LUT_DATA	<=	9'b101100101;//e
	LCD_LINE1+6:	LUT_DATA	<=	9'b100111010;//:
	LCD_LINE1+7:	LUT_DATA	<=	9'b100110000 + score_dec3;//score_dec3
	LCD_LINE1+8:	LUT_DATA	<=	9'b100110000 + score_dec2;//score_dec2
	LCD_LINE1+9:	LUT_DATA	<=	9'b100110000 + score_dec1;//score_dec1
	LCD_LINE1+10:	LUT_DATA	<=	9'b100110000 + score_dec0;//score_dec0
	LCD_LINE1+11:	LUT_DATA	<=	9'h120;
	LCD_LINE1+12:	LUT_DATA	<=	9'h120;
	LCD_LINE1+13:	LUT_DATA	<=	9'h120;
	LCD_LINE1+14:	LUT_DATA	<=	9'h120;
	LCD_LINE1+15:	LUT_DATA	<=	9'h120;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	//	Line 2
	LCD_LINE2+0:	LUT_DATA	<=	9'h120;
	LCD_LINE2+1:	LUT_DATA	<=	9'b101010000;//P
	LCD_LINE2+2:	LUT_DATA	<=	9'b101100101;//e
	LCD_LINE2+3:	LUT_DATA	<=	9'b101110010;//r
	LCD_LINE2+4:	LUT_DATA	<=	9'b101100011;//c
	LCD_LINE2+5:	LUT_DATA	<=	9'b101100101;//e
	LCD_LINE2+6:	LUT_DATA	<=	9'b101101110;//n
	LCD_LINE2+7:	LUT_DATA	<=	9'b101110100;//t
	LCD_LINE2+8:	LUT_DATA	<=	9'b100111010;//:
	LCD_LINE2+9:	LUT_DATA	<=	9'b100110000 + percent_dec3;//percent_dec3
	LCD_LINE2+10:	LUT_DATA	<=	9'b100110000 + percent_dec2;//percent_dec2
	LCD_LINE2+11:	LUT_DATA	<=	9'b100110000 + percent_dec1;//percent_dec1
	LCD_LINE2+12:	LUT_DATA	<=	9'b100101110;//.
	LCD_LINE2+13:	LUT_DATA	<=	9'b100110000 + percent_dec0;//percent_dec0
	LCD_LINE2+14:	LUT_DATA	<=	9'b100100101;//%
	LCD_LINE2+15:	LUT_DATA	<=	9'h120;
	default:		LUT_DATA	<=	9'h120;
	endcase
end

LCD_Controller 	u0	(
	//	Host Side
	.iDATA(mLCD_DATA),
	.iRS(mLCD_RS),
	.iStart(mLCD_Start),
	.oDone(mLCD_Done),
	.iCLK(iCLK),
	.iRST_N(iRST_N),
	//	LCD Interface
	.LCD_DATA(LCD_DATA),
	.LCD_RW(LCD_RW),
	.LCD_EN(LCD_EN),
	.LCD_RS(LCD_RS)	
);

endmodule