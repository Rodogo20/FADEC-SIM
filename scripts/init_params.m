%% init_params.m
% FADEC-SIM Stage 1 parameter initialization

clearvars -except ans;  

%% Model / simulation
t_stop = [];   % simulation running time

%% Initial conditions
N_idle = [];   % initial normalized spool speed (0..1)


%% Controller (speed loop)
% PI controller output (unconstrained): Wf_raw = Kp_N*e_N + Ki_N*Integral(e_N)
Kp_N = [];
Ki_N = [];

% Integrator clamp 
I_N_min = [];
I_N_max = [];

%% Fuel actuator limits
Wf_min = [];       % min fuel command
Wf_max = [];       % max fuel command
dWf_up_max = [];   % max fuel increase rate (per second)
dWf_dn_max = [];   % max fuel decrease rate (per second)


%% Engine 
tau_N = [];    % spool speed time constant (s)

% Steady-state linear map 
% N_eq = k_Neq*Wf_cmd + b_Neq
k_Neq = [];
b_Neq = [];

%% Proxy outputs (Stage 1)
% EGT proxy: EGT = EGT_idle + A_EGT*Wf_cmd - B_EGT*N
EGT_idle = [];
A_EGT    = [];
B_EGT    = [];

% Thrust proxy: Thrust = T_max * N^(a_thrust)
T_max    = [];
a_thrust = [];
