!------------------------------------------------------------------------------!
! Procedure : calc_ns_timestep   
!
! Fonction
!   Compute local time step for Euler/NS solver
!
!------------------------------------------------------------------------------!
subroutine calc_ns_timestep(cfl, fluid, umesh, field, dtloc, ncell)

use TYPHMAKE
use OUTPUT
use VARCOM
use MENU_NUM
use DEFFIELD
use USTMESH
use EQNS

implicit none

! -- INPUTS --
real(krp)         :: cfl           ! CFL number
type(st_espece)   :: fluid         ! donnees du fluide
type(st_ustmesh)  :: umesh         ! donnees geometriques
type(st_field)    :: field         ! donnees champs
integer           :: ncell         ! nombre de cellules internes (taille de dtloc)

! -- OUTPUTS --
real(krp), dimension(1:ncell) :: dtloc    ! tableau de pas de temps local

! -- Private DATA --
integer   :: if, ic
real(krp) :: gg1, a2, rv2, irho

! ------------------------------ BODY ------------------------------

! Euler timestep is 

! -- Calcul de somme S_i --
! pour faire la somme des surfaces des faces, on boucle d'abord sur les faces
! internes pour les contributions aux deux cellules voisines, puis on boucle
! sur les faces limites pour uniquement ajouter la contribution aux cellules 
! internes

! initialisation avant somme des faces

dtloc(1:ncell) = 0._krp

! somme des surfaces de faces internes sur chaque cellule (boucle sur faces)

do if = 1, umesh%nface_int
  ic  = umesh%facecell%fils(if,1)
  dtloc(ic) = dtloc(ic) + umesh%mesh%iface(if,1,1)%surface 
  ic  = umesh%facecell%fils(if,2)
  dtloc(ic) = dtloc(ic) + umesh%mesh%iface(if,1,1)%surface
enddo

! somme des surfaces de faces limites sur chaque cellule (boucle sur faces)

do if = umesh%nface_int+1, umesh%nface
  ic  = umesh%facecell%fils(if,1)
  dtloc(ic) = dtloc(ic) + umesh%mesh%iface(if,1,1)%surface
enddo

! -- Calcul de V / somme_i S_i et prise en compte du nombre de CFL --

!$OMP PARALLEL DO
do ic = 1, ncell
  dtloc(ic) =  cfl * 2._krp * umesh%mesh%volume(ic,1,1) / dtloc(ic)
enddo
!$OMP END PARALLEL DO

!!! OPTIM : try to vectorize !!!

gg1 = fluid%gamma*(fluid%gamma -1._krp)

!$OMP PARALLEL DO private(ic, rv2, irho, a2)
do ic = 1, ncell
  rv2  = sqrabs(field%etatcons%tabvect(1)%vect(ic))
  irho = 1._krp/field%etatcons%tabscal(1)%scal(ic)
  a2   = (field%etatcons%tabscal(2)%scal(ic)-.5_krp*rv2*irho)*gg1*irho
  if (.not.(a2 > 0._krp)) then  ! should get NaN as well
    write(str_w,'(a,e10.2,a,i8,a,3e10.2,a)') "negative or NaN internal energy (",a2,"m²/s²) <cell",ic,",",&
                                           umesh%mesh%centre(ic,1,1),">"
    call error_stop(trim(str_w))
  endif
  dtloc(ic) = dtloc(ic) / (sqrt(rv2)*irho+sqrt(a2))
enddo
!$OMP END PARALLEL DO

! dans le cas de pas de temps global, le pas de temps minimum est calcule et impose
! dans la routine appelante

endsubroutine calc_ns_timestep
!------------------------------------------------------------------------------!
! Changes history
!
! July 2004 : creation, calcul par CFL
! Aug  2005 : use direct CFL number (computed before)
!------------------------------------------------------------------------------!

