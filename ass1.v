module ass1 (CLOCK_50, KEY[3:0], SW[2:0], HEX0, HEX1, HEX2, HEX3);
    input CLOCK_50;
	input [3:0] KEY;
	input [2:0] SW;
	output reg [6:0] HEX0;
	output reg [6:0] HEX1;
	output reg [6:0] HEX2;
	output reg [6:0] HEX3;
    // minutes
    integer min=0;
    // ten seconds
    integer sec10=0;
    // one seconds
    integer sec1=0;
    // one/ten seconds
    integer sec01=0;
    integer counter_timer=0;
    // carry_out array
    reg [0:4] w;
    // boot switch
    assign mode=SW[0]; 
    // count switch
    assign is_count=SW[1];

    // variables for clock
    integer m10=0;
    integer m01=0;
    integer s10=0;
    integer s01=0;
    reg [0:4] c;
    integer counter_clock=0;

    integer b0;
    integer b1;
    integer b2;
    integer b3;

	reg [1:0] key_status3=2'b11;
	reg [1:0] key_status2=2'b11;
	reg [1:0] key_status1=2'b11;
	reg [1:0] key_status0=2'b11;

    always @(posedge CLOCK_50) begin
        counter_clock = counter_clock + 1;
        counter_timer = counter_timer + 1;
        if (mode==0) begin
            key_status3[1:0]={key_status3[0],KEY[3]};
            set_time(key_status0 [1:0], 5, sec01);
            
            key_status2[1:0]={key_status2[0],KEY[2]};
            set_time(key_status1 [1:0], 9, sec1);
            
            key_status1[1:0]={key_status1[0],KEY[1]};
            set_time(key_status2 [1:0], 5, sec10);
            
            key_status0[1:0]={key_status0[0],KEY[0]};
            set_time(key_status3 [1:0], 9, min);
            b0 = sec01;
            b1 = sec1;
            b2 = sec10;
            b3 = min;
        end else begin
            b0 = s01;
            b1 = s10;
            b2 = m01;
            b3 = m10;
        end
        if (counter_timer>=5000000) begin // 5M
            if(is_count==1) begin
                time_bit(10, w[4], sec01, w[0]);
                time_bit(10, w[0], sec1, w[1]);
                time_bit(6, w[1], sec10, w[2]);
                time_bit(10, w[2], min, w[3]);
                counter_timer = 0;
                w[4] = 1;
            end 
        end
        if(counter_clock>=50000000) begin // 50M
            time_bit(10, c[4], s01, c[0]);
            time_bit(6, c[0], s10, c[1]);
            time_bit(10, c[1], m01, c[2]);
            time_bit(6, c[2], m10, c[3]);
            counter_clock = 0;
            c[4] = 1;
        end 
    end

    always @(*) begin
        HEX0 = num_to_hex(b0);
        HEX1 = num_to_hex(b1);
        HEX2 = num_to_hex(b2);
        HEX3 = num_to_hex(b3);
    end

	task set_time;
		input reg [1:0] key_status;
		input integer up_limit;
		inout integer clk_bit;
		
		if(key_status[1:0]==2'b01)
			begin
				if(clk_bit==up_limit)
					clk_bit=0;
				else
					clk_bit=clk_bit+1;
			end
	endtask
    
    task time_bit;
        input integer up_limit;
        inout carry_in;
        inout integer s;
        output carry_out;

        if (carry_in == 1) 
        begin
            s = s + 1;
            carry_in = 0;
            if (s == up_limit) begin
                carry_out = 1;
                s = 0;
            end
        end
    endtask

    task modify_bit;
        input up_limit;
        input key;
        inout clk_bit;
        begin
            if (key==0) begin
                clk_bit = clk_bit + 1;
                if (clk_bit == up_limit) begin
                    clk_bit = 0;
                end
            end
        end
    endtask

	function [6:0] num_to_hex;
		input integer number;
            case(number)
            0: num_to_hex = 7'b1000000;
            1: num_to_hex = 7'b1111001;
            2: num_to_hex = 7'b0100100;
            3: num_to_hex = 7'b0110000;
            4: num_to_hex = 7'b0011001;
            5: num_to_hex = 7'b0010010;
            6: num_to_hex = 7'b0000010;
            7: num_to_hex = 7'b1111000;
            8: num_to_hex = 7'b0000000;
            9: num_to_hex = 7'b0010000;
            endcase
	endfunction
endmodule
