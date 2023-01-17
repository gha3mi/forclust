!> author: Seyed Ali Ghasemi
program test

   use :: forclust

   implicit none

   type(cluster) :: my_pc

   call my_pc%select()
     call my_pc%node(1)%select()
     call my_pc%node(1)%set_debug('on')
     call my_pc%node(1)%get_turbo()
       call my_pc%node(1)%cpu(2)%set_debug('on')
       call my_pc%node(1)%cpu(2)%is_online()
       call my_pc%node(1)%cpu(2)%get_base_freq()
       call my_pc%node(1)%cpu(2)%get_cpuinfo_max_freq()
       call my_pc%node(1)%cpu(2)%get_cpuinfo_min_freq()
       call my_pc%node(1)%cpu(2)%get_scaling_cur_freq()
       call my_pc%node(1)%cpu(2)%get_scaling_max_freq()
       call my_pc%node(1)%cpu(2)%get_scaling_min_freq()
       call my_pc%node(1)%cpu(2)%get_scaling_governor()
       call my_pc%node(1)%cpu(2)%get_energy_performance()

end program test
