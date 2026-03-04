%% init_params.m
% FADEC-SIM Stage 1 parameter initialization

if ~exist("thr_ts","var")
    % fallback: if running model manually without main
    if ~exist("thr_init","var"),      thr_init = 0.0; end
    if ~exist("thr_final","var"),     thr_final = 1; end
    if ~exist("thr_step_time","var"), thr_step_time = 3.0; end
    if ~exist("t_end","var"),         t_end = 20.0; end

    thr_ts = timeseries([thr_init; thr_final; thr_final], [0; thr_step_time; t_end]);
    thr_ts = setinterpmethod(thr_ts, "zoh");
end

thr0 = thr_ts.Data(1);

%% Command Mapping

N_idle    = 0.25;   %  normalized spool speed at iddle T= 0
N_max_ref = 1.0;    % max commanded normalized speed from throttle=1

%LUT
throttle_bp   = [0 0.05 0.10 0.20 0.40 0.70 1.00];   %breakpoints     
f_tbl = [0 0.005 0.015 0.05 0.20 0.65 1.00];         %table values 

Nref_tbl = N_idle + (N_max_ref - N_idle).* f_tbl;

thr0 = min(max(thr0, throttle_bp(1)), throttle_bp(end));
f0 = interp1(throttle_bp, f_tbl, thr0, 'linear');
N_init = N_idle + (N_max_ref - N_idle) * f0;

% monotonic, shaped

%% Engine 
tau_N = 1.2;    % spool speed time constant (s)


k_Neq = 1;
b_Neq = 0; %simplified for now

a_Neq = k_Neq / (1 - b_Neq);

%invert for initial idle conditions
den = 1 - exp(-a_Neq);

y = (N_idle - b_Neq)/(1 - b_Neq);  
Wf_idle = -(1/a_Neq)*log(1 - y*den);

y = (N_init - b_Neq)/(1 - b_Neq);  
Wf_init = -(1/a_Neq)*log(1 - y*den);


%% Controller (speed loop)

t95_N = 5;                   % [s] time to reach 95% of commanded response
lambda_N = t95_N / 3;        % first-order relation

Kp_N = tau_N / (k_Neq * lambda_N);
Ki_N = 1 / (k_Neq * lambda_N);

K_aw = Ki_N / Kp_N ; 

% Integrator clamps - (anti-windup)
I_N_min = 0;
I_N_max =  1;

%% Fuel actuator limits
Wf_min     = 0;    % min fuel command
Wf_max     = 1;    % max fuel command
dWf_up_max = 0.5;  % max fuel increase rate (per second)
dWf_dn_max = 1;    % max fuel decrease rate (per second)


%% Proxy outputs 

% EGT NORMALISED

tau_EGT = 2;   

%NASA LUT

lutFile  = fullfile(projRoot,"data","processed","egt_lut_v1.mat");
S = load(lutFile);

Nc_bp   = double(S.Nc_bp(:)');     % LUT speed axis 
Wf_bp   = double(S.Wf_bp(:)');      % LUT fuel axis 
EGT_LUT = double(S.EGT_LUT);      % LUT table

%% FORCE LIMITER ============================
EGT_test_gain = 1.15;

% Initial EGT 
N0  = min(max(N_init,  min(Nc_bp)), max(Nc_bp));
Wf0 = min(max(Wf_init, min(Wf_bp)), max(Wf_bp));
EGT_init = interp2(Wf_bp, Nc_bp, EGT_LUT, Wf0, N0, "linear");

%  EGT limiter
EGT_max  = 1.00; % normalized limit 
lambda_T = tau_EGT;        % conservative target
K_EGT    = 0.7 ;          % local EGT sensitivity to fuel 

Kp_T = tau_EGT / (K_EGT * lambda_T);
Ki_T = 1 / (K_EGT * lambda_T);


% Thrust proxy: Thrust = T_max * N^(a_thrust)
% NORMALISED
T_max    = 1;
a_thrust = 2;  %non-linear matches intuition . Not realistic