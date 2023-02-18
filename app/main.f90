!> author: Seyed Ali Ghasemi
program test

   use :: forclust
   use :: m_cli2

   implicit none

   type(cluster)                 :: my_pc
   integer                       :: node_num, cpu_num, brightness, sc_max_freq, sc_min_freq
   character(len=:), allocatable :: sw_debug, sw_turbo, sc_governor, energy_perf

   call set_mode('response_file')   
   call set_args('&
   &--debug on &
   &--actual-brightness --max-brightness --brightness 50 &
   &--node 1 --cpu 1 &
   &--base-freq --cpuinfo-max-freq --cpuinfo-min-freq --energy-performance &
   &--scaling-cur-freq --scaling-governor --scaling-max-freq --scaling-min-freq &
   &--turbo --is-cpu-online --all-node-info &
   &--set-turbo on &
   &--set-cpu-offline &
   &--set-cpu-online &
   &--set-scaling-max-freq 2400000 &
   &--set-scaling-min-freq 800000 &
   &--set-scaling-governor powersave &
   &--set-energy_performance performance')
   brightness  = iget('brightness')
   node_num    = iget('node')
   cpu_num     = iget('cpu')
   sw_turbo    = sget('set-turbo')
   sc_max_freq = iget('set-scaling-max-freq')
   sc_min_freq = iget('set-scaling-min-freq')
   sc_governor = sget('set-scaling-governor')
   energy_perf = sget('set-energy_performance')
   sw_debug    = sget('debug')

   call my_pc%select()

      if (specified('actual-brightness') .or. specified('max-brightness') .or. specified('brightness')) then
         call my_pc%backlight%select()
         call my_pc%backlight%set_debug(sw_debug)
         if (lget('actual-brightness')) call my_pc%backlight%get_actual_brightness()
         if (lget('max-brightness'))    call my_pc%backlight%get_max_brightness()
         if (specified('brightness'))   call my_pc%backlight%set_brightness(brightness)
      end if
      
         
      if (specified('set-turbo') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-turbo')) call my_pc%node(node_num)%set_turbo(sw_turbo)
      end if

                  
      if (specified('set-cpu-offline') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-cpu-offline')) call my_pc%node(node_num)%cpu(cpu_num)%set_offline()
      end if


      if (specified('set-cpu-online') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-cpu-online')) call my_pc%node(node_num)%cpu(cpu_num)%set_online()
      end if


      if (specified('set-scaling-max-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-scaling-max-freq')) call my_pc%node(node_num)%cpu(cpu_num)%set_scaling_max_freq(sc_max_freq)
      end if


      if (specified('set-scaling-min-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-scaling-min-freq')) call my_pc%node(node_num)%cpu(cpu_num)%set_scaling_min_freq(sc_min_freq)
      end if


      if (specified('set-scaling-governor') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-scaling-governor')) call my_pc%node(node_num)%cpu(cpu_num)%set_scaling_governor(sc_governor)
      end if


      if (specified('set-energy-performance') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         if (specified('set-energy-performance')) call my_pc%node(node_num)%cpu(cpu_num)%set_energy_performance(energy_perf)
      end if

         
      if (specified('base-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('base-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_base_freq()
      end if
            
         
      if (specified('cpuinfo-max-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('cpuinfo-max-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_cpuinfo_max_freq()
      end if
                  
         
      if (specified('cpuinfo-min-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('cpuinfo-min-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_cpuinfo_min_freq()
      end if

                        
      if (specified('energy-performance') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('energy-performance')) call my_pc%node(node_num)%cpu(cpu_num)%get_energy_performance()
      end if

                        
      if (specified('scaling-cur-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('scaling-cur-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_scaling_cur_freq()
      end if

                        
      if (specified('scaling-governor') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('scaling-governor')) call my_pc%node(node_num)%cpu(cpu_num)%get_scaling_governor()
      end if

                        
      if (specified('scaling-max-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('scaling-max-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_scaling_max_freq()
      end if

                        
      if (specified('scaling-min-freq') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('scaling-min-freq')) call my_pc%node(node_num)%cpu(cpu_num)%get_scaling_min_freq()
      end if

                        
      if (specified('turbo') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('turbo')) call my_pc%node(node_num)%get_turbo()
      end if

                        
      if (specified('is-cpu-online') ) then
         call my_pc%node(node_num)%select()
         call my_pc%node(node_num)%set_debug(sw_debug)
         call my_pc%node(node_num)%cpu(cpu_num)%set_debug(sw_debug)
         if (specified('is-cpu-online')) call my_pc%node(node_num)%cpu(cpu_num)%is_online()
      end if

                        
      if (specified('all-node-info') ) then
         if (specified('all-node-info')) call my_pc%print_info()
      end if

   call my_pc%deselect()

end program test

