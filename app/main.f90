!> author: Seyed Ali Ghasemi
program test

   use :: forclust
   use :: m_cli2

   implicit none

   type(cluster) :: my_pc
   integer       :: brightness
   integer       :: node_num, cpu_num

   call set_mode('response_file')   
   call set_args('--actual-brightness --max-brightness --brightness 50 --node 1 --cpu 1 --base-freq')
   brightness = iget('brightness')
   node_num   = iget('node')
   cpu_num    = iget('cpu')


   call my_pc%select()

      if (specified('actual-brightness') .or. specified('max-brightness') .or. specified('brightness')) then
         call my_pc%backlight%select()
         call my_pc%backlight%set_debug('on')
         if (lget('actual-brightness')) call my_pc%backlight%get_actual_brightness()
         if (lget('max-brightness'))    call my_pc%backlight%get_max_brightness()
         if (specified('brightness'))   call my_pc%backlight%set_brightness(brightness)
      end if
      
         
      if (specified('base-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug('on')
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug('on')
         if (specified('base-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_base_freq()
      end if
      
   call my_pc%deselect()

end program test

