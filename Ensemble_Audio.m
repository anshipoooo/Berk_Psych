clear all;
close all;
clc;



%% Load Screen
Screen('Preference', 'SkipSyncTests', 1);

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

[window, rect] = Screen('OpenWindow', 0); 
HideCursor();

window_w = rect(3); 
window_h = rect(4);


%% X and Y dimensions
x = window_w/2;
y = window_h/2;



%% Loading excel of frequencies
data = xlsread('Frequency_List');
data_Poss=data(:,2);


%% Defining Results
results=zeros(200,11);

%% Welcome
Screen('DrawText',window,'Welcome to the Ensemble Audio Experiment',x-200,y);
Screen('Flip',window);
WaitSecs(1);


%% Instructions
Screen('DrawText',window,'You will be presented with 6 auditory stimuli and one test stimuli',x-300,y);
Screen('Flip',window);
WaitSecs(2);
Screen('DrawText',window,'Press "h" if the test sound is higher than the average of the 6 sounds',x-300,y);
Screen('Flip',window);
WaitSecs(2);
Screen('DrawText',window,'Press "l" if the test sound is lower than the average of the 6 sounds',x-300,y);
Screen('Flip',window);
WaitSecs(2);
Screen('DrawText',window,'Press any key to begin the experiment',x-200,y);
Screen('Flip',window);
pause;


%% Master for loop
for totalTrials = 1:10
    
    
%% Matrix of values around mean
randMean=randi([6 47],1);
poss1P=data_Poss(randMean+1);
poss1N=data_Poss(randMean-1);
poss5P=data_Poss(randMean+5);
poss5N=data_Poss(randMean-5);
poss3P=data_Poss(randMean+3);
poss3N=data_Poss(randMean-3);
poss2P=data_Poss(randMean+2);
poss2N=data_Poss(randMean-2);


valuesAroundMean=[poss1P;poss1N;poss5P;poss5N;poss3P;poss3N;poss2P;poss2N];
positionAroundMean=[1;-1;5;-5;3;-3;2;-2];


%% Creating the tone
toneDuration= [0:1/44100:0.300];
numTones=6;



for values135=1:6
    globalTone135{values135}=sin(2*pi * valuesAroundMean(values135,1) * toneDuration);
end

for values1235=1:8
    globalTone1235{values1235}=sin(2*pi*valuesAroundMean(values1235,1)*toneDuration);
end



i=0;
Shuffle(globalTone135);


%% Cosine Ramp
Freq_ramp=50; %cosine ramp duration
rampvector=[1:441]; %vector of cosine ramp
fs=44100; %sampling rate
offset=(1+sin(2*pi*Freq_ramp*rampvector./fs+(pi/2)))/2;
onset=(1+sin(2*pi*Freq_ramp*rampvector./fs+(-pi/2)))/2;


%% Playing the Sound
shuffleTones=Shuffle(1:6);
Screen('DrawText',window, 'Here are the 6 stimuli',x-200,y);
Screen('Flip',window);
for i=shuffleTones    
    globalTone135{i}(1,1:441)=onset.*globalTone135{i}(1,1:441);
    globalTone135{i}(1,12791:13231)=offset.*globalTone135{i}(1,12791:13231);
    handle = PsychPortAudio('Open', [], [], 0,44100,1);
    PsychPortAudio('FillBuffer',handle,globalTone135{i});
    PsychPortAudio('Start',handle,1,0,1);
    WaitSecs(0.3);
    PsychPortAudio('Stop',handle);
    PsychPortAudio('Close',handle); 
    WaitSecs(0.1);
end




%% Play Testing Sound
Screen('DrawText',window,'Here is the test sound', x-200,y);
Screen('Flip',window);
 WaitSecs(1);
    c=randi([1 8],1);
    globalTone1235{c}(1,1:441)=onset.*globalTone1235{c}(1,1:441);
    globalTone1235{c}(1,12791:13231)=offset.*globalTone1235{c}(12791:13231);
    trial2 = PsychPortAudio('Open', [], [], 0,44100,1);
    PsychPortAudio('FillBuffer',trial2,globalTone1235{c});
    PsychPortAudio('Start',trial2,1,0,1);
    WaitSecs(0.3);
    PsychPortAudio('Stop',trial2);
    PsychPortAudio('Close',trial2); 
    Initial_Time=GetSecs;
    
    
%% Save mean
results(totalTrials,1)=data_Poss(randMean);


%% Freq saving
results(totalTrials,2)=poss5N;
results(totalTrials,3)=poss3N;
results(totalTrials,4)=poss1N;
results(totalTrials,5)=poss1P;
results(totalTrials,6)=poss3P;
results(totalTrials,7)=poss5P;



%% Distance from Mean
results(totalTrials,8)= positionAroundMean(c,:);


%% Save Test note freq
results(totalTrials,9)=valuesAroundMean(c,1);


%% Button press (save results) --> h for higher l for lower
Screen('DrawText',window,'Press "h" if the test sound is higher than the average of the 6 sounds',x-300,y);
Screen('DrawText',window,'Press "l" if the test sound is lower than the average of the 6 sounds',x-300,y+50);
Screen('Flip',window);




    KbName('UnifyKeynames');
    high_key=KbName('h');
    low_key=KbName('l');
    [keyIsDown,timeSecs,keyCode] = KbCheck();
    while ~keyCode(high_key) && ~keyCode(low_key)
        [keyIsDown,timeSecs,keyCode] = KbCheck();
    end
    if keyCode(high_key) ==1 && valuesAroundMean(c,1)>data_Poss(randMean)
        results(totalTrials,11)= 1;
    elseif keyCode(low_key)==1 && valuesAroundMean(c,1)<data_Poss(randMean)
        results(totalTrials,11)= 1;
    else
        results(totalTrials,11)=0;
    end
    
    
    %% Response time
    Final_Time=GetSecs;
    results(totalTrials,10)=Final_Time-Initial_Time;    
end




%% Calculate percent correct
totalCorrect=sum(results(1:totalTrials,11));
percentCorrect=totalCorrect/totalTrials*100;


%% Display percent correct
Screen('DrawText',window,'Below is your total percentage correct',x-250,y-50);
Screen('DrawText',window,[num2str(percentCorrect) '%'],x-50,y);
Screen('Flip',window);
WaitSecs(1.5);


%% Ending
Screen('DrawText',window,'Thank you for your time!', x-200,y);
Screen('Flip',window);
WaitSecs(1);
Screen('DrawText',window,'Press any key to close the simulation',x-250,y);
Screen('Flip',window);
pause;



%% Saving
save('results');



%% Finishing and closing screen
Screen('CloseAll');








































































































% Half of this code is useless spaces