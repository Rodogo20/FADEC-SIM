function make_plots(cfg, simOut, k)

%% plots.m
% Loads saved simulation output and plots


plotsDir = fullfile(cfg.projRoot, "results", "plots");
if ~exist(plotsDir, "dir")
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

EGT_lim_active = EGTLimActive_ts.Data;                %limiter flag
lim = (EGT_lim_active(:) > 0.5);

d = diff([false; lim; false]);
iStart = find(d == 1);
iEnd   = find(d == -1) - 1;

% remove tiny 1–2 sample blips
minPts = 3;
keep = (iEnd - iStart + 1) >= minPts;
iStart = iStart(keep);
iEnd   = iEnd(keep);

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

% ----- figure position: each test takes one third of screen width -----
pos = [
    0.01 0.05 0.32 0.86
    0.34 0.05 0.32 0.86
    0.67 0.05 0.32 0.86
];

fig = figure('Units','normalized', ...
             'Position', pos(k,:), ...
             'Color','w');
tl = tiledlayout(fig,3,1,'TileSpacing','loose','Padding','loose');

%% Plot 1 - Command vs engine response

nexttile;
plot(t, Nref);hold on;
plot(t, N);
plot(t, throttle, 'Color', [0 0 0 0.15], 'LineWidth', 8); 
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
yl = ylim;

for seg = 1:numel(iStart)   % EGT limiter shading 
    idx = iStart(seg):iEnd(seg);
    x = t(idx);
    y = Wf(idx);
    y0 = yl(1);

    p = patch([x; flipud(x)], ...
              [y0*ones(size(y)); flipud(y)], ...
              [1 0 0], ...
              'FaceAlpha', 0.08, ...
              'EdgeColor', 'none', ...
              'HandleVisibility', 'off');
    uistack(p,'bottom');
end

h1 = yline(1,'--');
h2 = yline(0,'--');
h1.HandleVisibility = 'off';
h2.HandleVisibility = 'off';

ax = gca;    %change y axis values 
yt = ax.YTick(:);
yt = unique([yt; 0; 1]);     
yt = sort(yt);
ax.YTick = yt;

labels = string(yt);

[~, i0] = min(abs(yt - 0));
[~, i1] = min(abs(yt - 1));
labels(i0) = "$Wf_{\mathrm{min}}$";
labels(i1) = "$Wf_{\mathrm{max}}$";

ax.YTickLabel = labels;
ax.TickLabelInterpreter = "latex";

ax.YTickMode = "manual";
ax.YTickLabelMode = "manual";




%% Plot 3 - EGT
nexttile;
plot(t, EGT, 'r'); hold on
yline(1,'k--');

grid on;
xlabel("Time (s)");
title("EGT Proxy");
ylim([0 max([1; EGT] + 0.1)]);

ax = gca;

% force tick at y = 1
yt = unique(sort([ax.YTick 1]));
ax.YTick = yt;

% build labels
labs = arrayfun(@num2str, yt, 'UniformOutput', false);
idx = find(abs(yt - 1) < 1e-12, 1);
labs{idx} = '$EGT_{\max}$';

ax.YTickLabel = labs;
ax.TickLabelInterpreter = 'latex';

yl = ylim;
yTop = yl(2);

for seg = 1:numel(iStart)  % limiter shading
    idx = iStart(seg):iEnd(seg);
    x = t(idx);
    y = EGT(idx);

    p = patch([x; flipud(x)], ...
              [y; yTop*ones(size(y))], ...
              [1 0 0], ...
              'FaceAlpha', 0.08, ...
              'EdgeColor', 'none', ...
              'HandleVisibility', 'off');
    uistack(p,'bottom');
end


%% Global title 
title(tl, string(cfg.testName), 'Interpreter','none','FontWeight','bold');


% ===== Save figure =====
outBase = fullfile(plotsDir, "V2_" + string(cfg.testName));

set(findall(fig,'Type','axes'),'FontSize',14)
exportgraphics(fig, outBase + ".png", "Resolution", 300);  

end