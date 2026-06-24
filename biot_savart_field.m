function B = biot_savart_field(coil, points, current, p)
%BIOT_SAVART_FIELD Magnetic flux density from segmented current loops.
% Implements dB = mu0 I/(4*pi) (dl x r)/|r|^3.
%
% points is M-by-3. B is M-by-3 in tesla.

arguments
    coil struct
    points (:,3) double
    current (1,1) double
    p struct
end

mu0 = p.constants.mu0;
softening2 = p.numerics.wireSoftening^2;
chunkSize = p.numerics.segmentChunkSize;

S = size(coil.segmentCenters, 1);
B = zeros(size(points));
coefficient = mu0*current/(4*pi);

for s0 = 1:chunkSize:S
    s1 = min(S, s0 + chunkSize - 1);
    centers = coil.segmentCenters(s0:s1, :);
    dl = coil.dl(s0:s1, :);

    rx = points(:,1) - centers(:,1).';
    ry = points(:,2) - centers(:,2).';
    rz = points(:,3) - centers(:,3).';
    invR3 = (rx.^2 + ry.^2 + rz.^2 + softening2).^(-1.5);

    cx = dl(:,2).'.*rz - dl(:,3).'.*ry;
    cy = dl(:,3).'.*rx - dl(:,1).'.*rz;
    cz = dl(:,1).'.*ry - dl(:,2).'.*rx;

    B(:,1) = B(:,1) + coefficient*sum(cx.*invR3, 2);
    B(:,2) = B(:,2) + coefficient*sum(cy.*invR3, 2);
    B(:,3) = B(:,3) + coefficient*sum(cz.*invR3, 2);
end
end
