<img title="ForClust" alt="ForClust" src="https://github.com/gha3mi/forclust/blob/main/media/logo.png">
I attempted several methods to decrease the noise from my laptop, but none of them worked. Later, I discovered that I can manually adjust the settings of the CPU and other components in Linux. As a result, I thought of creating a program in Fortran to enhance my control over my system. The goal of this project is to create a program in Fortran that can manage and control a Linux system.

-----
## Set Procedures
- Exercise caution and refrain from making any adjustments to system settings unless you have a clear understanding of what you are doing.

- Sudo privilege is needed for 'set' procedures.

-----
### --set-turbo on
`sudo forclust --node 1 --set-turbo on`
```
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
### --set-turbo off
`sudo forclust --node 1 --set-turbo off`
```
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
### --set-cpu-offline
`sudo forclust --node 1 -cpu 2 --set-cpu-offline`
```
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
### --set-cpu-online
`sudo forclust --node 1 -cpu 2 --set-cpu-online`
```
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
### --set-scaling-max-freq
`sudo forclust --node 1 -cpu 2 --set-scaling-max-freq 2400000`
```
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
### --set-scaling-min-freq
`sudo forclust --node 1 -cpu 2 --set-scaling-min-freq 800000`
```
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
### --set-scaling-governor
`sudo forclust --node 1 -cpu 2 --set-scaling-governor powersave`
```
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
### --set-energy_performance performance
`sudo forclust --node 1 -cpu 2 --set-energy_performance performance`
```
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
### --base-freq
`forclust --node 1 -cpu 2 --base-freq`
```
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
### --cpuinfo-max-freq
`forclust --node 1 -cpu 2 --cpuinfo-max-freq`
```
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
### --cpuinfo-min-freq
`forclust --node 1 -cpu 2 --cpuinfo-min-freq`
```
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
### --energy-performance
`forclust --node 1 -cpu 2 energy-performance`
```
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
### --scaling-cur-freq
`forclust --node 1 -cpu 2 --scaling-cur-freq`
```
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
### --scaling-governor
`forclust --node 1 -cpu 2 --scaling-governor`
```
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
### --scaling-max-freq
`forclust --node 1 -cpu 2 --scaling-max-freq`
```
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
### --scaling-min-freq
`forclust --node 1 -cpu 2 --scaling-min-freq`
```
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
### --turbo
`forclust --node 1 -cpu 2 --turbo`
```
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
### --is-cpu-online
`forclust --node 1 -cpu 2 --is-cpu-online`
```
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
### --all-nodes-info
`forclust --all-nodes-info`
```
use :: forclust

implicit none

type(cluster) :: my_pc

call my_pc%select()
call my_pc%print_info()
call my_pc%deselect()
```