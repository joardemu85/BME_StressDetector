function [ s_mag,s_dur,s_freq ] = sdetect(orig_eda,orig_fs,g)
%Original Programmer: Jennifer Healey, Dec 13, 1999

% Usage: this is a script so you dont' have to pass a vector.
% You can easily make it into a function if you prefer.
% The signals is "s" the 
% sampling frequency is "Fs"
% g is an additional variable to show plot
% 
% the results are: 
% s_freq (startle frequency) 
% s_mags (startle magnitude) 
% s_dur (startle durations)
% Edit all here or comment out for use in a giant script

%Modified by: Jorge Delgado
%Date: 25.06.2016

% Detailed explanation goes here


%% Downsample the signal (from 300 Hz to 30 Hz)

downsample_factor=floor(orig_fs/30);
Fs=round(orig_fs/downsample_factor);
s=downsample(orig_eda,downsample_factor);

%% Smoothing with Median filter
s=medfilt1(s,15); %increase order for too noisy EDA 05/07/2016


%% Filter out the high frequency noise (checked)

lgsr=length(s);
% lgsr2=lgsr/2;
time=linspace(0,(lgsr-1)/Fs,lgsr);
[b,a]=ellip(4,0.1,40,3*2/Fs);
% [H,w]=freqz(b,a,lgsr);
sf=filter(b,a,s);

% first derivative
sf_prime=diff(sf);


%% Find Significant Startles

%There is ringing in the signal so the first 35 points are excluded
p135=length(sf_prime);
sf_prime35=sf_prime(35:p135);

%Set a threshhold to define significant startle
%thresh=0.005;
thresh=0.003; % slop of the startle 0.003 µs/sample or 0.090 µS/sec 

vector=sf_prime35;
overthresh=find(vector>thresh);

%overthresh is the values at which the segment is over the threshold
overthresh35=overthresh+35;

%the true values of the segment (segments that are at least 1 sec away)
gaps=diff(overthresh35);
big_gaps=find(gaps>30);

%big_gaps returns the indices of gaps that exceed 31
% eg - big_gaps=[60 92 132 168....]
% gaps(60)=245; gaps(92)=205 ...
% overthresh35(58:62)= [346 347 348 593 594]
% so overthresh(61) is where the startle starts (ish)
% is overthresh (60) where the startle ends?

% check the results
iend=[];
ibegin=[];

for i=1:length(big_gaps)
 iend=[iend overthresh35(big_gaps(i))];
 ibegin=[ibegin overthresh35(big_gaps(i)+1)];
end;

%% Fine Tuning

% The idea being this is to find the zero crossing closet to where it goes
% over threshold


% find all zero crossings
overzero=find(sf_prime>0);
zerogaps=diff(overzero);
z_gaps=find(zerogaps>1);

iup=[];
idown=[];

for i=1:length(z_gaps)
 idown=[idown overzero(z_gaps(i))];
 iup=[iup overzero(z_gaps(i)+1)];
end;

% find up crossing closest to ibegin
new_begin=[];
for i=1:length(ibegin)
  temp=find(iup<ibegin(i));
  choice=temp(length(temp));
  new_begin(i)=iup(choice);
end;


% to find the end of the startle, find the maximum between startle
% beginnings

new_end=[];

for i=1:(length(new_begin)-1)
  startit=new_begin(i);
  endit=new_begin(i+1);
  [val, loc]=max(s(startit:endit));
  new_end(i)=startit+loc;
end;

if (length(new_begin)>0)
  last_begin=new_begin(length(new_begin));
  [lastval,lastloc]=max(s(last_begin:length(s)-1));
  new_end(length(new_begin))=new_begin(length(new_begin))+lastloc;
end;

%new_end and new_begin are the indexes where the startles are located

s_mag=[]; %initialize a vector of startle magnitudes
s_dur=[]; %initialize a vector of startle durations (in samples)

for i=1:length(new_end)
 s_dur(i)=time(new_end(i))-time(new_begin(i));
 s_mag(i)=s(new_end(i))-s(new_begin(i));
end

% s_dur;
% s_mag;
s_freq=length(ibegin);

no_response=find(s_mag<=0.03);
s_dur(no_response)=[];
s_mag(no_response)=[];
s_freq=length(s_mag);



%% Plot the locations

if g
 figure;
 plot(time,s,'Color','blue');
 hold on;
 %locate beginings
 a=plot(time(new_begin),s(new_begin),'k^','markerfacecolor',[1 0 0]);
 hold on;
 b=plot(time(new_end),s(new_end),'k^','markerfacecolor',[0 1 0]);
 legend([a,b],'Onsets','Peaks')
 title('SCR Orienting Responses Detection');
 xlabel('Time (seconds)');
 ylabel('Skin Conductance (microSiemens)');
 grid on;
end






end

