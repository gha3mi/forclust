!> author: Seyed Ali Ghasemi
program test

   use :: forclust

   implicit none

   type(cluster) :: my_pc

   call my_pc%select()
     call my_pc%node(1)%select()
     call my_pc%node(1)%set_debug('off')
       call my_pc%node(1)%cpu(1)%set_debug('on')
       call my_pc%node(1)%cpu(1)%get_scaling_governor()

       call my_pc%node(1)%cpu(1)%set_debug('off')
       call my_pc%node(1)%cpu(1)%get_scaling_governor()
   call my_pc%deselect()
   
end program test
