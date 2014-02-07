!------------------------------------------------------------------------------!
! PROGRAM : TYPHON                              Authors : J. Gressier (admin)
!                                               see http://typhon.sf.net
!                                               Created : July 2002
! 
! Plateforme de resolution de systemes d'equations 
! par discretisation Volumes Finis / Singularites
!   
! Historique des versions (cf fichier VERSIONS)
!
!------------------------------------------------------------------------------!
 
program main

use TYPHMAKE    ! default accuracy
use VARCOM      ! common variables and types
use OUTPUT      ! definition des procedures et unites pour les sorties
use TIMER
use MODWORLD    ! global data & structure for the computation
use MENU_GEN    ! general parameters for the project

implicit none

#ifdef MPICOMPIL
include 'mpif.h'
#endif /*MPICOMPIL*/

! -- Variables locales --

type(st_world) :: loc_world      ! structure encapsulant toutes les donnees TYPHON
integer        :: itimer_init, itimer_tot

type(st_info)  :: winfo

integer        :: ierr

character(len=6), parameter :: version = "0.5.0"

include 'svnrev.h'

! -- BODY --

#ifdef MPICOMPIL
! call init_exch_protocol(loc_world%info)
winfo = loc_world%info
call print_info(5,"init MPI exchanges")

call MPI_Init(ierr)
call MPI_Comm_rank(MPI_COMM_WORLD, myprocid,     ierr)
call MPI_Comm_size(MPI_COMM_WORLD, winfo%nbproc, ierr)

myprocid = myprocid+1    ! mpi_comm_rank starts from 0

print*,'I am ',myprocid,'among',winfo%nbproc,' procs'

tympi_real = MPI_REAL8
tympi_int  = MPI_INTEGER4

mpi_run  = .true.
#else  /*NO MPICOMPIL*/
winfo = loc_world%info
winfo%nbproc = 1
myprocid     = 0

mpi_run = .false.
#endif /*MPICOMPIL*/

call init_output()

!###### ENTETE

call print_info(0,"")
call print_info(0,"******************************************************")
call print_info(0,"TYPHON V "//trim(version)//" ("//trim(svnrev)//")")
call print_info(0,"******************************************************")

itimer_tot  = realtime_start()
itimer_init = realtime_start()

call init_varcom()
if (omp_run) call print_info(0, "Open-MP computation "//trim(strof(nthread))//" threads")

!###### PARAMETERS PARSING 

call def_param(loc_world)

!###### MPI STRATEGY: distribute procs

if (mpi_run) then
  call print_etape("> MPI STRATEGY: preprocessing")
  call mpi_strategy_pre(loc_world)
endif

!###### MESH READING AND DATA STRUCTURE DEFINITION

call print_etape("> INPUTS : mesh and boundary conditions")
call readallmesh(loc_world)

!###### INITIALISATION

call print_etape("> INITIALIZATION")
call init_world(loc_world)

!###### MPI STRATEGY: distribute procs

if (mpi_run) then
  call print_etape("> MPI STRATEGY: postprocessing")
  call mpi_strategy_post(loc_world)
endif

write(str_w, "(a,e13.4)") "> user initialization time: ", realtime_stop(itimer_init)
call print_info(10, str_w)

!###### INTEGRATION ET RESOLUTION

select case(loc_world%prj%action)
case(act_compute, act_restart)
  call print_etape("> INTEGRATION")
  call integration(loc_world)
case(act_analyze)
  call print_etape("> ANALYSIS & REPORT")
  call analyse(loc_world)
case default
  call error_stop("Development: Unexpected ACTION parameter: "//trim(strof(loc_world%prj%action)))
endselect

!###### FIN D'EXECUTION

call output_result(loc_world, end_calc) 

call delete(loc_world)

!###### Desallocation

call print_etape("> End of process")
write(str_w, "(a,e13.4)") "> total user time: ", realtime_stop(itimer_tot)

#ifdef MPICOMPIL
! call finalize_exch(loc_world%info)
call print_info(5,"finalize MPI exchanges")
call MPI_Finalize(ierr)
#endif /*MPICOMPIL*/

!#########
endprogram

!------------------------------------------------------------------------------!
! Change history
!
! july  2002 : creation
! may   2005 : add switch option to "analyse" instead of "integration"
!------------------------------------------------------------------------------!
