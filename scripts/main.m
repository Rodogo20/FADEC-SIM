%% MAIN 
% calls other scripts, run simulations, loads logs, calls plotting

clear; clc; close all;

%% Paths
scriptsDir = fileparts(mfilename("fullpath"));
projRoot   = fileparts(scriptsDir);
addpath(genpath(projRoot));

%% Settings
rerunSim = true;   % true = run Simulink again, false = use saved results

%% Run simulation

if rerunSim
    run(fullfile(scriptsDir, "run_simulations.m"));
end

%% Make plots (from saved results)
run(fullfile(scriptsDir, "plots.m"));



















