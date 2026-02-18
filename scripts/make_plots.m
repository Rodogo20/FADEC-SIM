function make_plots(cfg, simOut, runInfo)

close all;

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
WfRaw_ts = logsout.get("Wf_raw").Values;

thr   = thr_ts.Data;
Nref  = Nref_ts.Data;
N     = N_ts.Data;
Wf    = Wf_ts.Data;
Wf_raw = WfRaw_ts.Data;
EGT   = EGT_ts.Data;
Thrust = Th_ts.Data;


%% --------- METRICS ----------

e = Nref - N;   
avg_abs_err = mean(abs(e));   
rms_err = sqrt(mean(e.^2));    %rms penalizes big errors

overshoot = max(N) - Nref(end);

EGT_max = max(EGT);

runMetrics.avg_abs_err = avg_abs_err;
runMetrics.rms_err     = rms_err;
runMetrics.overshoot   = overshoot;
runMetrics.EGT_max     = EGT_max;


metricsDir = fullfile(cfg.projRoot, "results", "metrics");
if ~exist(metricsDir, "dir")
    mkdir(metricsDir);
end

save(fullfile(metricsDir, "stage1_" + cfg.testName + "_metrics.mat"), "runMetrics");


%% ========== PLOTS  ==========

fprintf("Stage1 - %s | avgE =%.3f RMS =%.3f OverShoot =%.3f EGT_max =%.3f\n", ...
    cfg.testName, runMetrics.avg_abs_err, runMetrics.rms_err, runMetrics.overshoot, runMetrics.EGT_max);

set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');

set(groot,'defaultAxesFontSize',15);
set(groot,'defaultTextFontSize',14);
set(groot,'defaultLegendFontSize',12);

set(groot,'defaultLineLineWidth',1.4);
set(groot,'defaultAxesLineWidth',1.0);

set(groot,'defaultFigureColor','w');

fig = figure;
set(fig,'WindowState','maximized');
tiledlayout(2,2);
set(gcf,'Position',[100 100 1100 700]);
grid on;



set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');

set(groot,'defaultAxesFontSize',15);
set(groot,'defaultTextFontSize',14);
set(groot,'defaultLegendFontSize',12);

set(groot,'defaultLineLineWidth',1.4);
set(groot,'defaultAxesLineWidth',1.0);

set(groot,'defaultFigureColor','w');




%% Plot 1 - Command vs engine response

nexttile;
plot(t, Nref);hold on;
plot(t, N);
plot(t, e);
grid on;
xlabel("Time (s)");
ylabel("Normalized");
title("Command vs Engine Response");
legend('$N_{\mathrm{ref}}$','$N$','$e$','Location','best');
ylim([min(e) - 0.05 1.05]) ; 


%% Plot 2 - Fuel commands

nexttile;
plot(t, Wf_raw); hold on;
plot(t, Wf);
grid on;
xlabel("Time (s)");
legend('$Wf{}_{\mathrm{raw}}$','$Wf{}_{\mathrm{cmd}}$',"Location","best",'Interpreter','latex');
title('Fuel Commands')
ylim([min([Wf;Wf_raw]) max([Wf;Wf_raw] + 0.05)]);

ax = gca;
yt = ax.YTick;
yl = string(yt);

idx = abs(yt - 1) < 1e-9;          % tick at 1.0
yl(idx) = "$Wf_{\mathrm{max}}$";  % replace label

ax.YTickLabel = yl;
ax.TickLabelInterpreter = "latex";


%% Plot 3 - EGT

nexttile;
plot(t, EGT);
grid on;
xlabel("Time (s)");
ylabel("EGT");
title("EGT Proxy");
xline(cfg.test.thr_step_time,'--','T','Interpreter','latex');
ylim([0 1.05]) ; 



%% Plot 4 - Thrust

nexttile;
plot(t, Thrust);
grid on;
xlabel("Time (s)");
ylabel("Thrust");
title("Thrust Proxy");
xline(cfg.test.thr_step_time,'--','T','Interpreter','latex');
ylim([0 1.05]) ; 


end