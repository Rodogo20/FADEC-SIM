<div align="center">

<h1 align="center">
  <img src="./docs/Images/Matlab.png" height="35" alt="MATLAB" />
  &nbsp; FADEC-SIM &nbsp;
  <img src="./docs/Images/Simulink.png" height="35" alt="Simulink" />
</h1>
  

### Engine control simulation in MATLAB/Simulink 

![MATLAB](https://img.shields.io/badge/MATLAB-R2024b-orange)
![Simulink](https://img.shields.io/badge/Simulink-.slx%20model-blue)
![Status](https://img.shields.io/badge/status-complete-brightgreen)

<p>
  <a href="#run">Run</a> &nbsp;•&nbsp;
  <a href="#results">Results</a> &nbsp;•&nbsp;
  <a href="#subsystems">Subsystems</a> &nbsp;•&nbsp;
  <a href="#references">References</a>
</p>


**Author:** Rodolfo Godinez — Aerospace Engineering Student UC3M ┃ UCSD 
</div>

------------------------------------------------------------------------


A FADEC (Full Authority Digital Engine Control) is the onboard computer that commands engine fuel to meet pilot demands while enforcing safety limits. This project builds a simplified FADEC-style controller in MATLAB/Simulink around a generic turbofan-like plant.

The design is guided by the control architecture and terminology described in NASA’s C-MAPSS (Commercial Modular Aero-Propulsion System Simulation).

<div align="center">
  <img src="./docs/Images/MODEL.png" width="100%" alt="Description" />
</div>



<a id="run"></a>

## How to Run
**Requirements:** MATLAB + Simulink **R2024b**  
<div style="margin-top:-10px; margin-bottom:-8px;">
<table>
  <tr>
    <td><b>Steps:</b></td>
    <td>1) Open MATLAB in the repository root folder<br/>2) Run: <code>main</code></td>
  </tr>
</table>
</div>



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
  <img src="./docs/Images/nasa2.png" height="40" alt="NASA"
       style="float:right; position:relative; top:-4px;" />
</h2>

This project uses the following two NASA reports as primary references (see `docs/references/`):

- **User’s Guide for the Commercial Modular Aero-Propulsion System Simulation (C-MAPSS)** — *NASA/TM—2007-215026* (Oct 2007)
- **Aircraft Turbine Engine Control Research at NASA Glenn Research Center** — *NASA/TM—2013-217821* (Apr 2013)


