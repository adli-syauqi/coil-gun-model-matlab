function motion = projectile_motion(forceModel, p)
%PROJECTILE_MOTION Integrate m z'' = F(z,t) with ode45.
% The magnetic force is proportional to I(t)^2 because it comes from B^2.

y0 = [p.projectile.z0; p.projectile.v0];
tSpan = [0, p.simulation.tFinal];
opts = odeset("RelTol", p.simulation.odeRelTol, ...
              "AbsTol", p.simulation.odeAbsTol, ...
              "MaxStep", p.simulation.tFinal/600);

odefun = @(t, y) rhs(t, y, forceModel, p);
[t, y] = ode45(odefun, tSpan, y0, opts);

z = y(:, 1);
v = y(:, 2);
force = zeros(size(t));
current = zeros(size(t));
acceleration = zeros(size(t));

for k = 1:numel(t)
    [force(k), current(k)] = axialForce(t(k), z(k), forceModel, p);
    acceleration(k) = force(k)/p.projectile.mass;
end

motion = struct();
motion.t = t;
motion.z = z;
motion.v = v;
motion.force = force;
motion.current = current;
motion.acceleration = acceleration;
end

function dydt = rhs(t, y, forceModel, p)
Fz = axialForce(t, y(1), forceModel, p);
dydt = [y(2); Fz/p.projectile.mass];
end

function [Fz, I] = axialForce(t, z, forceModel, p)
I = current_model(t, p);
forcePerAmp2 = forceModel.forceInterpolator(z);
Fz = forcePerAmp2 .* I.^2;
end
