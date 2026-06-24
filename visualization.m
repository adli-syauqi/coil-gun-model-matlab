function visualization(results, p)
%VISUALIZATION Generate publication-oriented figures and an animation.

coil = results.coil;
motion = results.motion;
forceModel = results.forceModel;

%% Figure 1: coil geometry and projectile.
figure("Name", "Figure 1 - Coil geometry", "Color", "w");
hCoil = drawCoilWinding(coil, p);
hold on;
hProjectile = drawProjectile(motion.z(1), p, [0.18 0.42 0.72], 0.75);
camlight headlight;
lighting gouraud;
axis equal; grid on; box on;
xlabel("x [m]"); ylabel("y [m]"); zlabel("z [m]");
title("Solenoid geometry and initial ferromagnetic projectile position");
view(38, 22);
legend([hCoil, hProjectile], ["Solenoid winding", "Projectile"], "Location", "northeast");

%% Figure 2: 3D magnetic field.
X = results.field.X;
Y = results.field.Y;
Z = results.field.Z;
Bx = results.field.Bx;
By = results.field.By;
Bz = results.field.Bz;
Bmag = results.field.Bmag;

figure("Name", "Figure 2 - Magnetic field distribution", "Color", "w");
slice(X, Y, Z, Bmag, 0, 0, 0);
shading interp;
colormap(turbo);
cb = colorbar;
cb.Label.String = "|B| [T]";
hold on;
qStride = 2;
quiver3(X(1:qStride:end,1:qStride:end,1:qStride:end), ...
        Y(1:qStride:end,1:qStride:end,1:qStride:end), ...
        Z(1:qStride:end,1:qStride:end,1:qStride:end), ...
        Bx(1:qStride:end,1:qStride:end,1:qStride:end), ...
        By(1:qStride:end,1:qStride:end,1:qStride:end), ...
        Bz(1:qStride:end,1:qStride:end,1:qStride:end), ...
        1.8, "k");
drawCoilWinding(coil, p);
camlight headlight;
lighting gouraud;
axis equal tight; grid on; box on;
xlabel("x [m]"); ylabel("y [m]"); zlabel("z [m]");
title(sprintf("Biot-Savart magnetic field at I = %.0f A", p.electrical.I0));
view(40, 24);

%% Figure 3: field and force along the coil axis.
figure("Name", "Figure 3 - Axial field and magnetic force", "Color", "w");
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");

nexttile;
plot(1e3*forceModel.z, p.electrical.I0*forceModel.BmagPerAmp, ...
    "LineWidth", 1.8, "Color", [0.12 0.36 0.62]);
grid on; box on;
xlabel("Projectile center z [mm]");
ylabel("|B| [T]");
title("Axial magnetic flux density from Biot-Savart law");
xline(-1e3*p.coil.length/2, "--", "Coil ends");
xline( 1e3*p.coil.length/2, "--", "HandleVisibility", "off");

nexttile;
plot(1e3*forceModel.z, forceModel.forceAtPeakCurrent, ...
    "LineWidth", 1.8, "Color", [0.67 0.18 0.16]);
grid on; box on;
xlabel("Projectile center z [mm]");
ylabel("F_z [N]");
title("Magnetic force from F_z = (\chi V / 2\mu_0) d(B^2)/dz");
xline(-1e3*p.coil.length/2, "--", "Coil ends");
xline( 1e3*p.coil.length/2, "--", "HandleVisibility", "off");
yline(0, "k:");

%% Figure 4: projectile dynamics.
figure("Name", "Figure 4 - Projectile dynamics", "Color", "w");
tiledlayout(3, 1, "TileSpacing", "compact", "Padding", "compact");

nexttile;
plot(1e3*motion.t, 1e3*motion.z, "LineWidth", 1.8, "Color", [0.12 0.36 0.62]);
grid on; box on;
xlabel("Time [ms]"); ylabel("z [mm]");
title("Projectile position");

nexttile;
plot(1e3*motion.t, motion.v, "LineWidth", 1.8, "Color", [0.16 0.50 0.28]);
grid on; box on;
xlabel("Time [ms]"); ylabel("v_z [m/s]");
title("Projectile velocity");

nexttile;
plot(1e3*motion.t, motion.acceleration, "LineWidth", 1.8, "Color", [0.67 0.18 0.16]);
grid on; box on;
xlabel("Time [ms]"); ylabel("a_z [m/s^2]");
title("Projectile acceleration");

%% Current pulse, useful for interpreting the dynamics.
figure("Name", "RLC current pulse", "Color", "w");
plot(1e3*results.tPulse, results.current, "LineWidth", 1.8, "Color", [0.20 0.20 0.20]);
grid on; box on;
xlabel("Time [ms]"); ylabel("Current [A]");
title("Assumed underdamped RLC discharge current");

if p.simulation.showAnimation
    animateProjectile(results, p);
end
end

function h = drawProjectile(zCenter, p, faceColor, alphaValue)
radius = p.projectile.radius;
length = p.projectile.length;
[Xc, Yc, Zc] = cylinder(radius, 36);
Zc = (Zc - 0.5)*length + zCenter;
h = surf(Xc, Yc, Zc, ...
    "FaceColor", faceColor, ...
    "EdgeColor", "none", ...
    "FaceAlpha", alphaValue, ...
    "DisplayName", "Projectile");
end

function h = drawCoilWinding(coil, p)
%DRAWCOILWINDING Render the solenoid as copper tubes following layer helices.
% The rendered paths match the multilayer winding layout used by the
% Biot-Savart loop geometry.

hold on;
numberOfLayers = numel(coil.plot.layers);
samplesPerLayer = max(160, ceil(p.visualization.coilSamplePoints/max(1, numberOfLayers)));
h = gobjects(numberOfLayers, 1);

for layerIndex = 1:numberOfLayers
    layer = coil.plot.layers(layerIndex);
    numSamples = min(samplesPerLayer, numel(layer.x));
    sampleIdx = unique(round(linspace(1, numel(layer.x), numSamples)));
    centerline = [layer.x(sampleIdx).', layer.y(sampleIdx).', layer.z(sampleIdx).'];

    [Xw, Yw, Zw] = tubeAlongCurve(centerline, p.visualization.wireRadius, p.visualization.tubeSides);
    h(layerIndex) = surf(Xw, Yw, Zw, ...
        "FaceColor", [0.88 0.42 0.12], ...
        "EdgeColor", "none", ...
        "FaceLighting", "gouraud", ...
        "AmbientStrength", 0.35, ...
        "DiffuseStrength", 0.75, ...
        "SpecularStrength", 0.25, ...
        "DisplayName", "Solenoid winding");
end
h = h(1);

% A faint bobbin helps the winding read as an actual coil assembly.
bobbinRadius = max(p.projectile.radius*1.15, coil.innerRadius - 2*p.coil.wireRadius);
[Xb, Yb, Zb] = cylinder(bobbinRadius, 48);
Zb = (Zb - 0.5)*p.coil.length;
surf(Xb, Yb, Zb, ...
    "FaceColor", [0.82 0.84 0.86], ...
    "EdgeColor", "none", ...
    "FaceAlpha", 0.22, ...
    "HandleVisibility", "off");
end

function [X, Y, Z] = tubeAlongCurve(centerline, radius, sides)
%TUBEALONGCURVE Build a shaded tube around a 3D curve.
% For a solenoid, the natural local frame is radial/tangential to the coil
% axis. This avoids twisting artifacts and makes the winding look like wire.

x = centerline(:, 1);
y = centerline(:, 2);
z = centerline(:, 3);

radial = [x, y, zeros(size(z))];
radialNorm = vecnorm(radial, 2, 2);
radial(radialNorm > 0, :) = radial(radialNorm > 0, :)./radialNorm(radialNorm > 0);

fallback = radialNorm == 0;
radial(fallback, :) = repmat([1, 0, 0], nnz(fallback), 1);
axial = repmat([0, 0, 1], numel(x), 1);
tangentAroundCoil = cross(axial, radial, 2);

phi = linspace(0, 2*pi, sides + 1);
X = x + radius*(radial(:,1)*cos(phi) + tangentAroundCoil(:,1)*sin(phi));
Y = y + radius*(radial(:,2)*cos(phi) + tangentAroundCoil(:,2)*sin(phi));
Z = z + radius*(radial(:,3)*cos(phi) + tangentAroundCoil(:,3)*sin(phi));
end

function animateProjectile(results, p)
coil = results.coil;
motion = results.motion;

fig = figure("Name", "Animation - Projectile motion", "Color", "w", ...
    "NumberTitle", "off", ...
    "CloseRequestFcn", @closeAnimation);
drawCoilWinding(coil, p);
hold on;
camlight headlight;
lighting gouraud;
axis equal; grid on; box on;
xlabel("x [m]"); ylabel("y [m]"); zlabel("z [m]");
view(38, 22);
xyLimit = coil.outerRadius + 4*p.coil.wireRadius;
xlim([-xyLimit, xyLimit]);
ylim([-xyLimit, xyLimit]);
zlim([p.force.zMin, p.force.zMax]);
title("Coil Gun Simulation");

%% info = sprintf(["Turns: %d\nCurrent: %.0f A peak\nProjectile: %.0f g\n\\mu_r: %.0f"], ...
%%    p.coil.turns, p.electrical.I0, 1e3*p.projectile.mass, p.projectile.mu_r);
%%text(-0.028, -0.028, p.force.zMax*0.85, info, ...
%%    "FontName", "Consolas", ...
%%    "BackgroundColor", "w", ...
%%    "EdgeColor", [0.65 0.65 0.65], ...
%%    "Margin", 6);

drawProjectile(motion.z(1), p, [0.18 0.42 0.72], 0.85);
projectileSurfaces = findobj(gca, "Type", "Surface");
projectile = projectileSurfaces(1);

frameTimes = linspace(motion.t(1), motion.t(end), p.simulation.animationFrames);
zFrame = interp1(motion.t, motion.z, frameTimes, "pchip");
frameIndex = 1;
isPlaying = true;
speedMultiplier = 1.0;

playButton = uicontrol(fig, "Style", "pushbutton", ...
    "String", "Pause", ...
    "Units", "normalized", ...
    "Position", [0.38 0.02 0.10 0.05], ...
    "Callback", @togglePlay);
uicontrol(fig, "Style", "pushbutton", ...
    "String", "Restart", ...
    "Units", "normalized", ...
    "Position", [0.50 0.02 0.10 0.05], ...
    "Callback", @restartAnimation);
uicontrol(fig, "Style", "text", ...
    "String", "Speed", ...
    "Units", "normalized", ...
    "BackgroundColor", "w", ...
    "Position", [0.63 0.032 0.06 0.025]);
speedText = uicontrol(fig, "Style", "text", ...
    "String", "1.0x", ...
    "Units", "normalized", ...
    "BackgroundColor", "w", ...
    "Position", [0.86 0.032 0.06 0.025]);
uicontrol(fig, "Style", "slider", ...
    "Min", 0.25, ...
    "Max", 4.0, ...
    "Value", 1.0, ...
    "Units", "normalized", ...
    "Position", [0.69 0.025 0.16 0.04], ...
    "Callback", @changeSpeed);

drawFrame(frameIndex);
playLoop();

    function drawFrame(k)
        zCenter = zFrame(k);
        [Xc, Yc, Zc] = cylinder(p.projectile.radius, 36);
        Zc = (Zc - 0.5)*p.projectile.length + zCenter;
        set(projectile, "XData", Xc, "YData", Yc, "ZData", Zc);
        subtitle(sprintf("t = %.2f ms, z = %.1f mm, v = %.2f m/s", ...
            1e3*frameTimes(k), 1e3*zCenter, interp1(motion.t, motion.v, frameTimes(k), "pchip")));
    end

    function playLoop()
        while ishandle(fig) && isPlaying && frameIndex <= numel(frameTimes)
            drawFrame(frameIndex);
            frameIndex = frameIndex + 1;
            drawnow;

            if frameIndex > numel(frameTimes)
                isPlaying = false;
                set(playButton, "String", "Play");
                break;
            end

            pause(p.visualization.animationBaseDelay/speedMultiplier);
        end
    end

    function togglePlay(~, ~)
        isPlaying = ~isPlaying;
        if isPlaying
            if frameIndex > numel(frameTimes)
                frameIndex = 1;
            end
            set(playButton, "String", "Pause");
            playLoop();
        else
            set(playButton, "String", "Play");
        end
    end

    function restartAnimation(~, ~)
        frameIndex = 1;
        isPlaying = true;
        set(playButton, "String", "Pause");
        drawFrame(frameIndex);
        playLoop();
    end

    function changeSpeed(source, ~)
        speedMultiplier = source.Value;
        set(speedText, "String", sprintf("%.1fx", speedMultiplier));
    end

    function closeAnimation(~, ~)
        delete(fig);
    end
end
