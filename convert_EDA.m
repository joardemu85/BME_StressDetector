function [ EDA_uS ] = convert_EDA(ADC,nbits)
%convertEDA Converts ADC value delivered by biosignalsplux into
%microsiemens
%   Requires decimal value of the sample and resolution of the converter

%Constants
Vcc=3;
% n=16;
a=0.12;

EDA_uS=((ADC/2^nbits)*Vcc)/a;

end

