function make_plots(cfg, simOut, runInfo)


%% plots.m
% Loads saved simulation output and plots


scriptsDir = fileparts(mfilename("fullpath"));
projRoot   = fileparts(scriptsDir);

logsDir  = fullfile(projRoot, "results", "logs");
plotsDir = fullfile(projRoot, "results", "plots");

if ~exist(plotsDir, "dir")   %creates folder in case it doesnt exist
    mkdir(plotsDir);
end


logsout = simOut.logsout;

%EXTRACT vectors
t = simOut.tout;  % common simulation time

thr_ts   = logsout.get("throttle").Values;
Nref_ts  = logsout.get("N_ref").Values;
N_ts     = logsout.get("N").Values;
Wf_ts    = logsout.get("Wf_cmd").Values;
EGT_ts   = logsout.get("EGT").Values;
Th_ts    = logsout.get("Thrust").Values;

thr   = thr_ts.Data;
Nref  = Nref_ts.Data;
N     = N_ts.Data;
Wf    = Wf_ts.Data;
EGT   = EGT_ts.Data;
Thrust = Th_ts.Data;



%% ========== PLOTS  ==========

%% Plot 1 - Command vs engine response
figure;
plot(t, thr); hold on;
plot(t, Nref);
plot(t, N);
grid on;
xlabel("Time (s)");
ylabel("Normalized");
title("Command vs Engine Response");
legend("throttle","N_{ref}","N","Location","best");

if cfg.savePlots
    saveas(gcf, fullfile(plotsDir, "stage1_" + cfg.testName + "_01_response.png"));
    close(gcf);
end

%% Plot 2 - Fuel command
figure;
plot(t, Wf);
grid on;
xlabel("Time (s)");
ylabel("Wf_{cmd}");
title("Fuel Command");

if cfg.savePlots
    saveas(gcf, fullfile(plotsDir, "stage1_" + cfg.testName + "_02_fuel.png"));
    close(gcf);
end

%% Plot 3 - EGT
figure;
plot(t, EGT);
grid on;
xlabel("Time (s)");
ylabel("EGT");
title("EGT Proxy");

if cfg.savePlots
    saveas(gcf, fullfile(plotsDir, "stage1_" + cfg.testName + "_03_egt.png"));
    close(gcf);
end

%% Plot 4 - Thrust
figure;
plot(t, Thrust);
grid on;
xlabel("Time (s)");
ylabel("Thrust");
title("Thrust Proxy");

if cfg.savePlots
    saveas(gcf, fullfile(plotsDir, "stage1_" + cfg.testName + "_04_thrust.png"));
    close(gcf);
end


end