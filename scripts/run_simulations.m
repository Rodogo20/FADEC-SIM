%% run_simulations.m
% Stage 1 baseline simple runner 

%% Paths / project setup
scriptDir = fileparts(mfilename("fullpath"));  
cd(scriptDir);

mdl = "top_level";                      % Simulink model name (no .slx)

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

t_stop = 20;   % simulation running time - arbitrary
set_param(mdl, "StopTime", num2str(t_stop));


% Turn on signal logging 
set_param(mdl, "SignalLogging", "on", "SignalLoggingName", "logsout");

%% ========== TESTS ==========

tests = struct([]);

% Test 1 (edit later)
tests(1).name          = "step_up";
tests(1).thr_step_time = 1;
tests(1).thr_init      = 0.0;
tests(1).thr_final     = 0.8;

activeTest = 1;


%% ========== RUN (single baseline sim) ==========
% Apply selected test 
tc = tests(activeTest);

assignin("base","thr_step_time", tc.thr_step_time);
assignin("base","thr_init",      tc.thr_init);
assignin("base","thr_final",     tc.thr_final);

simOut = sim(mdl);
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

save(fullfile(logsDir, "stage1.mat"), "simOut");

disp("Stage 1  saved to results/logs/stage1_baseline.mat");
