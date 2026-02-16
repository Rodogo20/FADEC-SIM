%% MAIN 
% calls other scripts, run simulations, loads logs, calls plotting

clear; clc; close all;

%% Paths
scriptsDir = fileparts(mfilename("fullpath"));
projRoot   = fileparts(scriptsDir);
addpath(genpath(projRoot));

%% Settings
rerunSim = true;   % true = run Simulink again, false = use saved results
cfg.savePlots = false;   % true = save PNGs, false = just display

%cfg is a configuration container -

cfg.projRoot = projRoot;
cfg.model    = "top_level";

%% ========== TESTS ==========

tests = struct([]);

tests(1).name          = "step_up";
tests(1).stopTime      = 20;
tests(1).thr_step_time = 1;
tests(1).thr_init      = 0.0;
tests(1).thr_final     = 0.8;

tests(2).name          = "step_down";
tests(2).stopTime      = 20;
tests(2).thr_step_time = 1;
tests(2).thr_init      = 0.8;
tests(2).thr_final     = 0.2;

tests(3).name          = "slam";   %will need model upgrade for true slam
tests(3).stopTime      = 20;
tests(3).thr_step_time = 0.5;
tests(3).thr_init      = 0.0;
tests(3).thr_final     = 1.0;


activeTest = 1;   % choose 1, 2 or 3

tc = tests(activeTest);

cfg.stopTime = tc.stopTime;

cfg.test.thr_step_time = tc.thr_step_time;
cfg.test.thr_init      = tc.thr_init;
cfg.test.thr_final     = tc.thr_final;

cfg.testName = tc.name;
disp("Running test: " + cfg.testName);


cfg.logFile = fullfile(projRoot, "results", "logs", "stage1_" + cfg.testName + ".mat");
cfg.plotFile = fullfile(projRoot, "results", "plots", "stage1_" + cfg.testName + "_N.png");

%% Run simulation

if rerunSim
    simOut = run_simulations(cfg, tc);

else
    load(cfg.logFile, "simOut");
end

%% Make plots (from saved results)
make_plots(cfg, simOut);



















