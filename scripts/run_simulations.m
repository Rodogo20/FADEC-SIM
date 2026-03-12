function simOut = run_simulations(cfg, tc)


%% run_simulations.m
%baseline simple runner 

thr_ts = tc.thr_ts;  %#ok<NASGU>

%% Project setup
mdl = cfg.model;  % Simulink model name (no .slx)

if isfield(cfg,"projRoot") && ~isempty(cfg.projRoot)
    projRoot = cfg.projRoot;
else
    scriptDir = fileparts(mfilename("fullpath"));
    projRoot  = fileparts(scriptDir);
end    

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

% sanity check
try
    names = simOut.logsout.getElementNames;
    if ~any(strcmp(names,"throttle"))
        warning("Signal 'throttle' not found in logsout (check signal name/label).");
    end
catch
    warning("logsout missing or not a Dataset (check Signal Logging settings).");
end


%% Save baseline output
logDir = fileparts(cfg.logFile);
if ~exist(logDir, "dir")
    mkdir(logDir);
end


runInfo.timestamp = datestr(now);   %saves metadata
runInfo.model     = cfg.model;
runInfo.stopTime  = cfg.stopTime;
runInfo.test      = cfg.test;
save(cfg.logFile, "simOut", "cfg", "runInfo");

disp("saved log");


end