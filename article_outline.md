# Title Suggestion

Numerical Simulation of a Single-Stage Solenoid Coil Gun Using the Biot-Savart Law and Magnetic Energy Gradients

# Abstract Idea

This article presents a MATLAB-based numerical model of a single-stage solenoid coil gun for undergraduate electromagnetics education. A finite solenoid is discretized into circular current elements, and the magnetic flux density is computed from the Biot-Savart law. A simplified linear ferromagnetic projectile model relates magnetic energy to axial force through the spatial gradient of \(B^2\). The resulting force is coupled to Newton's second law and solved using `ode45`. Visualizations of coil geometry, three-dimensional magnetic fields, axial force, and projectile motion demonstrate how Maxwell-related field concepts connect to mechanical acceleration.

# 1. Introduction

Introduce electromagnetic launch systems as an applied example of field-matter interaction. Emphasize that the project is an academic simulation: the aim is to visualize magnetic fields, energy gradients, and dynamics rather than optimize a device.

Explain why a single-stage solenoid is a useful model system. It is geometrically simple, has a recognizable magnetic field pattern, and shows the central physical idea that a ferromagnetic body is attracted toward regions of stronger magnetic field.

# 2. Theoretical Background

## Maxwell Equations Relevance

The simulation is magnetoquasistatic: field propagation and radiation are neglected because the system is small and the pulse is slow compared with electromagnetic wave travel times. The relevant concepts are Ampere's law, magnetic flux density, and the relation between currents and magnetic fields.

## Biot-Savart Law

The solenoid field is computed by summing contributions from many small wire elements:

```text
dB = (mu0 I / 4 pi) (dl x r) / |r|^3
```

This directly connects current geometry to the magnetic field vector. The 3D plots demonstrate the direction and concentration of the magnetic field around a finite coil.

## Magnetic Energy

For a simplified linear magnetic projectile, the energy in an external field is approximated as:

```text
U = -(chi V / 2 mu0) B^2
```

The negative sign indicates that a material with positive magnetic susceptibility lowers its energy by moving toward stronger magnetic field.

## Magnetic Force

The axial force follows from the energy gradient:

```text
Fz = -dU/dz = (chi V / 2 mu0) d(B^2)/dz
```

The force is therefore not assumed as \(kI^2\). It arises from the spatial derivative of a Biot-Savart field magnitude.

## Newtonian Dynamics

Projectile motion is computed from:

```text
m d2z/dt2 = Fz(z,t)
```

Because \(B\) is proportional to current, the force varies with \(I(t)^2\) and with projectile position.

# 3. Numerical Method

The coil is represented as 500 circular turns. Each turn is divided into straight current elements, and each element contributes to the field through the Biot-Savart law.

The capacitor discharge is approximated by an underdamped RLC current:

```text
I(t) = I0 exp(-R t / 2L) cos(w t)
w = sqrt(1/(LC) - R^2/(4L^2))
```

The magnetic field is first computed per ampere along the coil axis. The axial derivative of \(B^2\) gives a force-per-current-squared table. During integration, the force is interpolated at the projectile position and multiplied by \(I(t)^2\).

The equation of motion is solved with MATLAB `ode45`, using projectile position and velocity as state variables.

# 4. Simulation Results

## Coil Geometry

The geometry figure shows the finite solenoid and the initial projectile location. It establishes the coordinate system and the physical scale of the model.

## 3D Magnetic Field Distribution

The field visualization shows that the magnetic field is concentrated inside the solenoid and curves around the coil externally. Vector arrows show the field direction, while magnitude slices show where the field is strongest.

## Axial Field and Force

The axial field plot shows the field magnitude increasing as the projectile approaches the solenoid center. The force plot shows attraction toward the high-field region. The force changes sign after the center, illustrating that a continuously energized coil can decelerate a projectile after it passes the midpoint.

## Projectile Dynamics

Position, velocity, and acceleration curves show the mechanical response to the pulsed magnetic force. Velocity increases while the projectile experiences forward acceleration. Acceleration decreases or reverses when the current weakens or when the projectile crosses into a region where the magnetic gradient points backward.

# 5. Discussion

Discuss how the simulation links electromagnetic field theory to motion. The key result is that force depends on the spatial gradient of magnetic energy, not merely on current magnitude.

Also discuss limitations. The projectile is modeled with constant permeability and no saturation. The model neglects hysteresis, eddy currents, projectile demagnetization, coil heating, switching electronics, and mechanical losses. These effects would be needed for engineering prediction but would obscure the core educational relationship between field gradients and force.

# 6. Conclusion

The MATLAB model provides a transparent numerical demonstration of a single-stage solenoid accelerator. By combining Biot-Savart field calculation, RLC current approximation, magnetic energy gradients, and Newtonian dynamics, the project creates a coherent foundation for an electromagnetics article and for classroom visualization of Maxwell-related concepts.
