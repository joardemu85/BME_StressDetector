function [ ECG_mv,EDA_us,TEMP_dc ] = btMeasurement( myBT,...
                                            startAcq,...
                                            stopAcq,...
                                            total_samples,...
                                            n_bits,...
                                            window_size,...
                                            signal_width,...
                                            line_ECG,...
                                            line_EDA,...
                                            txt_tempVal,...
                                            txt_scVal)
                                        
% requires 
%convert_ECG.m, 
%convert_EDA.m  
%convert_TEMP.m

%% Local variables
                                        
%data for processing
ECG_mv=zeros(1,total_samples);
EDA_us=zeros(1,total_samples);
TEMP_dc=zeros(1,total_samples);

%data for display
ECG_draw=zeros(1,signal_width);
EDA_draw=zeros(1,signal_width);
time_plot=linspace(0,window_size,signal_width);  
hr_vec=zeros(1,300);

%% Start Acquisition
fopen(myBT);
fwrite(myBT,startAcq);
command=fread(myBT,12)';

disp('Measurement in Progress...')

count=1;

tic;
 while count<=total_samples
                   
        input_data=dec2hex(fread(myBT,10));

        %ECG (Port 1)
        ECG=[input_data(5,:),input_data(4,:)];
        ECG_mv(count)=convert_ECG(hex2dec(ECG),n_bits);

        %EDA (Port 2)
        EDA=[input_data(7,:),input_data(6,:)];
        EDA_us(count)=convert_EDA(hex2dec(EDA),n_bits);
        
        %TEMP (Port 3)
        TEMP=[input_data(9,:),input_data(8,:)];
        TEMP_dc(count)=convert_TEMP(hex2dec(TEMP),n_bits);        
           
         
        %plot lines and display values
        ECG_draw(1:end-1)= ECG_draw(2:end);
        ECG_draw(end)=ECG_mv(count);
        set(line_ECG,'Xdata',time_plot,'Ydata',ECG_draw)
        
     
          
        EDA_draw(1:end-1)= EDA_draw(2:end);
        EDA_draw(end)=EDA_us(count);
        set(line_EDA,'Xdata',time_plot,'Ydata',EDA_draw)
        sc=floor(EDA_us(count));
        txt_scVal.String=num2str(sc);
        
        t=floor(TEMP_dc(count));
        txt_tempVal.String=num2str(t);
                  
       % drawnow update; % THIS update WAS ALL THE PROBLEM!!!!
        drawnow limitrate; 

       count=count+1;

           
end

%% Stop Acquisition
end_time=toc;

disp('End of measurement')
fwrite(myBT,stopAcq);
fclose(myBT);
flushinput(myBT);
% get(myBT);


end

