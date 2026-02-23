function simOut = run_simulations(cfg, tc)


%% run_simulations.m
% Stage 1 baseline simple runner 

thr_ts = tc.thr_ts;  %#ok<NASGU>

%% Paths / project setup
scriptDir = fileparts(mfilename("fullpath"));  


mdl = cfg.model;                    % Simulink model name (no .slx)

projRoot = fileparts(scriptDir);
addpath(genpath(projRoot));         

% Load parameters
initFile = fullfile(projRoot, "scripts", "init_params.m");
if ~isfile(initFile)
    error("init_params.m not found at: %s", initFile);
end

run(initFile);       

%% Load model + basic sim settings
load_system(mdl);

t_stop = tc.stopTime;   % simulation running time - arbitrary
set_param(mdl, "StopTime", num2str(t_stop));


% Turn on signal logging 
set_param(mdl, "SignalLogging", "on", "SignalLoggingName", "logsout");


%% ========== RUN  ==========


simOut = sim(mdl, "SrcWorkspace","current");

logsout = simOut.logsout;


try        %sanity check
    thr = simOut.logsout.get("throttle").Values;
    fprintf("Throttle: start=%.3f, end=%.3f\n", thr.Data(1), thr.Data(end));
catch
    warning("Signal 'throttle' not found in logsout (check signal name/label).");
end


%% Save baseline output
logsDir = fullfile(projRoot, "results", "logs");
if ~exist(logsDir, "dir")
    mkdir(logsDir);
end


runInfo.timestamp = datestr(now);   %saves metadata
runInfo.model     = cfg.model;
runInfo.stopTime  = cfg.stopTime;
runInfo.test      = cfg.test;
save(cfg.logFile, "simOut", "cfg", "runInfo");

disp("saved log");


end