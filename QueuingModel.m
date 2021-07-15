clc;
close all;
figure;
for i=0:0.05:1
preChecking = round(700*i);
N_Total = 700-preChecking; % Total
Gates = 1;
N = N_Total/Gates; % Total entering each gate
Groups = 1; 
%Spaces = N/10;

%TicketRate = 1/10 ;%+ normrnd(0,1); % time taken to process ticket in min
TicketRate = 1/4;
Ticketers = 2; % number of ticket processors
OpenEarly = 30;
Start = 120;

Prevalence = 0.02;

if Groups>1
SlotGaps = (Start-60)/Groups;
GroupTimes = 0:SlotGaps:Start-SlotGaps;
IndivGroup = randi(Groups,1,N);
ArrivalMean = GroupTimes(IndivGroup);
ArrivalSd = 15; 
ArrivalTimes = normrnd(ArrivalMean,ArrivalSd); 
Open = min(ArrivalMean) - OpenEarly;

histogram(ArrivalTimes, 20);
hold on
line([Open, Open], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','--');
line([0, 0], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-.');
line([Start, Start], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-');
hold off

else
a = 6;b = 1.61;
%a = 6,b=1.11
ArrivalTimes =130*betarnd(a*ones(1,N),b*ones(1,N))-5; 
Open = min(ArrivalTimes) - OpenEarly;
%figure;
%histogram(ArrivalTimes,20);
end
disp(median(ArrivalTimes));



%attendees
Infected = zeros(1,N);
seeds = binornd(N,Prevalence); %Number of positives: should also be based off testing
InfectedInd = randsample(N,seeds); % select positives randomly
Infected(InfectedInd) = 1; % 1 if infected 0 ow
%Ticketers
InfectedTicketers_N = binornd(Ticketers,Prevalence);
InfectedTicketers = randsample(Ticketers,InfectedTicketers_N);

TicketerRisk = zeros(1,N);

QueueLength = [];
Queue = [];
Ts = [];
Tmin = floor(min(ArrivalTimes));
disp('Tmim')
disp(Tmin)

%figure(1)
%histogram(ArrivalTimes);
%hold on
%line([Open, Open], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','--');
%line([0, 0], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-.');
%line([Start, Start], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-');
%hold off
%% simulation
Time = Tmin;
while sum(isnan(ArrivalTimes)) < N
    Time = Time + 1;
    Ts = [Ts Time];
    % arrivals
    NewQueue = find(ArrivalTimes <= Time); % number there upon opening
    ArrivalTimes(NewQueue) = NaN;
    NewQueue = NewQueue(randperm(length(NewQueue)));
    Queue = [Queue NewQueue];
    % removals
    if Time >= Open
        OldQueue = poissrnd((1/TicketRate)*Ticketers);
        Remove = min(OldQueue,length(Queue));
        Ticketer_Removed = randi(Ticketers,1,Remove);
        N_infectedTicketer = find(Ticketer_Removed == InfectedTicketers);
        TicketerRisk(Queue(N_infectedTicketer)) = 1;
        if Remove == length(Queue)
            Queue = [];
        else
            Queue = Queue(Remove+1:end);
        end
    end
    QueueLength = [QueueLength length(Queue)]; %maybe used later to determine crowding
end
fname = sprintf('myfile%i.mat', round(i*100));
%save(fname,'Ts','QueueLength') ;
hold on
plot(Ts,QueueLength);
end