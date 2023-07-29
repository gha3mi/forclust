!> author: Seyed Ali Ghasemi
program test

   use :: forclust

   implicit none

   type(cluster) :: my_pc

   ! ============================================================================
   ! "Exercise caution and refrain from making any adjustments to system settings
   !  unless you have a clear understanding of what you are doing."
   !
   ! For 'set' functions, you need sudo privileges.
   ! ============================================================================

   call my_pc%select()
     call my_pc%node(1)%select()
     call my_pc%node(1)%set_debug('on')
    !  call my_pc%node(1)%set_turbo("on")
    !    call my_pc%node(1)%cpu(2)%set_debug('on')
    !    call my_pc%node(1)%cpu(2)%set_offline()
    !    call my_pc%node(1)%cpu(2)%set_online()
    !    call my_pc%node(1)%cpu(2)%set_scaling_max_freq(2400000)
    !    call my_pc%node(1)%cpu(2)%set_scaling_min_freq(800000)
    !    call my_pc%node(1)%cpu(2)%set_scaling_governor('powersave')
    !    call my_pc%node(1)%cpu(2)%set_energy_performance('performance')
   call my_pc%deselect()

end program test
