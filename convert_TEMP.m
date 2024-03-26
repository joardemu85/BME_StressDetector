function [ temp ] = convert_TEMP( ADC,nbits )
%Convertion from ADC value from biosignals to temperature in degree celsius
%   Detailed explanation goes here

%% Constants
VCC=3;
% nbits=16;
C1=1.12764514e-3;
C2=2.34282709e-4;
C3=8.77303013e-8;

%% Conversion to voltage (Volts)
Vout=(ADC*VCC)/(2^nbits - 1);

%% Conversion to Resistance of NTC (Ohmns)
Rntc=(10000*Vout)/(VCC-Vout);

%% Conversion to Temperature in Celsius
kelv = 1/(C1+C2*log(Rntc)+C3*log(Rntc)^3);
temp=kelv-273.5;



end

