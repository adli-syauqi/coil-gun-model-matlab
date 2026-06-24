function coil = coil_geometry(p)
%COIL_GEOMETRY Discretize a finite solenoid into circular current elements.
% Each turn is represented as a circular current loop. Turns are packed into
% axial layers using the wire diameter, then additional turns are placed on
% outer radial layers. This avoids the nonphysical single-layer compression
% that appears when a high turn count is forced into one helix.

N = p.coil.turns;
Ns = p.coil.segmentsPerTurn;
ell = p.coil.length;
wireDiameter = 2*p.coil.wireRadius;
axialPitch = wireDiameter + p.coil.insulationGap;
radialPitch = wireDiameter + p.coil.insulationGap;
turnsPerFullLayer = max(1, floor(ell/axialPitch));
numberOfLayers = ceil(N/turnsPerFullLayer);

thetaEdges = linspace(0, 2*pi, Ns + 1);
thetaMid = thetaEdges(1:end-1) + pi/Ns;
dtheta = 2*pi/Ns;

segmentCenters = zeros(N*Ns, 3);
dl = zeros(N*Ns, 3);
turnZ = zeros(N, 1);
turnRadius = zeros(N, 1);
turnLayer = zeros(N, 1);

k = 1;
turnIndex = 1;
plotLayers = repmat(struct("x", [], "y", [], "z", [], "radius", [], "turns", []), numberOfLayers, 1);

for layerIndex = 1:numberOfLayers
    turnsRemaining = N - turnIndex + 1;
    turnsInLayer = min(turnsPerFullLayer, turnsRemaining);
    a = p.coil.radius + (layerIndex - 1)*radialPitch;

    if turnsInLayer == 1
        zLayer = 0;
    else
        activeLength = (turnsInLayer - 1)*axialPitch;
        zLayer = linspace(-activeLength/2, activeLength/2, turnsInLayer);
    end

    % Adjacent layers are drawn in opposite axial directions, like a real
    % winding that returns at the end before stacking the next layer outward.
    zPlot = zLayer;
    if mod(layerIndex, 2) == 0
        zPlot = fliplr(zPlot);
    end
    thetaHelix = linspace(0, 2*pi*turnsInLayer, max(160, 36*turnsInLayer));
    plotLayers(layerIndex).x = a*cos(thetaHelix);
    plotLayers(layerIndex).y = a*sin(thetaHelix);
    if turnsInLayer == 1
        plotLayers(layerIndex).z = zPlot*ones(size(thetaHelix));
    else
        plotLayers(layerIndex).z = interp1(linspace(0, 1, turnsInLayer), zPlot, ...
            linspace(0, 1, numel(thetaHelix)), "linear", "extrap");
    end
    plotLayers(layerIndex).radius = a;
    plotLayers(layerIndex).turns = turnsInLayer;

    for localTurn = 1:turnsInLayer
        n = turnIndex;
        z = zLayer(localTurn);
        turnZ(n) = z;
        turnRadius(n) = a;
        turnLayer(n) = layerIndex;

    xMid = a*cos(thetaMid);
    yMid = a*sin(thetaMid);

    % Tangential line element for a counterclockwise loop viewed from +z.
    dlLoop = [-a*sin(thetaMid(:))*dtheta, ...
               a*cos(thetaMid(:))*dtheta, ...
               zeros(Ns, 1)];
    centersLoop = [xMid(:), yMid(:), z*ones(Ns, 1)];

    idx = k:(k + Ns - 1);
    segmentCenters(idx, :) = centersLoop;
    dl(idx, :) = dlLoop;
    k = k + Ns;
        turnIndex = turnIndex + 1;
    end
end

% Concatenated plot vectors are kept for simple diagnostics, while the
% layer-wise paths are used by visualization.m for high-fidelity rendering.
coil.plot.layers = plotLayers;
coil.plot.x = [];
coil.plot.y = [];
coil.plot.z = [];
for layerIndex = 1:numberOfLayers
    coil.plot.x = [coil.plot.x, plotLayers(layerIndex).x, NaN]; %#ok<AGROW>
    coil.plot.y = [coil.plot.y, plotLayers(layerIndex).y, NaN]; %#ok<AGROW>
    coil.plot.z = [coil.plot.z, plotLayers(layerIndex).z, NaN]; %#ok<AGROW>
end

coil.segmentCenters = segmentCenters;
coil.dl = dl;
coil.turnZ = turnZ;
coil.turnRadius = turnRadius;
coil.turnLayer = turnLayer;
coil.innerRadius = p.coil.radius;
coil.outerRadius = p.coil.radius + (numberOfLayers - 1)*radialPitch;
coil.radius = p.coil.radius;
coil.length = ell;
coil.turns = N;
coil.turnsPerLayer = turnsPerFullLayer;
coil.numberOfLayers = numberOfLayers;
coil.segmentsPerTurn = Ns;
end
