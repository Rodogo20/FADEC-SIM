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
  <a href="#subsystems">Subsystems</a> &nbsp;•&nbsp;
  <a href="#references">References</a>
</p>


<p style="font-size: 18px; margin: 6px 0;">
   Rodolfo Godinez — Aerospace Engineering Student UC3M ┃ UCSD
</p>




</div>

------------------------------------------------------------------------


A FADEC (Full Authority Digital Engine Control) is the onboard computer that commands engine fuel to meet pilot demands while enforcing safety limits. This project builds a simplified FADEC-style controller in MATLAB/Simulink around a generic turbofan-like plant.

The simulation combines a spool-speed control law with a non-linear turbofan model to capture realistic engine transients. The controller manages fuel flow through a PI feedback loop while enforcing essential safety and physical limits like actuator saturation / rate-limiting. 

The plant replaces traditional linear constants with multidimensional maps derived from real-world flight data.
This way the simulation captures the actual non-linear curvature and thermal behavior of a modern turbofan.

The design is guided by the control architecture, terminology and data described in [**NASA’s C-MAPSS**](#references).

<div align="center">
  <img src="./docs/Images/MODEL.png" width="100%" alt="Description" />
</div>



<a id="run"></a>

## How to Run

<table border="0">
  <tr>
    <td valign="top"><b>Requirements</b><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MATLAB<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Simulink R2024b</td>
    <td width="150"></td>
    <td valign="top"><b>Steps</b><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1) Open MATLAB in the repository root folder<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2) Run: <code>main</code></td>
  </tr>
</table>

`main` runs the default cases and saves figures to `./results/`. Edit `scripts/` to change scenarios or settings.


<a id="results"></a>

## Results


<div align="center">
  <img src="./docs/Images/plots.png" width="100%" alt="Description" />
</div>



These plots summarize three standard transients (Step Up, Burst Chop, Ramp Up). 
Top row shows speed reference tracking from input throttle, middle row shows how the raw fuel request is shaped into the final command by limits/rate logic, and bottom row shows the EGT proxy, where EGT stands for Exhaust Gas Temperature.











<a id="references"></a>

<h2 id="references">
  References
  <img src="./docs/Images/nasa2.png" height="40" alt="NASA" align="right" />
</h2>

This project uses the following two NASA reports as primary references (see `docs/references/`):

- **User’s Guide for the Commercial Modular Aero-Propulsion System Simulation (C-MAPSS)** — *NASA/TM—2007-215026* (Oct 2007)
- **Aircraft Turbine Engine Control Research at NASA Glenn Research Center** — *NASA/TM—2013-217821* (Apr 2013)


