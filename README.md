![ForClust](media/logo.png)
============

I attempted several methods to decrease the noise from my laptop, but none of them worked. Later, I discovered that I can manually adjust the settings of the CPU and other components in Linux. As a result, I thought of creating a program in Fortran to enhance my control over my system. The goal of this project is to create a program in Fortran that can manage and control a Linux system.

-----
##  Table of Contents
- [](#)
  - [Table of Contents](#table-of-contents)
  - [Required Linux Commands](#required-linux-commands)
  - [Installation](#installation)
    - [fpm](#fpm)
  - [Set Procedures](#set-procedures)
    - [set-turbo on](#set-turbo-on)
    - [set-turbo off](#set-turbo-off)
    - [set-cpu-offline](#set-cpu-offline)
    - [set-cpu-online](#set-cpu-online)
    - [set-scaling-max-freq](#set-scaling-max-freq)
    - [set-scaling-min-freq](#set-scaling-min-freq)
    - [set-scaling-governor](#set-scaling-governor)
    - [set-energy\_performance performance](#set-energy_performance-performance)
  - [Get Procedures](#get-procedures)
    - [base-freq](#base-freq)
    - [cpuinfo-max-freq](#cpuinfo-max-freq)
    - [cpuinfo-min-freq](#cpuinfo-min-freq)
    - [energy-performance](#energy-performance)
    - [scaling-cur-freq](#scaling-cur-freq)
    - [scaling-governor](#scaling-governor)
    - [scaling-max-freq](#scaling-max-freq)
    - [scaling-min-freq](#scaling-min-freq)
    - [turbo](#turbo)
    - [is-cpu-online](#is-cpu-online)
    - [all-nodes-info](#all-nodes-info)
  - [API documentation](#api-documentation)
  - [Contributing](#contributing)
-----

## Required Linux Commands

ForClust requires the following Linux commands to be installed and available in the system path.
```
nproc, lscpu, grep, awk
```

-----
## Installation

### fpm
ForClust can be cloned and then built using [fpm](https://github.com/fortran-lang/fpm), following the instructions provided in the documentation available on Fortran Package Manager.

```bash
git clone https://github.com/gha3mi/forclust.git
cd forclust
fpm install --prefix .
```

Or you can easily include this package as a dependency in your `fpm.toml` file.

```toml
[dependencies]
forclust = {git="https://github.com/gha3mi/forclust.git"}
```

-----
## Set Procedures
- Exercise caution and refrain from making any adjustments to system settings unless you have a clear understanding of what you are doing.

- Sudo privilege is needed for 'set' procedures.

-----
### set-turbo on
```bash
sudo forclust --node 1 --set-turbo on
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%set_turbo('on')
call my_pc%deselect()
```
-----
### set-turbo off
```bash
sudo forclust --node 1 --set-turbo off
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%set_turbo('off')
call my_pc%deselect()
```
-----
### set-cpu-offline
```bash
sudo forclust --node 1 -cpu 2 --set-cpu-offline
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_offline()
call my_pc%deselect()
```
-----
### set-cpu-online
```bash
sudo forclust --node 1 -cpu 2 --set-cpu-online
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_online()
call my_pc%deselect()
```
-----
### set-scaling-max-freq
```bash
sudo forclust --node 1 -cpu 2 --set-scaling-max-freq 2400000
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_scaling_max_freq(2400000)
call my_pc%deselect()
```
-----
### set-scaling-min-freq
```bash
sudo forclust --node 1 -cpu 2 --set-scaling-min-freq 800000
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_scaling_min_freq(800000)
call my_pc%deselect()
```
-----
### set-scaling-governor
```bash
sudo forclust --node 1 -cpu 2 --set-scaling-governor powersave
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_scaling_governor(powersave)
call my_pc%deselect()
```
-----
### set-energy_performance performance
```bash
sudo forclust --node 1 -cpu 2 --set-energy_performance performance
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_energy_performance(performance)
call my_pc%deselect()
```
-----
## Get Procedures
-----
### base-freq
```bash
forclust --node 1 -cpu 2 --base-freq
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_base_freq()
call my_pc%deselect()
```
-----
### cpuinfo-max-freq
```bash
forclust --node 1 -cpu 2 --cpuinfo-max-freq
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_cpuinfo_max_freq()
call my_pc%deselect()
```
-----
### cpuinfo-min-freq
```bash
forclust --node 1 -cpu 2 --cpuinfo-min-freq
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_cpuinfo_min_freq()
call my_pc%deselect()
```
-----
### energy-performance
```bash
forclust --node 1 -cpu 2 energy-performance
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('off')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_energy_performance()
call my_pc%deselect()
```
-----
### scaling-cur-freq
```bash
forclust --node 1 -cpu 2 --scaling-cur-freq
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_scaling_cur_freq()
call my_pc%deselect()
```
-----
### scaling-governor
```bash
forclust --node 1 -cpu 2 --scaling-governor
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_scaling_governor()
call my_pc%deselect()
```
-----
### scaling-max-freq
```bash
forclust --node 1 -cpu 2 --scaling-max-freq
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_scaling_max_freq()
call my_pc%deselect()
```
-----
### scaling-min-freq
```bash
forclust --node 1 -cpu 2 --scaling-min-freq
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%get_scaling_min_freq()
call my_pc%deselect()
```
-----
### turbo
```bash
forclust --node 1 --turbo
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('on')
    call my_pc%node(1)%get_turbo()
call my_pc%deselect()
```
-----
### is-cpu-online
```bash
forclust --node 1 -cpu 2 --is-cpu-online
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
    call my_pc%node(1)%select()
    call my_pc%node(1)%set_debug('off')
    call my_pc%node(1)%cpu(2)%set_debug('on')
    call my_pc%node(1)%cpu(2)%is_online()
call my_pc%deselect()
```
-----
### all-nodes-info
```bash
forclust --all-nodes-info
```

```fortran
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
call my_pc%print_info()
call my_pc%deselect()
```

## API documentation
The most up-to-date API documentation for the master branch is available
[here](https://gha3mi.github.io/forclust/).
To generate the API documentation for the `ForClust` module using
[ford](https://github.com/Fortran-FOSS-Programmers/ford) run the following
command:

```shell
ford ford.yml
```

## Contributing
Contributions to `ForClust` are welcome! If you find any issues or would like to suggest improvements, please open an issue.
