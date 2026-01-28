%% init_params.m
% FADEC-SIM Stage 1 parameter initialization

%clearvars -except ans; %not in use for now 

%% Model / simulation
t_stop = 30;   % simulation running time - arbitrary

%% Initial conditions
N_idle = 0.25;   % initial normalized spool speed (0..1) 
N_max_ref = 1.0;   % max commanded normalized speed from throttle=1

%% Controller (speed loop)
% PI controller output (unconstrained): Wf_raw = Kp_N*e_N + Ki_N*Integral(e_N)

%conservative values
Kp_N = 2; %0.5-4
Ki_N = 1; %0.2-3

% Integrator clamp - (anti-windup)
I_N_min = -0.2;
I_N_max = 0.2;

%% Fuel actuator limits
Wf_min = 0;       % min fuel command
Wf_max = 1;       % max fuel command
dWf_up_max = 0.5;   % max fuel increase rate (per second)
dWf_dn_max = 1;   % max fuel decrease rate (per second)


%% Engine 
tau_N = 1.5;    % spool speed time constant (s)

% Steady-state linear map 
% N_eq = k_Neq*Wf_cmd + b_Neq

k_Neq = 1;
b_Neq = 0; %simplified for now

%% Proxy outputs (Stage 1)
% EGT proxy: EGT = EGT_idle + A_EGT*Wf_cmd - B_EGT*N
EGT_idle = [];
A_EGT    = [];
B_EGT    = [];

% Thrust proxy: Thrust = T_max * N^(a_thrust)
T_max    = [];
a_thrust = [];
