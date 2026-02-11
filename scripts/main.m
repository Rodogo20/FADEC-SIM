%% MAIN 
% calls other scripts, run simulations, loads logs, calls plotting

clear; clc; close all;

%% Paths
scriptsDir = fileparts(mfilename("fullpath"));
projRoot   = fileparts(scriptsDir);
addpath(genpath(projRoot));

%% Settings
rerunSim = true;   % true = run Simulink again, false = use saved results

%cfg is a configuration container -

cfg.projRoot = projRoot;
cfg.model    = "top_level";

cfg.stopTime = 20;

cfg.test.thr_step_time = 1;
cfg.test.thr_init      = 0.0;
cfg.test.thr_final     = 0.8;


cfg.logFile = fullfile(projRoot, "results", "logs", "stage1.mat");
cfg.plotFile = fullfile(projRoot, "results", "plots", "stage1_N.png");

%% Run simulation

if rerunSim
    simOut = run_simulations(cfg);
else 
    load(cfg.logFile, "simOut");
end

%% Make plots (from saved results)
make_plots(cfg, simOut);



















