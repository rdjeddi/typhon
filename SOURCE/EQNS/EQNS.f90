!------------------------------------------------------------------------------!
! MODULE : EQNS                           Auteur : J. Gressier
!                                         Date   : Mai 2002
! Fonction                                Modif  : cf historique
!   Bibliotheque de procedures et fonctions pour la d�finition des �tats
!   dans les �quations de Navier-Stokes
!
! Defauts/Limitations/Divers :
!
!------------------------------------------------------------------------------!

module EQNS

use TYPHMAKE   ! Definition de la precision
use GEO3D      ! Compilation conditionnelle ? avec GEO3D_dp

! -- DECLARATIONS -----------------------------------------------------------

!------------------------------------------------------------------------------!
! D�finition de la structure ST_NSETAT : �tat physique
!------------------------------------------------------------------------------!
type st_nsetat
!  real(krp), dimension(:), pointer &
!                  :: density    ! masses volumiques partielles (nesp)
  real(krp)       :: density    ! masse volumique
  real(krp)       :: pressure   ! pression
  type(v3d)       :: velocity   ! vitesse
endtype st_nsetat

!------------------------------------------------------------------------------!
! D�finition de la structure ST_ESPECE : D�finition d'une esp�ce de gaz
!------------------------------------------------------------------------------!
type st_espece
  real(krp)    :: gamma         ! rapport de chaleurs sp�cifiques
  real(krp)    :: r_const       ! constante du gaz
  real(krp)    :: prandtl       ! nombre de Prandtl
  real(krp)    :: visc_dyn      ! viscosit� dynamique (faire �voluer en loi)
endtype st_espece

! -- INTERFACES -------------------------------------------------------------

!interface new
!  module procedure new_mesh, new_field, new_block, new_zone
!endinterface

!interface delete
!  module procedure delete_mesh, delete_field, delete_block, delete_zone
!endinterface


! -- Fonctions et Operateurs ------------------------------------------------


! -- IMPLEMENTATION ---------------------------------------------------------
contains

!------------------------------------------------------------------------------!
! Fonction : conversion de variables conservatives en variables primitives
!------------------------------------------------------------------------------!
!type(st_nsetat) function cons2nspri(fluid, etat)
!implicit none

! -- d�claration des entr�es
!type(st_espece)          :: fluid
!type(st_ :: etat

!  cons2kdif%density  = etat(1)
!  cons2kdif%pressure = etat(1)/defkdif%materiau%Cp
!  cons2kdif%density = etat(1)/defkdif%materiau%Cp
!  cons2kdif%density = etat(1)/defkdif%materiau%Cp

!endfunction cons2kdif

!------------------------------------------------------------------------------!
! Fonction : conversion de param�tres en variables primitives
!------------------------------------------------------------------------------!
type(st_nsetat) function pi_ti_mach_dir2nspri(fluid, pi, ti, mach, dir) result(nspri)
implicit none

! -- d�claration des entr�es
type(st_espece) :: fluid
type(v3d)       :: dir
real(krp)       :: pi, ti, mach
! -- internal variables 
real(krp)       :: g1, fm, ts, a

  g1 = fluid%gamma -1._krp
  fm = 1._krp / (1._krp + .5_krp*g1*mach**2)
  ts = ti *fm
  a  = sqrt(fluid%gamma*fluid%r_const*ts)
  nspri%pressure = pi *(fm**(fluid%gamma/g1))
  nspri%density  = nspri%pressure / (fluid%r_const * ts)
  nspri%velocity = (mach*a)*dir       ! product of scalars before

endfunction pi_ti_mach_dir2nspri


endmodule EQNS

!------------------------------------------------------------------------------!
! Modification history
!
! mai  2002 : cr�ation du module
! sept 2003 : adaptation du module pour premiers d�veloppements
! july 2004 : primitive variables calculation
!------------------------------------------------------------------------------!
