!------------------------------------------------------------------------------!
! Procedure : setboco_ns_outlet_sub       Auteur : J. Gressier
!                                         Date   : July 2004
! Fonction                                Modif  : (cf Historique)
!   Computation of supersonic inlet boundary conditions
!   
!------------------------------------------------------------------------------!
subroutine setboco_ns_outlet_sub(curtime, defns, unif, bc_ns, ustboco, umesh, fld)

use TYPHMAKE
use OUTPUT
use VARCOM
use MENU_BOCO
use USTMESH
use DEFFIELD 
use FCT_EVAL
use FCT_ENV

implicit none

! -- INPUTS --
real(krp)        :: curtime
type(mnu_ns)     :: defns            ! solver parameters
integer          :: unif             ! uniform or not
type(st_boco_ns) :: bc_ns            ! parameters (field or constant)
type(st_ustboco) :: ustboco          ! lieu d'application des conditions aux limites
type(st_ustmesh) :: umesh            ! maillage non structure

! -- OUTPUTS --
type(st_field)   :: fld              ! fld des etats

! -- Declaration des variables internes --
integer         :: ifb, if, ip, nf  ! index de liste, index de face limite et parametres
integer         :: icell, ighost    ! index de cellule interieure, et de cellule fictive
type(st_nsetat) :: nspri
real(krp), allocatable :: ps(:), pi(:), ti(:), mach(:)
type(v3d), allocatable :: dir(:)

! -- Body --

if (unif /= uniform) call erreur("Developpement","Condition non uniforme non implementee")

call new_fct_env(blank_env)      ! temporary environment from FCT_EVAL

nf = ustboco%nface
call new(nspri, nf)

do ifb = 1, nf
  if     = ustboco%iface(ifb)
  icell  = umesh%facecell%fils(if,1)
  nspri%density(ifb)  = fld%etatprim%tabscal(1)%scal(icell)
  nspri%pressure(ifb) = fld%etatprim%tabscal(2)%scal(icell)
  nspri%velocity(ifb) = fld%etatprim%tabvect(1)%vect(icell)
enddo

allocate(ps(nf))
allocate(pi(nf))
allocate(ti(nf))
allocate(mach(nf))
allocate(dir(nf))

call nspri2pi_ti_mach_dir(defns%properties(1), nf, nspri, pi, ti, mach, dir) 

call fct_env_set_real(blank_env, "t", curtime)

do ifb = 1, nf
  if   = ustboco%iface(ifb)
  call fct_env_set_real(blank_env, "x", umesh%mesh%iface(if,1,1)%centre%x)
  call fct_env_set_real(blank_env, "y", umesh%mesh%iface(if,1,1)%centre%y)
  call fct_env_set_real(blank_env, "z", umesh%mesh%iface(if,1,1)%centre%z)
  call fct_eval_real(blank_env, bc_ns%pstat, ps(ifb))
enddo

call pi_ti_ps_dir2nspri(defns%properties(1), nf, pi(1:nf), ti(1:nf), ps(1:nf), dir(1:nf), nspri) 

do ifb = 1, nf
  if     = ustboco%iface(ifb)
  ighost = umesh%facecell%fils(if,2)
  fld%etatprim%tabscal(1)%scal(ighost) = nspri%density(ifb)
  fld%etatprim%tabscal(2)%scal(ighost) = nspri%pressure(ifb)
  fld%etatprim%tabvect(1)%vect(ighost) = nspri%velocity(ifb)
enddo

call delete_fct_env(blank_env)      ! temporary environment from FCT_EVAL
call delete(nspri)
deallocate(ps, pi, ti, mach, dir)

endsubroutine setboco_ns_outlet_sub

!------------------------------------------------------------------------------!
! Changes history
!
! july 2004 : creation
! mar  2006 : array computation (optimization)
! June 2008 : FCT function for static pressure (function of X, Y, Z)
! Mar  2010 : time dependent conditions
!------------------------------------------------------------------------------!
