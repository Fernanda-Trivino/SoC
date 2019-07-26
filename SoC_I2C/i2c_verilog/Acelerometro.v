`timescale 1ns / 1ps


module Acelerometro(I2C_clk,led,scl,sda );
    
    input I2C_clk;
    output wire [7:0]led;
    inout scl;
    inout sda;
        
    reg I2C_rst = 0;
    reg arst_i= 1;
    
    reg [15:0]prescale;
    reg [7:0]control;
    reg [7:0]transmit;
    wire [7:0]receive;
    reg [7:0]command;
    wire [7:0]status;
    
    i2c acelerometro (
	I2C_clk, I2C_rst, arst_i,
    prescale,control,transmit,receive,command,status,
    scl,sda );
    
    reg [3:0]step;
    
    parameter add_w      = 8'b00111010; // MMA7455 Addrers for writting 
    parameter add_r      = 8'b00111011; // MMA7455 Addres for reading
    parameter add_ctrl   = 8'h16;
    parameter ctrl       = 8'b00000101; // measure 8g
    parameter add_x       =8'h06;
    //Commands
    parameter start_w    = 8'b10010000;
    parameter start_r    = 8'b10100000;  
    parameter stop_w     = 8'b01010000; 
    parameter read       = 8'b00100000; 
    parameter write      = 8'b00010000; 
    
    initial
    begin
        step = 4'h0;
        prescale = 16'd999; // Ver documentación pg3
        control = 8'b10000000; 
        transmit = 8'h0;
        command = 8'h0;
    end
    

    assign led[7:0] = receive ;

        
    always @(posedge I2C_clk)
        case(step)
            4'd0:
            begin
                command<=start_w;
                transmit<=add_w;
                step<= step + 1;
            end 
            4'd1:
            begin
                if(status[7])
                    begin
                        step<=step;
                    end
                else
                    step<=step+1;
            end 
            4'd2:
            begin
                command<=write;
                transmit<=add_ctrl;
                step<= step + 1;
            end 
            4'd3:
            begin
                if(status[7])
                    step<=step;
                else
                    step<=step+1;
            end
            4'd4:
            begin
                command<=stop_w;
                transmit<=ctrl;
                step<= step + 1;
            end 
            4'd5:
            begin
                if(status[7])
                    step<=step;
                else
                    step<=0;
            end
//            4'd6:
//            begin
//                command<=start_w;
//                transmit<=add_w;
//                step<= step + 1;
//            end 
//            4'd7:
//            begin
//                if(status[7])
//                    step<=step;
//                else
//                    step<=step+1;
//            end 
//            4'd8:
//            begin
//                command<=write;
//                transmit<=add_x;
//                step<= step + 1;
//            end 
//            4'd9:
//            begin
//                if(status[7])
//                    step<=step;
//                else
//                    step<=step+1;
//            end
//            4'd10:
//            begin
//                command<=start_r;
//                transmit<=add_r;
//                step<= step + 1;
//            end
//            4'd11:
//            begin
//                if(status[7])
//                    step<=step;
//                else
//                    step<=step+1;
//            end
//            4'd12:
//            begin
//                command<=read;
//                step<= step + 1;
//            end
//            4'd13:
//            begin
//                if(status[7])
//                    step<=step;
//                else
//                    step<=4'd12;
//            end
            
            
        endcase    
   
endmodule

