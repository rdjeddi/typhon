!------------------------------------------------------------------------------!
! Procedure : calcboco_ust                Auteur : J. Gressier
!                                         Date   : Avril 2003
! Fonction                                Modif  : (cf Historique)
!   Calcul des conditions aux limites pour maillage non structur�
!   Aiguillage des appels selon le type (g�n�ral ou par solveur)
!
! Defauts/Limitations/Divers :
!
!------------------------------------------------------------------------------!
subroutine calcboco_ust(defsolver, grid)

use TYPHMAKE
use OUTPUT
use VARCOM
use MENU_SOLVER
use USTMESH
use DEFFIELD
!use MENU_ZONECOUPLING
use DEFZONE

implicit none

! -- Declaration des entr�es --
type(mnu_solver)       :: defsolver        ! type d'�quation � r�soudre

! -- Declaration des entr�e/sorties --
type(st_grid)          :: grid             ! maillage en entr�e, champ en sortie

! -- Declaration des variables internes --
integer :: ib, ir                    ! index de conditions aux limites et de couplage
integer :: idef                      ! index de definitions des conditions aux limites
integer :: nrac                      ! num�ro de raccord

! -- Debut de la procedure --

do ib = 1, grid%umesh%nboco

  idef = grid%umesh%boco(ib)%idefboco

  ! Traitement des conditions aux limites communes aux solveurs

  select case(defsolver%boco(idef)%typ_boco)

  case(bc_geo_sym)
    call calcboco_ust_sym(defsolver%boco(idef), grid%umesh%boco(ib), grid%umesh, grid%field)
    !call erreur("D�veloppement","'bc_geo_sym' : Cas non impl�ment�")
    
  case(bc_geo_period)
    call erreur("D�veloppement","'bc_geo_period' : Cas non impl�ment�")
    
  case(bc_geo_extrapol)
    call calcboco_ust_extrapol(defsolver%boco(idef), grid%umesh%boco(ib), grid%umesh, grid%field)

! PROVISOIRE : � retirer
  case(bc_connection)
    call erreur("D�veloppement","'bc_connection' : Cas non impl�ment�")

  case default 

    select case(defsolver%typ_solver)
      case(solNS)
        call calcboco_ns(defsolver, defsolver%boco(idef), grid%umesh%boco(ib), grid)
      case(solKDIF)
        call calcboco_kdif(defsolver, defsolver%boco(idef), grid%umesh%boco(ib), grid)
      case(solVORTEX)
        ! rien � faire
      case default
         call erreur("incoh�rence interne (def_boco)","solveur inconnu")
    endselect

  endselect

enddo


endsubroutine calcboco_ust

!------------------------------------------------------------------------------!
! Historique des modifications
!
! avril 2003 : cr�ation de la proc�dure
! july  2004 : simplification of call tree (uniform or not boundary conditions)
!------------------------------------------------------------------------------!
