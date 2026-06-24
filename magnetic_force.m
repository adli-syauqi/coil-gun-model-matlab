function forceModel = magnetic_force(coil, p)
%MAGNETIC_FORCE Axial magnetic force from magnetic energy gradient.
% A linear ferromagnetic projectile in an external field has approximate
% energy U = -(chi V / 2 mu0) B^2. Therefore,
% Fz = (chi V / 2 mu0) d(B^2)/dz.
%
% The model uses the projectile center position and axial field. This is a
% deliberate educational approximation: it captures attraction toward the
% stronger-field coil region without saturation, hysteresis, or demagnetizing
% corrections.

z = linspace(p.force.zMin, p.force.zMax, p.force.samples).';
axisPoints = [zeros(size(z)), zeros(size(z)), z];

BperAmp = biot_savart_field(coil, axisPoints, 1.0, p);
B2perAmp2 = sum(BperAmp.^2, 2);
dB2dzPerAmp2 = gradient(B2perAmp2, z);

scale = p.projectile.chi*p.projectile.volume/(2*p.constants.mu0);
forcePerAmp2 = scale*dB2dzPerAmp2;

forceAtPeakCurrent = forcePerAmp2 .* p.electrical.I0.^2;
potentialAtPeakCurrent = -scale*B2perAmp2 .* p.electrical.I0.^2;

forceModel = struct();
forceModel.z = z;
forceModel.BperAmp = BperAmp;
forceModel.BmagPerAmp = sqrt(B2perAmp2);
forceModel.B2perAmp2 = B2perAmp2;
forceModel.dB2dzPerAmp2 = dB2dzPerAmp2;
forceModel.forcePerAmp2 = forcePerAmp2;
forceModel.forceAtPeakCurrent = forceAtPeakCurrent;
forceModel.potentialAtPeakCurrent = potentialAtPeakCurrent;
forceModel.forceInterpolator = griddedInterpolant(z, forcePerAmp2, "pchip", "nearest");
end
