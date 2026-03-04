%% BUILD EGT LUT FROM NASA N-CMAPSS - DS02 dataset

clear; clc; close all;

%% --------- Paths  ----------
thisFile   = mfilename("fullpath");
projRoot   = fileparts(fileparts(thisFile));  
rawDir     = fullfile(projRoot, "data", "raw");
outDir     = fullfile(projRoot, "data", "processed");
outFile    = fullfile(outDir, "egt_lut_v1.mat");
if ~exist(outDir, "dir"), mkdir(outDir); end



%% --------- Locate file  ----------

h5 = fullfile(rawDir,"N-CMAPSS_DS02-006.h5");
if ~isfile(h5), error("Missing file: %s", h5); end

% %variable names in each dataset

% W_var  = strtrim(string(h5read(h5,"/W_var")));
% T_var  = strtrim(string(h5read(h5,"/T_var")));
% Xs_var = strtrim(string(h5read(h5,"/X_s_var")));
% Xv_var = strtrim(string(h5read(h5,"/X_v_var")));
% A_var  = strtrim(string(h5read(h5,"/A_var")));
% 
% W_var, T_var, Xs_var, Xv_var, A_var


% the three interested variables are found on Xs_var / dev dataset
% Minimal extraction , reads only 1 row each

T50 = h5read(h5, "/X_s_dev", [4  1], [1 Inf])';   % EGT-like
Nc = h5read(h5, "/X_s_dev", [13 1], [1 Inf])';   % core speed
Wf  = h5read(h5, "/X_s_dev", [14 1], [1 Inf])';   % fuel flow

Nc_ref = prctile(Nc,99);  %take safe max values
Wf_ref = prctile(Wf,99);

Nc_n = Nc/ Nc_ref;   % normalize
Wf_n = Wf / Wf_ref;

T_idle = prctile(T50,0.01);   
T_lim  = prctile(T50,98);

EGT_n = (T50 - T_idle) / (T_lim - T_idle);   % normalize
% EGT_n = max(min(EGT_n, 1.2), 0);    % allows max headroom

%% create LUT

Nc_bp = linspace(0.6, 1.0, 7);   % 7 speed breakpoints
Wf_bp = linspace(0.0, 1.0, 9);   % 9 fuel breakpoints

%binning
Nc_edges  = [-inf, (Nc_bp(1:end-1)+Nc_bp(2:end))/2,  inf];
Wf_edges  = [-inf, (Wf_bp(1:end-1)+Wf_bp(2:end))/2,  inf];

iN = discretize(Nc_n, Nc_edges);   
iW = discretize(Wf_n, Wf_edges);  
ok = ~isnan(iN) & ~isnan(iW); %drop weird samples

%average one representative EGT value per cell
EGT_LUT = accumarray([iN(ok) iW(ok)], EGT_n(ok), ...
                     [numel(Nc_bp) numel(Wf_bp)], ...
                     @mean, NaN);    

%fill empty cells
[NN,WW] = ndgrid(Nc_bp, Wf_bp);
mask = ~isnan(EGT_LUT);

F = scatteredInterpolant(NN(mask), WW(mask), EGT_LUT(mask), ...
                         "nearest", "nearest");
EGT_LUT = F(NN, WW);
EGT_LUT = movmean(movmean(EGT_LUT, 3, 1), 3, 2);  % 3x3 smoothing

%% ---- Save LUT to data/processed ----
outDir = fullfile("data","processed");
if ~exist(outDir,"dir"), mkdir(outDir); end

save(outFile, "Nc_bp","Wf_bp","EGT_LUT","Nc_ref","Wf_ref","T_idle","T_lim");
fprintf("Saved: %s\n", outFile);




%% Compare plot

%% ---- Figure: Stage 1 proxy vs NASA LUT ----
A_EGT    = 0.7;
B_EGT    = 0.2;
EGT_idle = 0.4;


[NCg, WFg] = ndgrid(Nc_bp, Wf_bp);

% Stage 1 model on the same grid (normalized signals)
EGT_stage1_grid = EGT_idle + A_EGT.*WFg - B_EGT.*NCg;

% Difference
dEGT = EGT_LUT - EGT_stage1_grid;

figure("Name","EGT Proxy: Stage 1 vs NASA LUT");
tiledlayout(2,2,"Padding","compact","TileSpacing","compact");

nexttile;
surf(Wf_bp, Nc_bp, EGT_LUT); grid on;
xlabel("Wf_n"); ylabel("Nc_n"); zlabel("EGT_n");
title("NASA LUT (EGT)");

nexttile;
surf(Wf_bp, Nc_bp, EGT_stage1_grid); grid on;
xlabel("Wf_n"); ylabel("Nc_n"); zlabel("EGT_n");
title("Stage 1 proxy (EGT)");

nexttile;
surf(Wf_bp, Nc_bp, dEGT); grid on;
xlabel("Wf_n"); ylabel("Nc_n"); zlabel("\Delta EGT_n");
title("Difference: LUT - Stage 1");

nexttile;
plot(Wf_bp, EGT_LUT(end,:), "LineWidth", 1.2); hold on; grid on;
plot(Wf_bp, EGT_stage1_grid(end,:), "--", "LineWidth", 1.2);
xlabel("Wf_n"); ylabel("EGT_n");
title("High-speed slice (N = max)");
legend("LUT","Stage 1","Location","best");
ylim([0 inf]) 




