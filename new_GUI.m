%% Full application for stress estimation using KNN algorithm

   %Acquisition of 3 sensors with fs=300, resolution=16bit, real time
   %Acqusition and display using GUI template. 
   %Control start and stop Acquisition with Toggle Button. 
   %Extraction of features from the different signals
   %Display of numeric values.
   %Prediction of stress levels using KNN algorithm
   %Date: 21.08.2016
   %Author: Jorge Delgado
   
function new_GUI

%Requires:
%btMeasurement.m 
%generate_messages.m
%pan_tompkin.m
%RR_tacho.m
%sdetect.m

clc; 
clear all; 
close all;

% %% Find any old active Bluetooth object and delete it
% 
% oldBluetooth = instrfind('Name','biosignalsplux');
% if(~isempty(oldBluetooth))
%     disp('Closing old Bluetooth object')
%     fclose(oldBluetooth);
%     delete(oldBluetooth);
% end


%% Space for global variables and parameters 

%Acquisition parameters

%Sampling Frequency (Hz)
fs=300;
%ADC Resolution
n_bits=16;
%Measurement time (Seconds)
measurement_time=60;
%Number of samples to read from device
total_samples=fs*measurement_time;

%Communication Messages

%generate_messages already presets n_bits=16 and fs=300
[startAcq,stopAcq]=generate_messages(3);

   
%% Add GUI Elements

figure('Visible','on',...
       'Position',[258 132 790 450],...
       'Resize','off');

txt_tempText = uicontrol('Style','text',...
                    'Position',[590 410 140 30],...
                    'FontSize',12,...
                    'FontWeight','bold',...
                    'HorizontalAlignment','left',...
                    'String','Temperature (°C)');           
txt_tempVal = uicontrol('Style','text',...
                    'Position',[590 380 50 30],...
                    'FontSize',12,...
                    'BackgroundColor',[1 1 1],...
                    'String','0'); 
                
txt_hrText = uicontrol('Style','text',...
                    'Position',[590 340 140 30],...
                    'FontSize',12,...
                    'FontWeight','bold',...
                    'HorizontalAlignment','left',...
                    'String','Heart Rate (BPM)');           
txt_hrVal = uicontrol('Style','text',...
                    'Position',[590 310 50 30],...
                    'FontSize',12,...
                    'BackgroundColor',[1 1 1],...
                    'String','-');   
                
txt_scText = uicontrol('Style','text',...
                    'Position',[590 270 180 30],...
                    'FontSize',12,...
                    'FontWeight','bold',...
                    'HorizontalAlignment','left',...
                    'String','Skin Conductance (µS)');           
txt_scVal = uicontrol('Style','text',...
                    'Position',[590 240 50 30],...
                    'FontSize',12,...
                    'BackgroundColor',[1 1 1],...
                    'String','0');   
                
txt_stressText = uicontrol('Style','text',...
                    'Position',[590 150 180 30],...
                    'FontSize',14,...
                    'FontWeight','bold',...
                    'HorizontalAlignment','center',...
                    'String','STRESS LEVEL');           
txt_stressLevel = uicontrol('Style','text',...
                    'Position',[590 120 180 30],...
                    'FontSize',14,...
                    'BackgroundColor',[1 1 1],...
                    'HorizontalAlignment','center',...
                    'String','---');  
                
btn = uicontrol('Style','togglebutton',...
                'String','RUN', ...
                'Position',[640 30 80 40],...
                'ForegroundColor','k',...
                'BackgroundColor',[0 0.5 0],...
                'FontWeight','bold',...
                'FontSize',12,...
                'Callback',@my_program);                
            
            
                
%these two variables define the size of display window and waveforms (leave
%this part always to the end)
window_size=4;  %In seconds
signal_width=window_size*fs;       

ax_ECG = axes('Units','pixels',...
              'Position',[50,298,500,120]); 
line_ECG = line(nan,nan,...
                'Color',[0.1 0.4 0.8],...
                'LineWidth',1,...
                'Parent',ax_ECG);  
                title('ECG')
                ylim([-1.2 1.8]) 
                ylabel('(mVolts)');
                xlim([0 window_size])
                grid on;
           
ax_EDA = axes('Units','pixels',...
              'Position',[50,80,500,120]);          
line_EDA = line(nan,nan,...
                'Color',[0 0.5 0],...
                'LineWidth',1,...
                'Parent',ax_EDA);
                title('EDA')
                ylim([0 25]) 
                ylabel('(µSiemens)');
                xlim([0 window_size])
                grid on; 
          
%% Call of Bluetooth and Classification objects
tic;
%Bluetooth Object and properties
disp('Creating Bluetooth Object')
myBT=Bluetooth('biosignalsplux',1);
set(myBT,'InputBufferSize',1024); 
set(myBT,'Timeout',20); 
set(myBT,'Terminator','');
get(myBT);
disp('Bluetooth Ready. Push RUN to begin.')
BT_creation_time=toc;

%Machine Learning implementation


%load data
load ('training_data.mat',...
      'predictors_matrix',...
      'labels_2level',...
      'labels_3level',...
      'labels_4level');
  
% X=predictors_matrix;
% Y=stress_levels_5; %change name of var for different classification scale
tic
%train classifier for 2-level estimation
myKNN_2l = fitcknn(predictors_matrix, ...
                labels_2level, ...
                'Distance', 'cityblock', ...
                'Exponent', [], ...
                'NumNeighbors', 3, ...
                'DistanceWeight', 'squaredinverse', ...
                'Standardize', true, ...
                'ClassNames', {'No Stress', 'Stress'});   

%train classifier for 3-level estimation
myKNN_3l = fitcknn(predictors_matrix, ...
                labels_3level, ...
                'Distance', 'cityblock', ...
                'Exponent', [], ...
                'NumNeighbors', 10, ...
                'DistanceWeight', 'squaredinverse', ...
                'Standardize', true, ...
                'ClassNames', {'High','Low','Normal'}); 
            
%train classifier for 4-level estimation
myKNN_4l = fitcknn(predictors_matrix, ...
                labels_4level, ...
                'Distance', 'cityblock', ...
                'Exponent', [], ...
                'NumNeighbors', 1, ...
                'DistanceWeight', 'equal', ...
                'Standardize', true, ...
                'ClassNames', {'Attentive','High','Low','Normal'});             
                 
training_time=toc;               

%startup evaluation
fileID_1 = fopen('performance_1.txt','a');
fprintf(fileID_1,'%6s %12s\r\n','Bluetooth','Training');     
fprintf(fileID_1,'%6.2f %12.2f\r\n',BT_creation_time,training_time);

fileID_2=fopen('performance_2.txt','a');
fprintf(fileID_2,'%6s %12s %18s\r\n' ,'Acquisition','Extraction','Prediction');
                
fileID_3=fopen('measurements.txt','a');
fprintf(fileID_3,'%6s %12s %18s %20s %24s %28s\r\n','Heart Rate','NS_SCR','Temperature','2-level','3-level','4-level');


%% Main Callback Function                       
                            

  function my_program(source,eventdata) %Here I will write the main program
       
        if get(btn,'Value') == get(btn,'Max')
            btn.String = 'STOP';
            btn.BackgroundColor = [1 0 0];
        else
            btn.String = 'RUN';
            btn.BackgroundColor = [0 0.5 0];
        end  
        
      
        while get(btn,'Value') == get(btn,'Max') 
          
            %Start Communication with the device
            %Inputs: Bluetooth object, Acq parameters, Line objects, value texts. 
            %Outputs: Vectors of signals
            tic
            [ ECG,EDA,TEMP ] = btMeasurement( myBT,startAcq,stopAcq,total_samples,n_bits,...
                                         window_size,signal_width,line_ECG,line_EDA,txt_tempVal,...
                                         txt_scVal);
            Acquisition_time=toc;
 %Here I will preform the feature obtention and stress prediction using the trained 
 %classifier and display the result in the window
        tic
        %time vectors for feature extraction
        time_ms=linspace(0,(total_samples-1)*1000/fs,total_samples); %miliseconds
        time_s=linspace(0,(total_samples-1)/fs,total_samples);       %seconds
 
        
        %% ECG time domain HRV analysis.
        QRS_time=zeros(total_samples,1);
        
        % Find QRS amplitudes and their indexes using Pan-Tomkins Algorithm 
        [~,indexes,~]=pan_tompkin(ECG,fs,0);
        
        %generate beat time series
        indexes=indexes';
        QRS_time(indexes)=time_ms(indexes);
        
        %Generate RR Interval Tachogram
        [RR_interv,~] = RR_tacho(indexes,time_ms);

        %time domain features

        %Minimum RR interval lenght
        min_RR=min(RR_interv);

        %Maximum RR interval length
        max_RR=max(RR_interv);

        %RR interval range
        RR_range=max_RR-min_RR;

        %RR average interval
        mean_NN=mean(RR_interv);

        %RR Standard deviation
        SDNN=std(RR_interv);

        %RR Coefficient of variability
        NNCV=SDNN*100/mean_NN;

        %percentage of succesive intervals greater than 50ms
        aux=abs(diff(RR_interv));
        ind=find(aux>=50);
        NN50=aux(ind);
        pNN50=length(NN50)*100/length(RR_interv);

        %square root of the mean squared difference of successive RR intervals
        RMSSD=sqrt(mean(aux.^2));

        %Average heart rate
        HR_avg=floor(60/(mean_NN/1000));
        
        txt_hrVal.String=num2str(HR_avg);
       
       %% EDA PROCESSING
      
       % Phasic SCR Analysis
 
       %obtain features from phasic SCR
       [s_mag,s_dur,s_freq ] = sdetect(EDA,fs,0);
     
       %sum of startle magnitudes
       sum_mag=sum(s_mag);
     
       %sum of startle durations
       sum_dur=sum(s_dur);
     
       %sum of responses' areas
       sum_areas=sum(0.5*s_mag.*s_dur);
     
       %number of skin conductance responses
       NS_SCR=floor(s_freq*60/max(time_s));
      
       %% Temperature Processing (here the temperature is already expressed in °C)

       Temp_Min=min(TEMP);
       Temp_Max=max(TEMP);
       Temp_Avg=mean(TEMP);
     
  %% Feature summary
 
  feats=[min_RR,max_RR,RR_range,mean_NN,SDNN,NNCV,pNN50,RMSSD,HR_avg,sum_mag,...
         sum_dur,sum_areas,NS_SCR,Temp_Min,Temp_Max,Temp_Avg]; 
     
  feature_extraction_time=toc;
  
  
  %% Stress Prediction
 
  %prediction for 2-level
  stress_2l=predict(myKNN_2l,feats);
  stress_2l=strjoin(stress_2l);
  %txt_stressLevel.String=stress;
    
  %prediction for 3-level
  stress_3l=predict(myKNN_3l,feats);
  stress_3l=strjoin(stress_3l);
  %txt_stressLevel.String=stress;
  
  %prediction for 4-level
  tic
  stress_4l=predict(myKNN_4l,feats);
  stress_4l=strjoin(stress_4l);
  txt_stressLevel.String=stress_4l;
  prediction_time=toc;
  
  %% Write performance times in file to evaluate performance
   
  % performance evaluation 

  %write operation times
  fprintf(fileID_2,'%6.2f %12.2f %18.2f\r\n' ,...
          Acquisition_time,feature_extraction_time,prediction_time);
  
  %write basic features and stress levels of the three scales
  fprintf(fileID_3,'%6.2f %14.2f %18.2f %22s %24s %28s\r\n',...
          HR_avg,NS_SCR,Temp_Avg,stress_2l,stress_3l,stress_4l);    
   
          % Plot signals
            time=linspace(0,(total_samples-1)/fs,total_samples);
            figure;

            subplot(2,1,1);
            plot(time,ECG,'blue');
            title('ECG')
            ylabel('(mV)');
            grid on

            subplot(2,1,2);
            plot(time,EDA,'green');
            title('EDA')
            ylabel('(µS)');
            grid on 

          if get(btn,'Value') == get(btn,'Min') 
            break
          end
          
 
          
        end  
        
    end    

 end
