function [ startAcq_bin, stopAcq_bin ] = generate_messages(nPorts)
%generate_messages Generates the messages to send to biosignalsplux and
%start and stop acquisition. 
%   Requires number of ports to acquire (1-4) and CR8_gen.m
%   format of message: [header][len][payload][CRC8]

%% Generate Start acquisition message 

%Constant fields

%Header
header='AA';

%constant fields for payload
payloadHeader = {'07' '01'};
startTime={'00' '00' '00' '00'}; %start acquisition now
duration={'FF' 'FF' 'FF' 'FF'}; %infinite duration
nRepeats={'00' '00'}; %no repetition
repearPeriod={'00' '00' '00' '00'}; %no repetition period
baseFrequency={'00' '00' '96' '43'}; %Sampling frequency = 300Hz
% Other possible values
% baseFrequency={'00' '00' 'C8' '42'}; 100 Hz
% baseFrequency={'00' '00' '48' '43'}; 200 Hz
% baseFrequency={'00' '00' '96' '43'}; 300 Hz
% baseFrequency={'00' '00' '68' '43'}; 400 Hz
% baseFrequency={'00' '00' 'FA' '43'}; 500 Hz
% baseFrequency={'00' '00' '16' '44'}; 600 Hz
% baseFrequency={'00' '00' '2F' '44'}; 700 Hz
% baseFrequency={'00' '00' '48' '44'}; 800 Hz
% baseFrequency={'00' '00' '61' '44'}; 900 Hz
% baseFrequency={'00' '00' '7A' '44'}; 1000Hz

%byte at the end of the message
lenText={'00'};

%% Assemble payload according desired number of sensors

switch nPorts
% Message for 1 sensor    
    case 1
        nSensors={'01'};
        len={'1E'};
        
        %data for Port 1.
        port_res={'81'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor={'01' '00'};
        chMask={'01'};
        class={'00'};
        serialNumber={'00' '00' '00'};
        
        payload=[payloadHeader startTime, duration, nRepeats, repearPeriod, ... 
                 baseFrequency, nSensors, port_res, freq_divisor, chMask,...
                 class, serialNumber,lenText]; 
             
        %Generate payload CRC     
        CRC8=CRC8_gen(payload);     
        
        %Asseble whole message converted to binary data (uint8)
        startAcq_hex=[header len payload CRC8];
        startAcq_bin=uint8(hex2dec(startAcq_hex))';
      
        
        
% Message for 2 sensors        
    case 2
        len={'26'};
        nSensors={'02'};
        
        %data for Port 1. (ECG)
        port_res1={'81'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor1={'01' '00'};
        chMask1={'01'};
        class1={'00'};
        serialNumber1={'00' '00' '00'};
        
        %data for Port 2. (EDA)
        port_res2={'82'}; %Acquire from analog port 2 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor2={'01' '00'};
        chMask2={'01'};
        class2={'00'};
        serialNumber2={'00' '00' '00'};
        
        payload2=[payloadHeader startTime, duration, nRepeats, repearPeriod, ... 
                 baseFrequency, nSensors, port_res1, freq_divisor1, chMask1,...
                 class1, serialNumber1, port_res2, freq_divisor2, chMask2,...
                 class2, serialNumber2, lenText];
       
        %Generate payload CRC     
        CRC8=CRC8_gen(payload2);     
        
        %Asseble whole message converted to binary data (uint8)
        startAcq_hex=[header len payload2 CRC8];
        startAcq_bin=uint8(hex2dec(startAcq_hex))';  
                 
        
        
% Message for 3 sensors        
    case 3
        len='2E';
        nSensors={'03'};
        
        %data for Port 1. (ECG)
        port_res1={'81'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor1={'01' '00'};
        chMask1={'01'};
        class1={'00'};
        serialNumber1={'00' '00' '00'};
        
        %data for Port 2. (EDA)
        port_res2={'82'}; %Acquire from analog port 2 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor2={'01' '00'};
        chMask2={'01'};
        class2={'00'};
        serialNumber2={'00' '00' '00'};
        
        %data for Port 3. (Temp)
        port_res3={'83'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor3={'01' '00'}; %don't forget this
        chMask3={'01'};
        class3={'00'};
        serialNumber3={'00' '00' '00'};
        
        payload3=[payloadHeader startTime, duration, nRepeats, repearPeriod, ... 
                 baseFrequency, nSensors, port_res1, freq_divisor1, chMask1,...
                 class1, serialNumber1, port_res2, freq_divisor2, chMask2,...
                 class2, serialNumber2, port_res3, freq_divisor3, chMask3,...
                 class3, serialNumber3, lenText];    
             
        %Generate payload CRC     
        CRC8=CRC8_gen(payload3);     
        
        %Asseble whole message converted to binary data (uint8)
        startAcq_hex=[header len payload3 CRC8];
        startAcq_bin=uint8(hex2dec(startAcq_hex))';   
             
             
        
    case 4
        len={'36'};
        nSensors={'04'};
        
        %data for Port 1. (ECG)
        port_res1={'81'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor1={'01' '00'};
        chMask1={'01'};
        class1={'00'};
        serialNumber1={'00' '00' '00'};
        
        %data for Port 2. (EDA)
        port_res2={'82'}; %Acquire from analog port 2 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor2={'01' '00'};
        chMask2={'01'};
        class2={'00'};
        serialNumber2={'00' '00' '00'};
        
        %data for Port 3. (Temp)
        port_res3={'83'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor3={'01' '00'}; %don't forget this
        chMask3={'01'};
        class3={'00'};
        serialNumber3={'00' '00' '00'};
        
        %data for Port 4. (BVP)
        port_res4={'84'}; %Acquire from analog port 1 at 16 bits
        % Other possible values
        % port_res={'01'}; analog port 1 at 8 bits
        % port_res={'02'}; analog port 2 at 8 bits
        % port_res={'03'}; analog port 3 at 8 bits
        % port_res={'04'}; analog port 4 at 8 bits
        % port_res={'82'}; analog port 2 at 16 bits
        % port_res={'83'}; analog port 3 at 16 bits
        % port_res={'84'}; analog port 4 at 16 bits
        freq_divisor4={'01' '00'};
        chMask4={'01'};
        class4={'00'};
        serialNumber4={'00' '00' '00'};       
        
        
        payload4=[payloadHeader startTime, duration, nRepeats, repearPeriod, ... 
                 baseFrequency, nSensors, port_res1, freq_divisor1, chMask1,...
                 class1, serialNumber1, port_res2, freq_divisor2, chMask2,...
                 class2, serialNumber2, port_res3, freq_divisor3, chMask3,...
                 class3, serialNumber3, port_res4, freq_divisor4, chMask4,...
                 class4, serialNumber4, lenText];    
             
        %Generate payload CRC     
        CRC8=CRC8_gen(payload4);     
        
        %Asseble whole message converted to binary data (uint8)
        startAcq_hex=[header len payload4 CRC8];
        startAcq_bin=uint8(hex2dec(startAcq_hex))';         
        
        
    otherwise
        disp('Wrong value')
    
    
end


%% Generate Stop acquisition message

%stop sending from BT
stByte1='02'; 
%stop command
stByte2='09';
stByte3='00'; %stop acquisition from BT
stop_payload={stByte2, stByte3};
%CRC for stop Acquisition
CRC8st=CRC8_gen(stop_payload);

stopAcq_hex=[header stByte1 stop_payload CRC8st];
stopAcq_bin=uint8(hex2dec(stopAcq_hex))';

end

