%% Single-Stage Coil Gun Electromagnetics Simulation
% This project demonstrates how a pulsed solenoid field can be computed
% from the Biot-Savart law and coupled to a simplified ferromagnetic slug
% model through magnetic energy and Newton's second law.

clear; close all; clc;

projectRoot = fileparts(mfilename("fullpath"));
addpath(projectRoot);

p = parameters();

fprintf("Single-stage coil gun electromagnetic simulation\n");
fprintf("Coil: %d turns, radius %.1f mm, length %.1f mm\n", ...
    p.coil.turns, 1e3*p.coil.radius, 1e3*p.coil.length);
fprintf("Projectile: %.1f g iron slug, mu_r = %.0f\n", ...
    1e3*p.projectile.mass, p.projectile.mu_r);
fprintf("Electrical pulse: I0 = %.1f A, R = %.3f ohm, L = %.4f H, C = %.4f F\n\n", ...
    p.electrical.I0, p.electrical.R, p.electrical.L, p.electrical.C);

coil = coil_geometry(p);

% Current pulse used for plots and ODE forcing.
tPulse = linspace(0, p.simulation.tFinal, p.simulation.currentSamples);
[I, pulse] = current_model(tPulse, p);

% Compute the 3D field at the peak-current instant for visualization.
% meshgrid ordering is used because MATLAB's slice/interp3 functions expect
% this grid convention for volume visualization.
[X, Y, Z] = meshgrid(p.field.x, p.field.y, p.field.z);
fieldPoints = [X(:), Y(:), Z(:)];
B = biot_savart_field(coil, fieldPoints, p.electrical.I0, p);
Bx = reshape(B(:,1), size(X));
By = reshape(B(:,2), size(X));
Bz = reshape(B(:,3), size(X));
Bmag = sqrt(Bx.^2 + By.^2 + Bz.^2);

% Compute the axial field and magnetic force basis from Biot-Savart.
forceModel = magnetic_force(coil, p);

% Integrate projectile motion with ode45.
motion = projectile_motion(forceModel, p);

results = struct();
results.coil = coil;
results.tPulse = tPulse;
results.current = I;
results.pulse = pulse;
results.field.X = X;
results.field.Y = Y;
results.field.Z = Z;
results.field.Bx = Bx;
results.field.By = By;
results.field.Bz = Bz;
results.field.Bmag = Bmag;
results.forceModel = forceModel;
results.motion = motion;

visualization(results, p);

fprintf("Simulation complete.\n");
fprintf("Peak |B| on plotting grid: %.3f T\n", max(Bmag, [], "all"));
fprintf("Peak axial force at %.0f A: %.2f N\n", ...
    p.electrical.I0, max(abs(forceModel.forceAtPeakCurrent)));
fprintf("Final projectile position: %.1f mm\n", 1e3*motion.z(end));
fprintf("Final projectile velocity: %.2f m/s\n", motion.v(end));
