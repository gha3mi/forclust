!> author: Seyed Ali Ghasemi
program test

   use :: forclust

   implicit none

   type(cluster) :: my_pc

   call my_pc%select()
     call my_pc%backlight%select()
       call my_pc%backlight%set_debug('on')
       call my_pc%backlight%get_actual_brightness()
       call my_pc%backlight%get_max_brightness()
    !    call my_pc%backlight%set_brightness(200)
   call my_pc%deselect()

end program test
