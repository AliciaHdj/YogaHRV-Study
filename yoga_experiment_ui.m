%% ========================================================================
%          ST4Health Masters DMH - Research Project - User Interface
%                    A. Obert, A. Heddadj, C. Moy
%
%   Make sure OpenSignals has LSL enabled and start recording before
%   running this code.
%% ========================================================================


function yoga_experiment_ui()

    % INITIALIZING VARIABLES & BUFFERS
    % Global variables
    global fs windowSec ecgBuffer respBuffer ecgAxes respAxes

    fs = 1000;          % BITalino sampling frequency
    windowSec = 10;

    ecgBuffer  = [];
    respBuffer = [];

    lslInlet = [];

    % Full buffers (for saving & HRV)
    ecgBufferAll  = [];
    pztBufferAll  = [];
    timeBufferAll = [];

    % Display buffers (rolling)
    ecgBufferDisp = [];
    pztBufferDisp = [];

    % Pose markers
    poseMarkers = [];

    sessionStartTime = [];

    % !! DEFINING EXPERIMENT PARAMETERS !!
    % Posture Sequence
    poses = {
        'Resting', 'poses/pose1.jpg';
        'Tadasana', 'poses/pose2.jpg';
        'Adhomukhasana', 'poses/pose3.jpg';
        'Paschimottanasana', 'poses/pose4.jpg';
        'Virabhadrasana', 'poses/pose5.jpg';
        'Shavasana', 'poses/pose6.jpg'
    };

    poseDuration = 5 * 60; % in seconds
    currentPose = 1;
    timeLeft = poseDuration;

    timerObj = [];
    lslTimer = [];

    
    % UI WINDOW
    % Initializing Window
    fig = uifigure('Name','Yoga HRV Experiment',...
                   'Position',[100 100 1200 700]);

    % Pose Title
    titleLabel = uilabel(fig,...
        'Text',poses{currentPose,1},...
        'FontSize',22,...
        'FontWeight','bold',...
        'HorizontalAlignment','center',...
        'Position',[300 650 600 30]);
    % Pose Image
    poseAxes = uiaxes(fig,'Position',[30 350 350 280]);
    axis(poseAxes,'off');

    % Timer Label
    timerLabel = uilabel(fig,...
        'Text','05:00',...
        'FontSize',26,...
        'FontWeight','bold',...
        'HorizontalAlignment','center',...
        'Position',[450 600 200 40]);

    % Buttons
    startBtn = uibutton(fig,'push',...
        'Text','Start',...
        'FontSize',14,...
        'Position',[470 540 160 40],...
        'ButtonPushedFcn',@startTimer);

    nextBtn = uibutton(fig,'push',...
        'Text','Next Pose',...
        'FontSize',14,...
        'Position',[470 490 160 40],...
        'ButtonPushedFcn',@nextPose);

    endBtn = uibutton(fig,'push',...
        'Text','End Session',...
        'FontSize',14,...
        'Position',[470 440 160 40],...
        'ButtonPushedFcn',@endSession);

    % Signals Axes
    ecgAxes = uiaxes(fig,'Position',[400 230 750 140]);
    title(ecgAxes,'ECG (last 10 s)');

    pztAxes = uiaxes(fig,'Position',[400 60 750 140]);
    title(pztAxes,'Respiration (PZT)');

    % INITIALIZNG LSL
    initLSL();

    lslTimer = timer( ...
        'ExecutionMode','fixedRate', ...
        'Period',0.05, ...     % 20 Hz UI refresh
        'TimerFcn',@updateSignals);
    start(lslTimer);

    % INITIAL DISPLAY
    showPose();
    updateTimerLabel();

    % FUNCTIONS
    function showPose()
        cla(poseAxes);
        img = imread(poses{currentPose,2});
        imshow(img,'Parent',poseAxes);
        axis(poseAxes,'image');
        axis(poseAxes,'off');
        titleLabel.Text = poses{currentPose,1};
    end

    function updateTimerLabel()
        min = floor(timeLeft/60);
        sec = mod(timeLeft,60);
        timerLabel.Text = sprintf('%02d:%02d',min,sec);
    end

    % Start Pose
    function startTimer(~,~)

        if ~isempty(timerObj)
            stop(timerObj);
            delete(timerObj);
        end

        % Store pose marker
        if ~isempty(timeBufferAll)
            poseMarkers(end+1).pose = poses{currentPose,1};
            poseMarkers(end).time  = timeBufferAll(end);
        end

        timeLeft = poseDuration;
        updateTimerLabel();
        speak(['Début de ',poses{currentPose,1}]);

        timerObj = timer( ...
            'ExecutionMode','fixedRate', ...
            'Period',1, ...
            'TimerFcn',@timerTick);
        start(timerObj);
    end

    function timerTick(~,~)
        timeLeft = timeLeft - 1;
        updateTimerLabel();

        if mod(timeLeft,60)==0 && timeLeft>0
            speak(sprintf('Il reste %d minutes',timeLeft/60));
        end

        if timeLeft<=3 && timeLeft>0
            beep;
        end

        if timeLeft<=0
            stop(timerObj);
            speak('Fin de la posture');
        end
    end

    function nextPose(~,~)
        if ~isempty(timerObj)
            stop(timerObj);
        end
        currentPose = currentPose + 1;
        if currentPose > size(poses,1)
            currentPose = 1;
        end
        timeLeft = poseDuration;
        showPose();
        updateTimerLabel();
        speak(['Posture suivante ',poses{currentPose,1}]);
    end

    % End Session
    function endSession(~,~)

        if ~isempty(timerObj)
            stop(timerObj); delete(timerObj);
        end
        if ~isempty(lslTimer)
            stop(lslTimer); delete(lslTimer);
        end

        % Saving data
        t = timeBufferAll(:);

        dataTable = table( ...
            t, ...
            ecgBufferAll(:), ...
            pztBufferAll(:), ...
            'VariableNames',{'Time_s','ECG','PZT'});

        filename = sprintf('yoga_session_%s.xlsx',datestr(now,'yyyymmdd_HHMMSS'));
        writetable(dataTable,filename);

        save(strrep(filename,'.xlsx','.mat'), ...
             'ecgBufferAll','pztBufferAll','timeBufferAll','poseMarkers','poses','fs');

        speak('Session terminée');
        close(fig);
    end

    % TEXT TO SPEECH FOR AUDITORY TIMER
    function speak(text)
        try
            NET.addAssembly('System.Speech');
            speaker = System.Speech.Synthesis.SpeechSynthesizer;
            speaker.SpeakAsync(text);
        catch
            disp(text);
        end
    end

    % LSL Connection
    function initLSL()
        lib = lsl_loadlib();
        streams = lsl_resolve_byprop(lib,'type','ECG',5);
        if isempty(streams)
            streams = lsl_resolve_all(lib,5);
        end
        lslInlet = lsl_inlet(streams{1});
        disp('LSL connected');
    end

    % Updating Signals
    function updateSignals()
        global ecgBuffer respBuffer fs windowSec ecgAxes respAxes
    
        if isempty(ecgBuffer)
            return
        end
    
        t = (0:length(ecgBuffer)-1) / fs;         % Time Vector

        % Display Window
        Nwin = round(windowSec * fs);
    
        if length(ecgBuffer) > Nwin
            ecgDisp  = ecgBuffer(end-Nwin+1:end);
            respDisp = respBuffer(end-Nwin+1:end);
            tDisp    = t(end-Nwin+1:end);
        else
            ecgDisp  = ecgBuffer;
            respDisp = respBuffer;
            tDisp    = t;
        end
    
   
        % Plots
        cla(ecgAxes)
        plot(ecgAxes, tDisp, ecgDisp,'r','LineWidth',1)
        grid(ecgAxes,'on')
        xlim(ecgAxes,[tDisp(1) tDisp(end)])
        ylim(ecgAxes,'auto')
        title(ecgAxes,'ECG (live, 1000 Hz)')
        xlabel(ecgAxes,'Time (s)')
        ylabel(ecgAxes,'Amplitude')
    
        cla(respAxes)
        plot(respAxes, tDisp, respDisp,'b','LineWidth',1)
        grid(respAxes,'on')
        xlim(respAxes,[tDisp(1) tDisp(end)])
        ylim(respAxes,'auto')
        title(respAxes,'Respiration (PZT)')
        xlabel(respAxes,'Time (s)')
        ylabel(respAxes,'Amplitude')
    
        drawnow limitrate
    end

end