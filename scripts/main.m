%% MAIN
clear; clc; close all;

%% Paths
scriptsDir = fileparts(mfilename("fullpath"));
projRoot   = fileparts(scriptsDir);
addpath(genpath(projRoot));

%% Settings
rerunSim = true;
cfg.projRoot = projRoot;
cfg.model    = "top_level";

%% ========== TESTS ==========
tests = struct([]);



% --- Step  test
tests(1).name          = "stepUp";
tests(1).profile       = "step";
tests(1).thr_init      = 0.0;
tests(1).thr_final     = 0.8;
tests(1).thr_step_time = 1.0;
tests(1).t_end         = 20.0;

% --- Burst–Chop
tests(2).name     = "burstChop";
tests(2).profile  = "burstChop";
tests(2).t_burst  = 1.0;
tests(2).t_chop   = 12.0;
tests(2).t_end    = 20.0;   % will become stopTime

% --- Ramp test
tests(3).name         = "rampUp";
tests(3).profile      = "ramp";
tests(3).thr_init     = 0.1;
tests(3).thr_final    = 0.9;
tests(3).t_ramp_start = 1.0;
tests(3).t_ramp_end   = 8.0;
tests(3).t_end        = 20.0;

%% ======= LOOP  =======
for k = 2 % 1:numel(tests)  %replace 1:numel(tests) for single test

    tc = tests(k);

    % Build ONLY Simulink input: thr_ts + stopTime + events
    [tc.thr_ts, tc.stopTime, tc.events] = build_thr_ts(tc);

    cfg.stopTime = tc.stopTime;
    cfg.test     = tc;          % keep for plots/metadata
    cfg.testName = tc.name;

    disp("Running test: " + cfg.testName);

    cfg.logFile = fullfile(projRoot, "results", "logs", "V2_" + cfg.testName + ".mat");

    if rerunSim
        simOut = run_simulations(cfg, tc);
    else
        load(cfg.logFile, "simOut");
    end

    make_plots(cfg, simOut);
end

%% ======= local Build Throttle function =======
function [thr_ts, stopTime, events] = build_thr_ts(tc)

profile = lower(string(tc.profile));

switch profile
    case "step"
        t = [0; tc.thr_step_time; tc.t_end];
        u = [tc.thr_init; tc.thr_final; tc.thr_final];
        thr_ts = timeseries(u, t);
        thr_ts = setinterpmethod(thr_ts, "zoh");
        events = struct("t", tc.thr_step_time, "label", "STEP");

    case "ramp"
        dt = 0.01;
        t  = (0:dt:tc.t_end)';
    
        u = tc.thr_init*ones(size(t));
        idx = (t >= tc.t_ramp_start) & (t <= tc.t_ramp_end);
        u(idx) = tc.thr_init + (tc.thr_final - tc.thr_init) .* ...
                 (t(idx) - tc.t_ramp_start) ./ (tc.t_ramp_end - tc.t_ramp_start);
        u(t > tc.t_ramp_end) = tc.thr_final;
    
        thr_ts = timeseries(u, t);
    
        events = [ ...
            struct("t", tc.t_ramp_start, "label", "RAMP_START"), ...
            struct("t", tc.t_ramp_end,   "label", "RAMP_END") ...
        ];

    case "burstchop"
        t = [0; tc.t_burst; tc.t_chop; tc.t_end];
        u = [0; 1; 0; 0];          % idle=0, max=1 by convention
        thr_ts = timeseries(u, t);
        thr_ts = setinterpmethod(thr_ts, "zoh");
        events = [ ...
            struct("t", tc.t_burst, "label", "BURST"), ...
            struct("t", tc.t_chop,  "label", "CHOP") ...
        ];
        otherwise
            error("Unknown profile: %s", profile);
    end

% Clamp to [0,1]
thr_ts.Data = max(0, min(1, thr_ts.Data));

stopTime = thr_ts.Time(end);

end