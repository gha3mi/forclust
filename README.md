<img title="ForClust" alt="ForClust" src="https://github.com/gha3mi/forclust/blob/main/media/logo.png">
I attempted several methods to decrease the noise from my laptop, but none of them worked. Later, I discovered that I can manually adjust the settings of the CPU and other components in Linux. As a result, I thought of creating a program in Fortran to enhance my control over my system. The goal of this project is to create a program in Fortran that can manage and control a Linux system.

## Example:
`test/test_print_info.f90`:

```
NODE: 1
==============================
intel turbo:            on
------------------------------
CPU: 1
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700886
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 2
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700238
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 3
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700603
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 4
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700011
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 5
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700499
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 6
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700464
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 7
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700126
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 8
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3699974
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 9
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700049
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 10
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3699974
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 11
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700061
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 12
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700167
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 13
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3699855
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 14
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3699872
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 15
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3700000
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
CPU: 16
online:                 1
base frequency:         2400000
cpuinfo max frequency:  5000000
cpuinfo min frequency:  800000
scaling cur frequency:  3699944
scaling max frequency:  5000000
scaling min frequency:  800000
scaling governor:       powersave
energy perf preference: balance_performance
------------------------------
```