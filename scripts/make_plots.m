function make_plots(cfg, simOut)

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
WfTlim_ts = logsout.get("Wf_Tlim").Values;
EGTLimActive_ts = logsout.get("EGT_lim_active").Values;

throttle   = thr_ts.Data;
Nref  = Nref_ts.Data;
N     = N_ts.Data;
Wf    = Wf_ts.Data;
Wf_raw = WfRaw_ts.Data;
Wf_Tlim = WfTlim_ts.Data;
EGT   = EGT_ts.Data;
Thrust = Th_ts.Data;

EGT_lim_active = EGTLimActive_ts;  %????


%% --------- METRICS ----------

e = Nref - N;   
avg_abs_err = mean(abs(e));   
rms_err = sqrt(mean(e.^2));    %rms penalizes big errors

overshoot = 100* abs((max(N) - max(Nref)) )/ max(Nref);

EGT_max = max(EGT);

runMetrics.avg_abs_err = avg_abs_err;
runMetrics.rms_err     = rms_err;
runMetrics.overshoot   = overshoot;
runMetrics.EGT_max     = EGT_max;


metricsDir = fullfile(cfg.projRoot, "results", "metrics");
if ~exist(metricsDir, "dir")
    mkdir(metricsDir);
end

save(fullfile(metricsDir, "stage2_" + cfg.testName + "_metrics.mat"), "runMetrics");


%% ========== PLOTS  ==========

fprintf("Stage2 - %s | avgE =%.3f RMS =%.3f OverShoot =%.3f %%  EGT_max =%.3f\n", ...
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
tl = tiledlayout(fig,2,2,'TileSpacing','compact','Padding','compact');

%% Plot 1 - Command vs engine response

nexttile;
plot(t, Nref);hold on;
plot(t, N);
plot(t, throttle, 'Color', [0 0 0 0.25], 'LineWidth', 5); 
grid on;
xlabel("Time (s)");
ylabel("Normalized");
title("Command vs Engine Response");
legend('$N_{\mathrm{ref}}$','$N$','Throttle','Location','best');
ylim([0 1.05]) ; 


%% Plot 2 - Fuel commands

nexttile;
plot(t, Wf_raw); hold on;
plot(t, Wf);
grid on;
xlabel("Time (s)");
legend('$Wf{}_{\mathrm{raw}}$','$Wf{}_{\mathrm{cmd}}$',"Location","best",'Interpreter','latex');
title('Fuel Commands')
ylim([min([Wf;Wf_raw;0]-0.1) max([Wf;Wf_raw ; 1] + 0.1)]);
h1 = yline(1,'--');
h2 = yline(0,'--');
h1.HandleVisibility = 'off';
h2.HandleVisibility = 'off';

ax = gca; yt = ax.YTick; tol = 1e-9;

if ~any(abs(yt-0)<tol), yt = sort([yt 0]); ax.YTick = yt; end
yl = string(yt);

yl(abs(yt-0)<tol) = "$Wf_{\mathrm{min}}$";    %replaces y axis values 
yl(abs(yt-1)<tol) = "$Wf_{\mathrm{max}}$";

ax.YTickLabel = yl;
ax.TickLabelInterpreter = "latex";




%% Plot 3 - EGT

nexttile;
plot(t, EGT);
grid on;
xlabel("Time (s)");
ylabel("EGT");
title("EGT Proxy");
ylim([0 max([1;EGT] + 0.1)]);



%% Plot 4 - Thrust

nexttile;
plot(t, Thrust);
grid on;
xlabel("Time (s)");
ylabel("Thrust");
title("Thrust Proxy");
ylim([0 1.05]) ; 



%% Global title 
title(tl, "V2 — " + string(cfg.testName), 'Interpreter','none','FontWeight','normal');


% ===== Save figure =====
outBase = fullfile(plotsDir, "V2_" + string(cfg.testName));
exportgraphics(fig, outBase + ".png", "Resolution", 300);  

end