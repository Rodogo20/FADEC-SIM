<div align="center">

<h1 align="center" style="font-size: 40px; margin: 0;">
  <img src="./docs/Images/Matlab.png" height="45" alt="MATLAB" />
  &nbsp; FADEC-SIM &nbsp;
  <img src="./docs/Images/Simulink.png" height="45" alt="Simulink" />
  
</h1>
  

<p style="font-size: 24px; margin-top: 6px;"><b>Simplified engine control system for a generic turbofan </b></p>

![MATLAB](https://img.shields.io/badge/MATLAB-R2024b-orange?style=for-the-badge)
![Simulink](https://img.shields.io/badge/Simulink-.slx%20model-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/status-complete-brightgreen?style=for-the-badge)




<p style="font-size: 18px; margin: 6px 0;">
  <a href="#run">Run</a> &nbsp;•&nbsp;
  <a href="#results">Results</a> &nbsp;•&nbsp;
  <a href="#control">Control Structure</a> &nbsp;•&nbsp;
  <a href="#references">References</a>
</p>


<p style="font-size: 18px; margin: 6px 0;">
   Rodolfo Godinez — Aerospace Engineering Student UC3M ┃ UCSD
</p>





</div>

-------------------------------------------------------------


A FADEC (Full Authority Digital Engine Control) is the onboard computer that commands engine fuel to meet pilot demand while enforcing safety limits. This project builds a simplified FADEC-style controller in MATLAB/Simulink around a generic turbofan-like plant.

The simulation focuses on engine transient response under throttle changes, combining closed-loop control with a nonlinear plant representation to produce realistic speed, fuel-flow, and temperature trends.


The model is implemented in normalized variables, which keeps controller, limiter and proxy outputs on a common scale across the test cases.

The design is guided by the control architecture, terminology and data described in [**NASA’s C-MAPSS**](#references).



<a id="model"></a>


<div align="center">
  <img src="./docs/Images/MODEL.png" width="100%" alt="Description" />
</div>




<a id="run"></a>

## How to Run

**Requirements** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Steps**<br/>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MATLAB &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1) Open MATLAB in the repository root folder<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Simulink R2024b &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2) Run: `main`

`main` runs the default cases and saves figures to `./results/`. &nbsp; Edit `scripts/` to change scenarios or settings.<br/>
Supporting MATLAB scripts handle parameter initialization, case execution, logging and plot generation.<br/>


<a id="results"></a>

## Results


<div align="center">
  <img src="./docs/Images/plots.png" width="100%" 
  alt="3x3 plots" />
</div>


<br/>
These plots summarize three standard transients : Step Up, Burst Chop and Ramp Up. 

<br/>The top row shows speed reference tracking from input throttle. It compares the demanded spool-speed profile with the simulated engine response, making it easy to see how the closed-loop system follows each maneuver. Across the three transients, this row mainly highlights rise, settling, and the overall quality of the tracking response.

The middle row shows how the raw fuel request is shaped into the final command by limits and rate logic. This is where the protection layer becomes visible, since the controller may briefly ask for more aggressive fuel changes than can be directly applied to the plant. The red shaded intervals indicate the periods where the thermal protection is active and fuel is being constrained to prevent further temperature rise.

The bottom row shows the EGT proxy, where EGT stands for Exhaust Gas Temperature. It provides a simple view of the thermal response during each maneuver and shows how temperature rises and settles more gradually than speed or fuel.






<a id="control"></a>
## Control Structure


The simulation combines a spool-speed control law with a non-linear turbofan model to capture realistic engine transients. The controller manages fuel flow through a PI feedback loop with tracking anti-windup while enforcing essential safety and physical limits like actuator saturation and rate limiting.

<div align="center">
  <img src="./docs/Images/flowchart1.png" width="95%" 
  alt="3x3 plots" />
</div>

Following the NASA control philosophy, fuel flow is treated as the main control variable, while spool speed acts as the main indicator of engine power setting. In practice, this means the controller does not send the raw fuel request directly to the plant. Instead, the command is passed through limiter and protection logic so the engine response remains stable and thermally reasonable during aggressive throttle changes. This follows the same general idea used in real FADEC systems, where fuel metering must achieve the demanded power without violating key operating limits.


<div align="center">
  <img src="./docs/Images/LUT.png" width="95%" 
  alt="3x3 plots" />
</div>

The plant replaces traditional linear constants with a multidimensional map derived from real-world flight data. This way the simulation captures the actual non-linear curvature and thermal behavior of a modern turbofan more realistically than a single fixed-gain approximation. 

For a block-level view of the complete implementation, see the [model overview](#model).

<h2 id="references">
  References
  <img src="./docs/Images/nasa2.png" height="40" alt="NASA" align="right" />
</h2>

This project uses the following two NASA reports as primary references (see `docs/references/`):

- **User’s Guide for the Commercial Modular Aero-Propulsion System Simulation (C-MAPSS)** — *NASA/TM—2007-215026* (Oct 2007)
- **Aircraft Turbine Engine Control Research at NASA Glenn Research Center** — *NASA/TM—2013-217821* (Apr 2013)
- **N-CMAPSS_DS02-006.h5** - *Figshare dataset*; used as the data source for the nonlinear map-based plant relationships in this project.

<div align="center">
  <img src="./docs/Images/nasa.png" width="50%" 
</div>


