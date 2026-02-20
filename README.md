

\## Author : Rodolfo Godinez , Aerospace Engineering Student at UC3M

\# FADEC-SIM    

Full Authority Digital Engine Control Simulation



Simplified FADEC-like engine control system implemented in MATLAB/Simulink. 



\## Structure

\- model/   : Simulink models

\- scripts/ : MATLAB scripts for simulation, tests, and plots
\- results/ : Generated plots and metrics
\- docs/    : references , planning and images
\- report/  :  written report

**Requirements:** MATLAB + Simulink

1. Open MATLAB in the repository root folder 
2) Run:

```matlab
main



\## Status

 **Stage 1**  
- Normalized first-order spool dynamics  
- Throttle → spool speed reference mapping  
- PI spool speed controller  
- Fuel saturation + rate limiting  
- Proxy EGT and thrust signals  
- Automated tests + plots + metrics 

![Stage 1 — stepUp](docs/images/stage1_stepUp.png)
![Stage 1 — stepDown](docs/images/stage1_stepDown.png)