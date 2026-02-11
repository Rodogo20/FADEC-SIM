function make_plots(cfg, simOut)


%% plots.m
% Loads saved simulation output and plots


scriptsDir = fileparts(mfilename("fullpath"));
projRoot   = fileparts(scriptsDir);

logsDir  = fullfile(projRoot, "results", "logs");
plotsDir = fullfile(projRoot, "results", "plots");

logFile = fullfile(logsDir, "stage1.mat");  
if ~isfile(logFile)
    error("Log file not found: %s. Run run_simulations.m first.", logFile);
end

load(logFile, "simOut");

logsout = simOut.logsout;


%% ========== PLOTS  ==========
N_ts = logsout.get("N").Values;   % this is a timeseries
t    = N_ts.Time;                 % time vector
N    = N_ts.Data;                 % data vector

figure;
plot(t, N);
grid on;
xlabel("Time (s)");
ylabel("N");
title("Logged signal: N");

end