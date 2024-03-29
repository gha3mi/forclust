!> author: Seyed Ali Ghasemi
module forclust

   implicit none

   private

   public :: cluster

   !===============================================================================
   type :: linux_backlight
      character(len=:), allocatable :: debug
      character(len=:), allocatable :: path_backlight
      integer                       :: actual_brightness
      integer                       :: brightness
      integer                       :: max_brightness
   contains
      procedure :: set_debug              => set_backlight_debug_switch
      procedure :: select                 => select_backlight
      procedure :: get_actual_brightness  => get_backlight_actual_brightness
      procedure :: get_max_brightness     => get_backlight_max_brightness
      procedure :: set_brightness         => set_backlight_brightness

      procedure :: deselect               => deallocate_linux_backlight
   end type linux_backlight
   !===============================================================================


   !===============================================================================
   type :: linux_cpu
      character(len=:), allocatable :: debug
      character(len=:), allocatable :: path_cpu
      integer                       :: online
      integer                       :: base_frequency
      integer                       :: cpuinfo_max_freq
      integer                       :: cpuinfo_min_freq
      integer                       :: scaling_cur_freq
      integer                       :: scaling_max_freq
      integer                       :: scaling_min_freq
      character(len=:), allocatable :: scaling_governor
      character(len=:), allocatable :: energy_performance_preference
   contains
      procedure :: set_debug              => set_cpu_debug_switch
      procedure :: is_online              => is_cpu_online
      procedure :: get_base_freq          => get_cpu_base_frequency
      procedure :: get_cpuinfo_max_freq   => get_cpuinfo_max_frequency
      procedure :: get_cpuinfo_min_freq   => get_cpuinfo_min_frequency
      procedure :: get_scaling_cur_freq   => get_cpu_scaling_cur_frequency
      procedure :: get_scaling_max_freq   => get_cpu_scaling_max_frequency
      procedure :: get_scaling_min_freq   => get_cpu_scaling_min_frequency
      procedure :: get_scaling_governor   => get_cpu_scaling_governor
      procedure :: get_energy_performance => get_cpu_energy_performance_preference
      procedure :: set_offline            => set_cpu_offline
      procedure :: set_online             => set_cpu_online
      procedure :: set_scaling_max_freq   => set_cpu_scaling_max_freq
      procedure :: set_scaling_min_freq   => set_cpu_scaling_min_freq
      procedure :: set_scaling_governor   => set_cpu_scaling_governor
      procedure :: set_energy_performance => set_cpu_energy_performance_preference

      procedure :: deselect               => deallocate_linux_cpu
   end type linux_cpu
   !===============================================================================


   !===============================================================================
   type :: linux_nodes
      character(len=:),               allocatable :: debug
      character(len=:),               allocatable :: path_node
      type(linux_cpu),  dimension(:), allocatable :: cpu
      integer                                     :: ncpus
      character(len=:),               allocatable :: turbo
      integer                                     :: is_intel_pstate
   contains
      procedure          :: set_debug                 => set_node_debug_switch
      procedure          :: select                    => select_node
      procedure, private :: find_number_of_cpus
      procedure, private :: is_intel_pstate_available
      procedure          :: get_turbo                 => get_intel_turbo
      procedure          :: set_turbo                 => set_intel_turbo

      procedure          :: deselect                  => deallocate_linux_nodes
   end type linux_nodes
   !===============================================================================


   !===============================================================================
   type :: cluster
      type(linux_nodes),  dimension(:), allocatable :: node
      integer                                       :: nnodes
      type(linux_backlight)                         :: backlight
   contains
      procedure          :: select => select_linux
      procedure, private :: find_number_of_nodes
      procedure          :: print_info            => print_all_cluster_info

      procedure          :: deselect              => deallocate_cluster
   end type cluster
   !===============================================================================


contains


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine find_number_of_nodes(this)
      use :: popen_module, only: get_command_as_string
      class(cluster), intent(inout) :: this
      character(len=:), allocatable :: nnodes_char

      nnodes_char = get_command_as_string("lscpu | grep 'NUMA node(s):' | awk '{print $3}'")
      read(nnodes_char,*) this%nnodes
   end subroutine find_number_of_nodes
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine select_linux(this)
      class(cluster), intent(inout) :: this
      character(len=100)            :: current_node_path
      character(len=100)            :: backlight_path
      integer                       :: i

      call this%find_number_of_nodes()
      if (.not. allocated(this%node)) allocate(this%node(this%nnodes))

      do concurrent (i = 1:this%nnodes)
         write (current_node_path, "(a,i0,a)") "/sys/devices/system/node/node",i-1,"/"
         this%node(i)%path_node=adjustl(trim(current_node_path))
      end do

      write (backlight_path, "(a,i0,a)") "/sys/class/backlight/intel_backlight"
      this%backlight%path_backlight=adjustl(trim(backlight_path))
   end subroutine select_linux
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine find_number_of_cpus(this)
      use :: popen_module, only: get_command_as_string
      class(linux_nodes), intent(inout) :: this
      character(len=:), allocatable     :: ncpu_char

      ncpu_char = get_command_as_string('nproc --all')
      read(ncpu_char,*) this%ncpus
   end subroutine find_number_of_cpus
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine select_node(this)
      class(linux_nodes), intent(inout) :: this
      character(len=100)                :: current_cpu_path
      integer                           :: nunit, stat, i
      integer                           :: temp
      character(len=100)                :: temp_char
      logical                           :: ex
      character(len=:), allocatable     :: file_name

      ! check if intel_pstate exists
      call this%is_intel_pstate_available()
      if (this%is_intel_pstate == 1) then
         ! read turbo
         open(newunit=nunit, file='/sys/devices/system/cpu/intel_pstate/no_turbo', iostat=stat)
         read(nunit, *) temp
         close(nunit)
         if (temp==1) this%turbo = 'off'
         if (temp==0) this%turbo = 'on'
      else
         this%turbo = 'off'
      end if

      call this%find_number_of_cpus()
      if (.not. allocated(this%cpu)) allocate(this%cpu(this%ncpus))

      do concurrent (i = 1:this%ncpus)
         ! path cpu
         write (current_cpu_path, "(a,a,i0)") adjustl(trim(this%path_node)),"cpu",i-1
         this%cpu(i)%path_cpu = adjustl(trim(current_cpu_path))

         ! read base frequency
         file_name = this%cpu(i)%path_cpu//"/cpufreq/base_frequency"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) this%cpu(i)%base_frequency
            close(nunit)
         else
            this%cpu(i)%base_frequency = 0
            ! error stop "file not found: "//file_name
         endif

         ! read cpuinfo max frequency
         file_name = this%cpu(i)%path_cpu//"/cpufreq/cpuinfo_max_freq"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) this%cpu(i)%cpuinfo_max_freq
            close(nunit)
         else
            this%cpu(i)%cpuinfo_max_freq = 0
            ! error stop "file not found: "//file_name
         endif
         
         ! read cpuinfo min frequency
         file_name = this%cpu(i)%path_cpu//"/cpufreq/cpuinfo_min_freq"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) this%cpu(i)%cpuinfo_min_freq
            close(nunit)
         else
            this%cpu(i)%cpuinfo_min_freq = 0
            ! error stop "file not found: "//file_name
         endif

         ! read scaling cur frequency
         file_name = this%cpu(i)%path_cpu//"/cpufreq/scaling_cur_freq"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) this%cpu(i)%scaling_cur_freq
            close(nunit)
         else
            this%cpu(i)%scaling_cur_freq = 0
            ! error stop "file not found: "//file_name
         endif

         ! read scaling max frequency
         file_name = this%cpu(i)%path_cpu//"/cpufreq/scaling_max_freq"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/scaling_max_freq", iostat=stat)
            read(nunit, *) this%cpu(i)%scaling_max_freq
            close(nunit)
         else
            this%cpu(i)%scaling_max_freq = 0
            ! error stop "file not found: "//file_name
         endif

         ! read scaling min frequency
         file_name = this%cpu(i)%path_cpu//"/cpufreq/scaling_min_freq"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) this%cpu(i)%scaling_min_freq
            close(nunit)
         else
            this%cpu(i)%scaling_min_freq = 0
            ! error stop "file not found: "//file_name
         endif

         ! read scaling governor
         file_name = this%cpu(i)%path_cpu//"/cpufreq/scaling_governor"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) temp_char
            this%cpu(i)%scaling_governor = adjustl(trim(temp_char))
            close(nunit)
         else
            this%cpu(i)%scaling_governor = "not found"
            ! error stop "file not found: "//file_name
         endif

         ! read energy performance preference
         file_name = this%cpu(i)%path_cpu//"/cpufreq/energy_performance_preference"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=file_name, iostat=stat)
            read(nunit, *) temp_char
            this%cpu(i)%energy_performance_preference = adjustl(trim(temp_char))
            close(nunit)
         else
            this%cpu(i)%energy_performance_preference = "not found"
            ! error stop "file not found: "//file_name
         endif
      end do

      ! read online
      this%cpu(1)%online = 1
      do concurrent (i = 2:this%ncpus)
         file_name = this%cpu(i)%path_cpu//"/online"
         inquire(file=file_name, exist=ex)
         if (ex) then
            open(newunit=nunit, file=this%cpu(i)%path_cpu//"/online", iostat=stat)
            read(nunit, *) this%cpu(i)%online
            close(nunit)
         else
            this%cpu(i)%online = 0
            ! error stop "file not found: "//file_name
         endif
      end do
   end subroutine select_node
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine is_cpu_online(this, online)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: online

      if (present(online)) online = this%online
      if (this%debug=='on') print'(a,i0)', 'online:                 ',this%online
   end subroutine is_cpu_online
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpu_base_frequency(this, base_frequency)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: base_frequency

      if (present(base_frequency)) base_frequency = this%base_frequency
      if (this%debug=='on') print'(a,i0)', 'base frequency:         ', this%base_frequency
   end subroutine get_cpu_base_frequency
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpuinfo_max_frequency(this, cpuinfo_max_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: cpuinfo_max_freq

      if (present(cpuinfo_max_freq)) cpuinfo_max_freq = this%cpuinfo_max_freq
      if (this%debug=='on') print'(a,i0)', 'cpuinfo max frequency:  ',this%cpuinfo_max_freq
   end subroutine get_cpuinfo_max_frequency
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpuinfo_min_frequency(this, cpuinfo_min_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: cpuinfo_min_freq

      if (present(cpuinfo_min_freq)) cpuinfo_min_freq = this%cpuinfo_min_freq
      if (this%debug=='on') print'(a,i0)', 'cpuinfo min frequency:  ',this%cpuinfo_min_freq
   end subroutine get_cpuinfo_min_frequency
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpu_scaling_cur_frequency(this, scaling_cur_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: scaling_cur_freq

      if (present(scaling_cur_freq)) scaling_cur_freq = this%scaling_cur_freq
      if (this%debug=='on') print'(a,i0)', 'scaling cur frequency:  ',this%scaling_cur_freq
   end subroutine get_cpu_scaling_cur_frequency
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpu_scaling_max_frequency(this, scaling_max_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: scaling_max_freq

      if (present(scaling_max_freq)) scaling_max_freq = this%scaling_max_freq
      if (this%debug=='on') print'(a,i0)', 'scaling max frequency:  ',this%scaling_max_freq
   end subroutine get_cpu_scaling_max_frequency
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpu_scaling_min_frequency(this, scaling_min_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: scaling_min_freq

      if (present(scaling_min_freq)) scaling_min_freq = this%scaling_min_freq
      if (this%debug=='on') print'(a,i0)', 'scaling min frequency:  ' ,this%scaling_min_freq
   end subroutine get_cpu_scaling_min_frequency
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpu_scaling_governor(this, scaling_governor)
      class(linux_cpu), intent(inout)         :: this
      character(len=*), intent(out), optional :: scaling_governor

      if (present(scaling_governor)) scaling_governor = this%scaling_governor
      if (this%debug=='on') print'(a,a)', 'scaling governor:       ' ,this%scaling_governor
   end subroutine get_cpu_scaling_governor
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_cpu_energy_performance_preference(this, energy_performance_preference)
      class(linux_cpu), intent(inout) :: this
      character(len=*), intent(out), optional    :: energy_performance_preference

      if (present(energy_performance_preference)) energy_performance_preference = this%energy_performance_preference
      if (this%debug=='on') print'(a,a)', 'energy perf preference: ' ,this%energy_performance_preference
   end subroutine get_cpu_energy_performance_preference
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_cpu_offline(this)
      class(linux_cpu), intent(inout) :: this
      integer                         :: nunit, stat
      logical                         :: ex
      character(len=:), allocatable   :: file_name

      this%online = 0

      file_name = this%path_cpu//"/online"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         write(nunit, '(i0)') this%online
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_cpu_offline
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_cpu_online(this)
      class(linux_cpu), intent(inout) :: this
      integer                         :: nunit, stat
      logical                         :: ex
      character(len=:), allocatable   :: file_name

      this%online = 1

      file_name = this%path_cpu//"/online"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         write(nunit, '(i0)') this%online
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_cpu_online
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_cpu_scaling_max_freq(this,max_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(in)             :: max_freq
      integer                         :: nunit, stat
      logical                         :: ex
      character(len=:), allocatable   :: file_name

      this%scaling_max_freq = max_freq

      file_name = this%path_cpu//"/cpufreq/scaling_max_freq"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         write(nunit, '(i0)') this%scaling_max_freq
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_cpu_scaling_max_freq
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_cpu_scaling_min_freq(this,min_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(in)             :: min_freq
      integer                         :: nunit, stat
      logical                         :: ex
      character(len=:), allocatable   :: file_name

      this%scaling_min_freq = min_freq

      file_name = this%path_cpu//"/cpufreq/scaling_min_freq"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         write(nunit, '(i0)') this%scaling_min_freq
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_cpu_scaling_min_freq
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_cpu_scaling_governor(this,scaling_governor)
      class(linux_cpu), intent(inout) :: this
      character(len=*), intent(in)    :: scaling_governor
      integer                         :: nunit, stat
      logical                         :: ex
      character(len=:), allocatable   :: file_name

      this%scaling_governor = scaling_governor

      file_name = this%path_cpu//"/cpufreq/scaling_governor"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=this%path_cpu//"/cpufreq/scaling_governor", iostat=stat)
         write(nunit, '(a)') this%scaling_governor
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_cpu_scaling_governor
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_cpu_energy_performance_preference(this,energy_performance_preference)
      class(linux_cpu), intent(inout) :: this
      character(len=*), intent(in)    :: energy_performance_preference
      integer                         :: nunit, stat
      logical                         :: ex
      character(len=:), allocatable   :: file_name

      this%energy_performance_preference = energy_performance_preference

      file_name = this%path_cpu//"/cpufreq/energy_performance_preference"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         write(nunit, '(a)') this%energy_performance_preference
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_cpu_energy_performance_preference
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine is_intel_pstate_available(this)
      ! bug: it does not depend on a node
      class(linux_nodes), intent(inout) :: this
      integer                           :: is_intel_pstate
      logical                           :: ex

      inquire(file='/sys/devices/system/cpu/intel_pstate', exist=ex)
      if (ex)       is_intel_pstate = 1
      if (.not. ex) is_intel_pstate = 0
      this%is_intel_pstate = is_intel_pstate
      ! if (this%debug=='on') print'(a,i0)', 'intel pstate avail:     ',this%is_intel_pstate
   end subroutine is_intel_pstate_available
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_intel_turbo(this,turbo)
      class(linux_nodes), intent(inout)         :: this
      character(len=*),   intent(out), optional :: turbo

      if (present(turbo)) turbo = this%turbo
      if (this%debug=='on') print'(a,a)', 'intel turbo:            ',this%turbo
   end subroutine get_intel_turbo
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_intel_turbo(this,turbo)
      ! bug: it does not depend on a node
      class(linux_nodes), intent(inout) :: this
      character(len=*),   intent(in)    :: turbo
      integer                           :: nunit, stat

      call this%is_intel_pstate_available()
      if (this%is_intel_pstate == 1) then

         this%turbo = turbo

         open(newunit=nunit, file='/sys/devices/system/cpu/intel_pstate/no_turbo', iostat=stat)
         if (turbo == 'on' ) write(nunit,'(i0)') 0
         if (turbo == 'off') write(nunit,'(i0)') 1
         close(nunit)
      end if
   end subroutine set_intel_turbo
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine set_cpu_debug_switch(this,debug)
      class(linux_cpu), intent(inout) :: this
      character(len=*),   intent(in)  :: debug

      this%debug = debug
   end subroutine set_cpu_debug_switch
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine set_node_debug_switch(this,debug)
      class(linux_nodes), intent(inout) :: this
      character(len=*),   intent(in)    :: debug

      this%debug = debug
   end subroutine set_node_debug_switch
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine print_all_cluster_info(this)
      class(cluster), intent(inout) :: this
      integer                       :: n, c

      do n = 1, this%nnodes; print'(a,i0)', 'NODE: ',n; print'(a)','=============================='
         call this%node(n)%select()
         call this%node(n)%set_debug('on')
         call this%node(n)%get_turbo()
         print'(a)','------------------------------'

         do c = 1, this%node(n)%ncpus
            print'(a,i0)', 'CPU: ',c
            call this%node(n)%cpu(c)%set_debug('on')
            call this%node(n)%cpu(c)%is_online()
            call this%node(n)%cpu(c)%get_base_freq()
            call this%node(n)%cpu(c)%get_cpuinfo_max_freq()
            call this%node(n)%cpu(c)%get_cpuinfo_min_freq()
            call this%node(n)%cpu(c)%get_scaling_cur_freq()
            call this%node(n)%cpu(c)%get_scaling_max_freq()
            call this%node(n)%cpu(c)%get_scaling_min_freq()
            call this%node(n)%cpu(c)%get_scaling_governor()
            call this%node(n)%cpu(c)%get_energy_performance()
            print'(a)','------------------------------'
         end do
      end do

   end subroutine print_all_cluster_info
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine select_backlight(this)
      class(linux_backlight), intent(inout) :: this
      integer                               :: nunit, stat
      logical                               :: ex
      character(len=:), allocatable         :: file_name

      ! read actual brightness
      file_name = this%path_backlight//"/actual_brightness"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         read(nunit, *) this%actual_brightness
         close(nunit)
      else
         this%actual_brightness = 0
         ! error stop "file not found: "//file_name
      endif

      ! read max brightness
      file_name = this%path_backlight//"/max_brightness"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         read(nunit, *) this%max_brightness
         close(nunit)
      else
         this%max_brightness = 0
         ! error stop "file not found: "//file_name
      endif

   end subroutine select_backlight
   !===============================================================================
   

   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine set_backlight_debug_switch(this,debug)
      class(linux_backlight), intent(inout) :: this
      character(len=*),       intent(in)    :: debug

      this%debug = debug
   end subroutine set_backlight_debug_switch
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_backlight_actual_brightness(this, actual_brightness)
      class(linux_backlight), intent(inout)          :: this
      integer,                intent(out),  optional :: actual_brightness

      if (present(actual_brightness)) actual_brightness = this%actual_brightness
      if (this%debug=='on') print'(a,i0)', 'actual brightness:         ', this%actual_brightness
   end subroutine get_backlight_actual_brightness
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine get_backlight_max_brightness(this, max_brightness)
      class(linux_backlight), intent(inout)          :: this
      integer,                intent(out),  optional :: max_brightness

      if (present(max_brightness)) max_brightness = this%max_brightness
      if (this%debug=='on') print'(a,i0)', 'max brightness:         ', this%max_brightness
   end subroutine get_backlight_max_brightness
   !===============================================================================

   
   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental impure subroutine set_backlight_brightness(this,brightness)
      class(linux_backlight), intent(inout) :: this
      integer,                intent(in)    :: brightness
      integer                               :: nunit, stat
      logical                               :: ex
      character(len=:), allocatable         :: file_name

      this%brightness = brightness

      file_name = this%path_backlight//"/brightness"
      inquire(file=file_name, exist=ex)
      if (ex) then
         open(newunit=nunit, file=file_name, iostat=stat)
         write(nunit, '(i0)') this%brightness
         close(nunit)
      else
         ! error stop "file not found: "//file_name
      endif
   end subroutine set_backlight_brightness
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine deallocate_linux_backlight(this)
      class(linux_backlight), intent(inout) :: this

      if (allocated(this%debug))          deallocate(this%debug)
      if (allocated(this%path_backlight)) deallocate(this%path_backlight)
   end subroutine deallocate_linux_backlight
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine deallocate_linux_cpu(this)
      class(linux_cpu), intent(inout) :: this

      if (allocated(this%debug))                         deallocate(this%debug)
      if (allocated(this%path_cpu))                      deallocate(this%path_cpu)
      if (allocated(this%scaling_governor))              deallocate(this%scaling_governor)
      if (allocated(this%energy_performance_preference)) deallocate(this%energy_performance_preference)
   end subroutine deallocate_linux_cpu
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine deallocate_linux_nodes(this)
      class(linux_nodes), intent(inout) :: this

      if (allocated(this%debug))     deallocate(this%debug)
      if (allocated(this%path_node)) deallocate(this%path_node)
      if (allocated(this%turbo))     deallocate(this%turbo)
      if (allocated(this%cpu))       call this%cpu(:)%deselect()
   end subroutine deallocate_linux_nodes
   !===============================================================================


   !===============================================================================
   !> author: Seyed Ali Ghasemi
   elemental pure subroutine deallocate_cluster(this)
      class(cluster), intent(inout) :: this

      if (allocated(this%node)) call this%node(:)%deselect()
      call this%backlight%deselect()
   end subroutine deallocate_cluster
   !===============================================================================

end module forclust
