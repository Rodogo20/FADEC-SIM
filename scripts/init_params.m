%% init_params.m
% FADEC-SIM Stage 1 parameter initialization

if ~exist("thr_ts","var")
    % fallback: if running model manually without main
    if ~exist("thr_init","var"),      thr_init = 0.0; end
    if ~exist("thr_final","var"),     thr_final = 1; end
    if ~exist("thr_step_time","var"), thr_step_time = 1.0; end
    if ~exist("t_end","var"),         t_end = 20.0; end

    thr_ts = timeseries([thr_init; thr_final; thr_final], [0; thr_step_time; t_end]);
    thr_ts = setinterpmethod(thr_ts, "zoh");
end

thr0 = thr_ts.Data(1);

%% Initial conditions

N_idle    = 0.25;   %  normalized spool speed at iddle T= 0
N_max_ref = 1.0;    % max commanded normalized speed from throttle=1

N_init = N_idle + thr0 * (N_max_ref - N_idle);

%% Engine 
tau_N = 1.2;    % spool speed time constant (s)

% Steady-state linear map 
% N_eq = k_Neq*Wf_cmd + b_Neq

k_Neq = 1;
b_Neq = 0; %simplified for now

Wf_idle = (N_idle - b_Neq)/k_Neq;   
Wf_init = (N_init - b_Neq)/k_Neq;

%% Controller (speed loop)

t95_N = 5;                   % [s] time to reach 95% of commanded response
lambda_N = t95_N / 3;        % first-order relation

Kp_N = tau_N / (k_Neq * lambda_N);
Ki_N = 1 / (k_Neq * lambda_N);

% Integrator clamps - (anti-windup)
I_N_min = 0;
I_N_max =  1;

%% Fuel actuator limits
Wf_min     = 0;    % min fuel command
Wf_max     = 1;    % max fuel command
dWf_up_max = 0.5;  % max fuel increase rate (per second)
dWf_dn_max = 1;    % max fuel decrease rate (per second)


%% Proxy outputs 
% EGT proxy: EGT = EGT_idle + A_EGT*Wf_cmd - B_EGT*N
% NORMALISED
EGT_idle = 0.4;

A_EGT = 0.7;
B_EGT = 0.2;

EGT_init = EGT_idle + A_EGT * Wf_init - ( B_EGT * N_init );

tau_EGT = 2;   


%  EGT limiter
EGT_max  = 1.00; % normalized limit 
lambda_T = tau_EGT;        % conservative target
K_EGT    = A_EGT;          % local EGT sensitivity to fuel (proxy gain)

Kp_T = tau_EGT / (K_EGT * lambda_T);
Ki_T = 1 / (K_EGT * lambda_T);


% Thrust proxy: Thrust = T_max * N^(a_thrust)
% NORMALISED
T_max    = 1;
a_thrust = 2;  %non-linear matches intuition . Not realistic