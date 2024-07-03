function stimstruct = Stroop(ID, Group)

if ~exist(['./audioResults/' num2str(ID)], 'dir')
    mkdir(['./audioResults/' num2str(ID)]);
end

Screen('Preference', 'SkipSyncTests',1);
% Clear the workspace and the screen
% sca;
% close all;
% clear;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Screens');

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this. For help see: help max
screenNumber = 1;

% Define black and white (white will be 1 and black 0). This is because we
% are defining luminace values between 0 and 1 through the use of the PTB
% default setting call above.
% For help see: help WhiteIndex and help BlackIndex
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace value for white
grey = white / 2;

% Start cordinate in pixels of our window. Note that setting both of these
% to zero will make the window appear in the top right of the screen.
startXpix = 120;
startYpix = 50;

% Dimensions in pixels of our window in the X (left-right) and Y (up down)
% dimensions
dimX = 400;
dimY = 250;

% Open an on screen window using PsychImaging and color it grey.
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,...
%     [startXpix startYpix startXpix + dimX startYpix + dimY]);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
% For help see: Screen BlendFunction?
% Also see: Chapter 6 of the OpenGL programming guide
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

[ monitorFlipInterval, nrValidSamples, stddev ] = Screen('GetFlipInterval', window);

%----------------------------------------------------------------------
%                     Make stim list
%----------------------------------------------------------------------


% We are going to use three colors for this demo. Red, Green and blue.
wordList = {'A', 'E', 'I', 'O'};
wordListT = {'W', 'K', 'D', 'J'};
rgbColors = [255/255 174/255 201/255; 0/255 0/255 255/255; 255/255 255/255 0/255; 201/255 16/255 26/255];

% Incongruent condition
condMatrixBase = [sort(repmat([1 2 3 4], 1, 3)); 2 3 4 1 3 4 1 2 4 1 2 3];

% Congruent condition
condMatrixBaseC = [sort(repmat([1 2 3 4], 1, 3)); sort(repmat([1 2 3 4], 1, 3))];
condMatrixBaseE = [sort(repmat([1 2 3 4], 1, 1)); sort(repmat([1 2 3 4], 1, 1))];

%Number of Repetitions
trialsPerCondition = 2;
trialsPerConditionE = 5;

% Duplicate the condition matrix to get the full number of trials
condMatrix = repmat(condMatrixBase, 1, trialsPerCondition);
condMatrixC = repmat(condMatrixBaseC, 1, trialsPerCondition);
condMatrixE = repmat(condMatrixBaseE, 1, trialsPerConditionE);

% Get the size of the matrix
% [~, numTrials] = size(condMatrix);
[~, numTrials] = size(condMatrixC);

% Randomise the conditions
shuffler = Shuffle(1:numTrials);
condMatrixShuffled = condMatrix(:, shuffler);
condMatrixShuffledC = condMatrixC(:, shuffler);
numTrialsE = size(condMatrixE,2);
shufflerE = Shuffle(1:numTrialsE);
condMatrixShuffledE = condMatrixE(:, shufflerE);

respMatGII= nan(5, numTrials);
respMatGCI= nan(5, numTrials);
respMatGIR= nan(5, numTrials);
respMatGCR= nan(5, numTrials);
respMatTII= nan(5, numTrials);
respMatTCI= nan(5, numTrials);
respMatTIR= nan(5, numTrials);
respMatTCR= nan(5, numTrials);
respMatE= nan(4, numTrialsE);

%% Stimulus structure

stimstruct = struct;
stimstruct.numTrials = numTrials;
stimstruct.condMatrixShuffledC = condMatrixShuffledC;
stimstruct.wordList = wordList;
stimstruct.xCenter = xCenter;
stimstruct.yCenter = yCenter;
stimstruct.rgbColors = rgbColors;
stimstruct.black = black;
stimstruct.grey = grey;
stimstruct.IFI = monitorFlipInterval;
stimstruct.expStart = GetSecs;


%%

%----------------------------------------------------------------------
%                     Dialogue box for info
%----------------------------------------------------------------------


% prompt = {'Enter participant ID:','Enter group:'};
% dlgtitle = 'Input';
dims = [1 35];
% definput = {'1','S'};
% answer = inputdlg(prompt,dlgtitle,dims,definput);
% ID = cell2mat(answer(1))-48;
% ID=ID(1)*10+ID(2);
% Group = cell2mat(answer(2));


stimstruct.ID = ID;
stimstruct.Group = Group;
%----------------------------------------------------------------------
%                     Run Gen XP in a random order
%----------------------------------------------------------------------
% C = {'GenIncInk.m', 'GenCongInk.m', 'GenIncRet.m', 'GenCongRet.m'};
% for k = randperm(numel(C))
%    run(C{k})
% end



a = audiorecorder(11025,16,1,2);
% K = {'GenCongInk.m'};
for l = 1
    
%     run(K{l})    

    [respMatGCI, audio] = GenCongInk(window, stimstruct, a);
    toc;
end

for n = 1:size(audio, 2)
    filename = [num2str(n) '_fileGCI.wav'];
    audiowrite(['./audioResults/' num2str(stimstruct.ID) '/' filename],audio(:,n),11025);
end



%----------------------------------------------------------------------
%                     Run Exposure
%----------------------------------------------------------------------

% D = {'Exposure.m', 'VerifLearning.m'};
% for l = (1:2) 
    
%     run(D{l})
% end


%----------------------------------------------------------------------
%                     Run Train XP in a random order
%----------------------------------------------------------------------

% E = {'TrainIncInk.m', 'TrainCongInk.m', 'TrainIncRet.m', 'TrainCongRet.m'};
% for k = randperm(numel(E))
%     run(E{k})
% end

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca

stimstruct.expEnd = GetSecs;
stimstruct.expDuration = stimstruct.expEnd - stimstruct.expStart;
sca;