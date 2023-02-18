!> author: Seyed Ali Ghasemi
program test

   use :: forclust

   implicit none

   type(cluster) :: my_pc

   call my_pc%select()
     call my_pc%node(1)%select()
     call my_pc%node(1)%set_debug('off')
       call my_pc%node(1)%cpu(:)%set_debug('on')
       call my_pc%node(1)%cpu(:)%get_cpuinfo_min_freq()

       call my_pc%node(1)%cpu(:)%set_debug('off')
       call my_pc%node(1)%cpu(:)%get_cpuinfo_min_freq()
   call my_pc%deselect()
   
end program test
