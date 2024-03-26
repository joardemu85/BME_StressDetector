function [ ECG_mv ] = convert_ECG(ADC,nbits)
%convert_ECG Converts ADC value delivered by biosignalsplux into milivolts
%   Requires decimal value of the sample and resolution of the converter

%Constants
Vcc=3;
% n=16;
a=0.5;
%Gain=1000;

ECG_mv=((ADC/2^nbits)-a)*Vcc;

end

