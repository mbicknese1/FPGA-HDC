module main ();
    reg [7:0] HV [127:0];
    reg [7:0] dictMem[36:0][127:0]; // change to [10000:0] later
    reg [159:0] msg [32:0];
    integer Max_lenght = 160;
    integer sum = 0;
    integer l,j,k;
    real avg;
    integer seed = 11;
  
    integer i = 0;
    reg[14*7:0] char;
    reg[7:0] letter;
    reg[7:0] lower_letter;
    reg[7:0] num_msg[11:0];

    initial begin
        char = "Shenda Huang";
        for (i = 0; i < 95 ; i = i + 8) begin 
            letter = {char[i+7],char[i+6],char[i+5],char[i+4],char[i+3],char[i+2],char[i+1],char[i]};
            //$display("%d, %c", letter, letter);
            lower_letter = to_lower(letter);
            //$display("%d, %c", lower_letter, lower_letter);
            if (lower_letter>="a" && lower_letter<="z") begin
                num_msg[i/8] = lower_letter-"a"+11;
            end else begin
                if (lower_letter>="0" && lower_letter<="9")
                    num_msg[i/8] = lower_letter-"0"+1;
                else
                    num_msg[i/8] = 0;
            end
        end
        
        for(i = 0; i < 12; i = i+1) begin
            //$display (num_msg[i]);
        end

        memGen(37,128);

        encoding(128);

    end

    //Make all characters lower case
    function [7:0] to_lower (input [7:0] in_char);
    begin
        to_lower = in_char;
        if (in_char > 64 && in_char < 91)
            to_lower = in_char + 32;
        end
    endfunction // to_lower

    //Generate item memories
    task memGen;
        input [7:0] num_char, dim;
        integer i,j;
        begin
            for (i = 0; i < num_char ; i = i + 1 ) begin
                for (j = 0; j < dim; j = j + 1 ) begin
                    dictMem[i][j] = $urandom(seed)%2; //generate dictMem
                    //$display("%b", dictMem[i][j]);
                end
            end
        end
    endtask

    task encoding;
        input [7:0] dim;
        integer i, l, avg;
        begin

            for (i = 0; i < 128; i = i + 1) begin // make HV all zeros
                HV[i] = 0;
            end

            for (l = 0; l < 12; l = l + 1 ) begin // sum each unit together
                for (k = 0; k < 128 ; k = k + 1 ) begin
                    HV[k] = HV[k] + dictMem[num_msg[l]][k];
                    if (l==11) begin
                        sum = sum + HV[k];
                    end
                end 
            end

            avg = sum / 128.0; // Calculate average 

            for (i = 0; i < 128; i = i + 1) begin // Do comparison
                if ( HV[i] > avg) begin
                    HV[i] = 1;
                end else begin
                    if ( HV[i] < avg)
                        HV[i] = -1;
                    else
                        HV[i] = 0;
                end
            end
        end
    endtask

endmodule