function [I, pulse] = current_model(t, p)
%CURRENT_MODEL Underdamped RLC current approximation.
% I(t) = I0 exp(-R t / 2L) cos(w t), with
% w = sqrt(1/(LC) - R^2/(4L^2)).

R = p.electrical.R;
L = p.electrical.L;
C = p.electrical.C;
I0 = p.electrical.I0;

alpha = R/(2*L);
omegaSquared = 1/(L*C) - R^2/(4*L^2);

if omegaSquared <= 0
    error("current_model:Overdamped", ...
        "Chosen RLC parameters are not underdamped. Reduce R or increase L/C.");
end

omega = sqrt(omegaSquared);
I = I0 .* exp(-alpha.*t) .* cos(omega.*t);

pulse = struct();
pulse.alpha = alpha;
pulse.omega = omega;
pulse.frequency = omega/(2*pi);
pulse.dampingTime = 1/alpha;
pulse.firstZeroCrossing = pi/(2*omega);
end
