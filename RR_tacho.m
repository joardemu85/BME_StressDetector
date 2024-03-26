function [ RR_interv,time_stamps ] = RR_tacho(indexes,time)
%Generates RR Interval tachogram as a Discrete Event Series 
%
%   Input Arguments:
%      indexes: Sample indexes that belong to each QRS Fiducial Point
%      time: Complete time vector for the ECG recording (in miliseconds)
%
%   Output Arguments:
%      RR_interv: Intervals between heart pulses (in miliseconds)
%      time_stamps: Time belonging to each RR Interval (in seconds)


% generate beat time series
QRS_time(indexes)=time(indexes);

%generate interval vector
time_intervals=QRS_time;
time_intervals(time_intervals==0)=[];

%calculates interbeat time between elements (RR intervals)
RR_interv=diff(time_intervals);

%calculate time stamps
time_stamps=time_intervals;
% time_stamps(time_stamps==0)=[];

%remove first element from time axis (time corresponding to first beat)
% to make it equal to RR interval vector in length and express it seconds
time_stamps=time_stamps(2:length(time_stamps))./1000;

%this does not remove the first element, but the last, just to see how
%everything changes
% num=length(time_stamps);
% time_stamps=time_stamps(1:num-1)./1000; 


 end

