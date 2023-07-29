module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;

reg [3:0] p1_x, p1_y, p2_x, p2_y, p3_x, p3_y;
reg [3:0] r1, r2, r3;
reg [3:0] x,y;
integer i;
reg [6:0] square [0:9];
always @(posedge clk,posedge rst) begin
	if(rst)begin
		busy <= 1'd0;
		valid <= 1'd0;
		candidate <= 8'd0;
		{p1_x, p1_y, p2_x, p2_y, p3_x, p3_y} <= 24'd0;
		{r1,r2,r3} <= 12'd0;
		x <= 4'd1;
		y <= 4'd1;
		for(i=0;i<=9;i=i+1)begin
			square[i] <= i*i;
		end
	end
	else begin
		if(en) begin
			{p1_x, p1_y, p2_x, p2_y, p3_x, p3_y} <= central[23:0];
			{r1,r2,r3} <= radius[11:0];
			candidate <= 8'd0;
			x <= 4'd1;
			y <= 4'd1;
			busy <= 1;
			valid <= 0;
		end
		if(busy) begin
			valid <= 0;
			case (mode)
				2'b00:begin
					if(in_circle(x,y,p1_x,p1_y,r1))	candidate <= candidate + 8'd1;
				end
				2'b01:begin
					if(in_circle(x,y,p1_x,p1_y,r1) && in_circle(x,y,p2_x,p2_y,r2))	candidate <= candidate + 8'd1;
				end
				2'b10:begin
					// if((in_circle(x,y,p1_x,p1_y,r1) && (~in_circle(x,y,p2_x,p2_y,r2))) && ((~in_circle(x,y,p1_x,p1_y,r1)) && in_circle(x,y,p2_x,p2_y,r2)))	candidate <= candidate + 8'd1;
					if((in_circle(x,y,p1_x,p1_y,r1) ^ in_circle(x,y,p2_x,p2_y,r2)))	candidate <= candidate + 8'd1;
				end
				2'b11:begin
					if(in_circle(x,y,p1_x,p1_y,r1) && in_circle(x,y,p2_x,p2_y,r2) && in_circle(x,y,p3_x,p3_y,r3))	candidate <= candidate + 8'd1;
				end 
			endcase

			if(x == 4'd8)begin
				if(y == 4'd8)begin
					x <= 4'd1;
					y <= 4'd1;
					busy <= 0;
					valid <= 1;
				end
				else begin
					y <= y + 1;
					x <= 4'd1;
				end
			end
			else	x <= x + 1;

		end
		
	end
end
function integer abs_minus;
	input [3:0] a;
	input [3:0] b;
	begin
		abs_minus = (a>b) ? a-b:b-a;
	end
endfunction
function integer in_circle;
	input [3:0] xx;
	input [3:0] yy;
	input [3:0] c_x;
	input [3:0] c_y;
	input [3:0] rr;
	begin
		// in_circle = {1'b0,abs_minus(xx,c_x)}*{1'b0,abs_minus(xx,c_x)} + {1'b0,abs_minus(yy,c_y)}*{1'b0,abs_minus(yy,c_y)} <= rr*rr;
		in_circle = ({1'b0,square[abs_minus(xx,c_x)]} + {1'b0,square[abs_minus(yy,c_y)]} <= square[rr]);
	end
endfunction
endmodule

