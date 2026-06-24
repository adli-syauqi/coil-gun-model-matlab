function p = parameters()
%PARAMETERS Central location for physical and numerical assumptions.
% Values are laboratory scale and intended for electromagnetic education,
% not engineering optimization.

p.constants.mu0 = 4*pi*1e-7;       % vacuum permeability [H/m]

% Solenoid geometry.
p.coil.radius = 0.015;             % innermost winding centerline radius [m]
p.coil.length = 0.050;             % [m]
p.coil.turns = 200;                % total turns
p.coil.segmentsPerTurn = 48;       % Biot-Savart line segments per loop
p.coil.wireRadius = 5.0e-4;        % copper wire radius used for winding layout [m]
p.coil.insulationGap = 1.0e-4;     % small spacing between neighboring wires [m]

% Ferromagnetic projectile, approximated as a small linear magnetic body.
p.projectile.mass = 0.005;         % [kg]
p.projectile.length = 0.030;       % [m]
p.projectile.radius = 0.005;       % [m]
p.projectile.mu_r = 200;           % relative permeability, constant model
p.projectile.chi = p.projectile.mu_r - 1;
p.projectile.volume = pi*p.projectile.radius^2*p.projectile.length;
p.projectile.z0 = -0.035;          % initial center position [m]
p.projectile.v0 = 0.0;             % initial velocity [m/s]
 
% RLC pulse approximation. The requested form assumes an initial peak
% current I0; the sign reversal is retained in B, while force uses B^2.
p.electrical.I0 = 120.0;            % [A]
p.electrical.R = 0.088;            % [ohm]
p.electrical.L = 1.0e-3;           % [H]
p.electrical.C = 3.0e-4;           % [F]

% Simulation domain.
p.simulation.tFinal = 0.012;       % [s]
p.simulation.currentSamples = 600;
p.simulation.odeRelTol = 1e-7;
p.simulation.odeAbsTol = 1e-9;
p.simulation.showAnimation = true;
p.simulation.animationFrames = 90;

% Rendering controls. Tube resolution affects only visual fidelity; the
% wire radius also defines the multilayer winding layout above.
p.visualization.wireRadius = p.coil.wireRadius;% displayed copper wire radius [m]
p.visualization.tubeSides = 12;            % circular facets for wire tube
p.visualization.coilSamplePoints = 2600;   % rendered helix samples
p.visualization.animationBaseDelay = 0.035;% seconds per frame at 1x speed

% Axial samples used for force interpolation.
p.force.zMin = -0.110;
p.force.zMax = 0.250;
p.force.samples = 721;

% 3D field grid for visualization. Keep moderate for interactive runtime.
p.field.x = linspace(-0.035, 0.035, 13);
p.field.y = linspace(-0.035, 0.035, 13);
p.field.z = linspace(-0.070, 0.070, 19);

% Numerical regularization. Grid points rarely sit exactly on a wire, but a
% small radius avoids singular values in classroom parameter edits.
p.numerics.wireSoftening = 4.0e-4; % [m]
p.numerics.segmentChunkSize = 512;
end
