module forclust

   implicit none

   private

   public :: cluster

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
      procedure, private :: find_number_of_cpus ! todo:
      procedure, private :: is_intel_pstate_available
      procedure          :: get_turbo                 => get_intel_turbo
      procedure          :: set_turbo                 => set_intel_turbo
   end type linux_nodes
   !===============================================================================


   !===============================================================================
   type :: cluster
      type(linux_nodes),  dimension(:), allocatable :: node
      integer                                       :: nnodes
   contains
      procedure          :: select => select_linux
      procedure, private :: find_number_of_nodes ! todo:
      procedure          :: print_info            => print_all_cluster_info
   end type cluster
   !===============================================================================


contains


   !===============================================================================
   subroutine find_number_of_nodes(this)
      class(cluster), intent(inout) :: this

      ! todo: get total number of linux nodes
      this%nnodes = 1
   end subroutine find_number_of_nodes
   !===============================================================================


   !===============================================================================
   subroutine select_linux(this)
      class(cluster), intent(inout) :: this
      character(len=100)            :: current_node_path
      integer                       :: i

      call this%find_number_of_nodes()
      if (.not. allocated(this%node)) allocate(this%node(this%nnodes))

      do concurrent (i = 1:this%nnodes)
         write (current_node_path, "(a,i0,a)") "/sys/devices/system/node/node",i-1,"/"
         this%node(i)%path_node=adjustl(trim(current_node_path))
      end do
   end subroutine select_linux
   !===============================================================================


   !===============================================================================
   subroutine find_number_of_cpus(this)
      class(linux_nodes), intent(inout) :: this
      INTEGER                           :: nunit

      ! todo: get total number of linux nodes
      call execute_command_line ("echo $(nproc --all) > forclust.tmp")
      open(newunit=nunit, file='forclust.tmp', action='read')
      read(nunit, *) this%ncpus
      close(nunit)
   end subroutine find_number_of_cpus
   !===============================================================================


   !===============================================================================
   subroutine select_node(this)
      class(linux_nodes), intent(inout) :: this
      character(len=100)                :: current_cpu_path
      integer                           :: nunit, stat, i
      integer                           :: temp
      character(len=100)                :: temp_char

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
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/base_frequency", iostat=stat)
         read(nunit, *) this%cpu(i)%base_frequency
         close(nunit)

         ! read cpuinfo max frequency
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/cpuinfo_max_freq", iostat=stat)
         read(nunit, *) this%cpu(i)%cpuinfo_max_freq
         close(nunit)

         ! read cpuinfo min frequency
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/cpuinfo_min_freq", iostat=stat)
         read(nunit, *) this%cpu(i)%cpuinfo_min_freq
         close(nunit)

         ! read scaling cur frequency
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/scaling_cur_freq", iostat=stat)
         read(nunit, *) this%cpu(i)%scaling_cur_freq
         close(nunit)

         ! read scaling max frequency
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/scaling_max_freq", iostat=stat)
         read(nunit, *) this%cpu(i)%scaling_max_freq
         close(nunit)

         ! read scaling min frequency
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/scaling_min_freq", iostat=stat)
         read(nunit, *) this%cpu(i)%scaling_min_freq
         close(nunit)

         ! read scaling governor
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/scaling_governor", iostat=stat)
         read(nunit, *) temp_char
         this%cpu(i)%scaling_governor = adjustl(trim(temp_char))
         close(nunit)

         ! read energy performance preference
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/cpufreq/energy_performance_preference", iostat=stat)
         read(nunit, *) temp_char
         this%cpu(i)%energy_performance_preference = adjustl(trim(temp_char))
         close(nunit)
      end do

      ! read online
      this%cpu(1)%online = 1
      do concurrent (i = 2:this%ncpus)
         open(newunit=nunit, file=this%cpu(i)%path_cpu//"/online", iostat=stat)
         read(nunit, *) this%cpu(i)%online
         close(nunit)
      end do
   end subroutine select_node
   !===============================================================================


   !===============================================================================
   subroutine is_cpu_online(this, online)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: online

      if (present(online)) online = this%online
      if (this%debug=='on') print'(a,i0)', 'online:                 ',this%online
   end subroutine is_cpu_online
   !===============================================================================


   !===============================================================================
   subroutine get_cpu_base_frequency(this, base_frequency)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: base_frequency

      if (present(base_frequency)) base_frequency = this%base_frequency
      if (this%debug=='on') print'(a,i0)', 'base frequency:         ', this%base_frequency
   end subroutine get_cpu_base_frequency
   !===============================================================================


   !===============================================================================
   subroutine get_cpuinfo_max_frequency(this, cpuinfo_max_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: cpuinfo_max_freq

      if (present(cpuinfo_max_freq)) cpuinfo_max_freq = this%cpuinfo_max_freq
      if (this%debug=='on') print'(a,i0)', 'cpuinfo max frequency:  ',this%cpuinfo_max_freq
   end subroutine get_cpuinfo_max_frequency
   !===============================================================================


   !===============================================================================
   subroutine get_cpuinfo_min_frequency(this, cpuinfo_min_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: cpuinfo_min_freq

      if (present(cpuinfo_min_freq)) cpuinfo_min_freq = this%cpuinfo_min_freq
      if (this%debug=='on') print'(a,i0)', 'cpuinfo min frequency:  ',this%cpuinfo_min_freq
   end subroutine get_cpuinfo_min_frequency
   !===============================================================================


   !===============================================================================
   subroutine get_cpu_scaling_cur_frequency(this, scaling_cur_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: scaling_cur_freq

      if (present(scaling_cur_freq)) scaling_cur_freq = this%scaling_cur_freq
      if (this%debug=='on') print'(a,i0)', 'scaling cur frequency:  ',this%scaling_cur_freq
   end subroutine get_cpu_scaling_cur_frequency
   !===============================================================================


   !===============================================================================
   subroutine get_cpu_scaling_max_frequency(this, scaling_max_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: scaling_max_freq

      if (present(scaling_max_freq)) scaling_max_freq = this%scaling_max_freq
      if (this%debug=='on') print'(a,i0)', 'scaling max frequency:  ',this%scaling_max_freq
   end subroutine get_cpu_scaling_max_frequency
   !===============================================================================


   !===============================================================================
   subroutine get_cpu_scaling_min_frequency(this, scaling_min_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(out), optional  :: scaling_min_freq

      if (present(scaling_min_freq)) scaling_min_freq = this%scaling_min_freq
      if (this%debug=='on') print'(a,i0)', 'scaling min frequency:  ' ,this%scaling_min_freq
   end subroutine get_cpu_scaling_min_frequency
   !===============================================================================


   !===============================================================================
   subroutine get_cpu_scaling_governor(this, scaling_governor)
      class(linux_cpu), intent(inout)         :: this
      character(len=*), intent(out), optional :: scaling_governor

      if (present(scaling_governor)) scaling_governor = this%scaling_governor
      if (this%debug=='on') print'(a,a)', 'scaling governor:       ' ,this%scaling_governor
   end subroutine get_cpu_scaling_governor
   !===============================================================================


   !===============================================================================
   subroutine get_cpu_energy_performance_preference(this, energy_performance_preference)
      class(linux_cpu), intent(inout) :: this
      character(len=*), intent(out), optional    :: energy_performance_preference

      if (present(energy_performance_preference)) energy_performance_preference = this%energy_performance_preference
      if (this%debug=='on') print'(a,a)', 'energy perf preference: ' ,this%energy_performance_preference
   end subroutine get_cpu_energy_performance_preference
   !===============================================================================


   !===============================================================================
   subroutine set_cpu_offline(this)
      class(linux_cpu), intent(inout) :: this
      integer                         :: nunit, stat

      this%online = 0

      open(newunit=nunit, file=this%path_cpu//"/online", iostat=stat)
      write(nunit, '(i0)') this%online
      close(nunit)
   end subroutine set_cpu_offline
   !===============================================================================


   !===============================================================================
   subroutine set_cpu_online(this)
      class(linux_cpu), intent(inout) :: this
      integer                         :: nunit, stat

      this%online = 1

      open(newunit=nunit, file=this%path_cpu//"/online", iostat=stat)
      write(nunit, '(i0)') this%online
      close(nunit)
   end subroutine set_cpu_online
   !===============================================================================


   !===============================================================================
   subroutine set_cpu_scaling_max_freq(this,max_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(in)             :: max_freq
      integer                         :: nunit, stat

      this%scaling_max_freq = max_freq

      open(newunit=nunit, file=this%path_cpu//"/cpufreq/scaling_max_freq", iostat=stat)
      write(nunit, '(i0)') this%scaling_max_freq
      close(nunit)
   end subroutine set_cpu_scaling_max_freq
   !===============================================================================


   !===============================================================================
   subroutine set_cpu_scaling_min_freq(this,min_freq)
      class(linux_cpu), intent(inout) :: this
      integer, intent(in)             :: min_freq
      integer                         :: nunit, stat

      this%scaling_min_freq = min_freq

      open(newunit=nunit, file=this%path_cpu//"/cpufreq/scaling_min_freq", iostat=stat)
      write(nunit, '(i0)') this%scaling_min_freq
      close(nunit)
   end subroutine set_cpu_scaling_min_freq
   !===============================================================================


   !===============================================================================
   subroutine set_cpu_scaling_governor(this,scaling_governor)
      class(linux_cpu), intent(inout) :: this
      character(len=*), intent(in)    :: scaling_governor
      integer                         :: nunit, stat

      this%scaling_governor = scaling_governor

      open(newunit=nunit, file=this%path_cpu//"/cpufreq/scaling_governor", iostat=stat)
      write(nunit, '(a)') this%scaling_governor
      close(nunit)
   end subroutine set_cpu_scaling_governor
   !===============================================================================


   !===============================================================================
   subroutine set_cpu_energy_performance_preference(this,energy_performance_preference)
      class(linux_cpu), intent(inout) :: this
      character(len=*), intent(in)    :: energy_performance_preference
      integer                         :: nunit, stat

      this%energy_performance_preference = energy_performance_preference

      open(newunit=nunit, file=this%path_cpu//"/cpufreq/energy_performance_preference", iostat=stat)
      write(nunit, '(a)') this%energy_performance_preference
      close(nunit)
   end subroutine set_cpu_energy_performance_preference
   !===============================================================================


   !===============================================================================
   subroutine is_intel_pstate_available(this)
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
   subroutine get_intel_turbo(this,turbo)
      class(linux_nodes), intent(inout)         :: this
      character(len=*),   intent(out), optional :: turbo

      if (present(turbo)) turbo = this%turbo
      if (this%debug=='on') print'(a,a)', 'intel turbo:            ',this%turbo
   end subroutine get_intel_turbo
   !===============================================================================


   !===============================================================================
   subroutine set_intel_turbo(this,turbo)
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
   subroutine set_cpu_debug_switch(this,debug)
      class(linux_cpu), intent(inout) :: this
      character(len=*),   intent(in)  :: debug

      this%debug = debug
   end subroutine set_cpu_debug_switch
   !===============================================================================


   !===============================================================================
   subroutine set_node_debug_switch(this,debug)
      class(linux_nodes), intent(inout) :: this
      character(len=*),   intent(in)    :: debug

      this%debug = debug
   end subroutine set_node_debug_switch
   !===============================================================================


   !===============================================================================
   subroutine print_all_cluster_info(this)
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

end module forclust
