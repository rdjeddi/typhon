!------------------------------------------------------------------------------!
! Procedure : integration                 Auteur : J. Gressier
!                                         Date   : Juillet 2002
! Fonction                                Modif  : Mars 2003 (cf historique)
!   Integration des champs de chaque zone
!
! Defauts/Limitations/Divers :
!
!------------------------------------------------------------------------------!

subroutine integration(lworld)

use TYPHMAKE
use OUTPUT
use VARCOM
use MODWORLD

implicit none

! -- Declaration des entr�es/sorties --
type(st_world) :: lworld

! -- Declaration des entr�es --

! -- Declaration des sorties --

! -- Declaration des variables internes --
real(krp)      :: macro_dt
real(krp), dimension(:), allocatable &
               :: excht ! instants d'�change pour les diff�rents couplages de zones
integer        :: ir, izone
integer        :: iz1, iz2, ncoupl1, ncoupl2, nbc1, nbc2

! -- Debut de la procedure --

macro_dt        = lworld%prj%dtbase

! initialisation

lworld%info%icycle          = 0
lworld%info%curtps          = 0._krp
lworld%info%fin_integration = .false.


!if (lworld%prj%ncoupling > 0) then
  allocate(excht(lworld%prj%ncoupling))
  excht(:) = 0._krp
!endif


!-----------------------------------------------------------------------------------------------------------------------
! DVT : Ouverture du fichier de comparaison des flux � l'interface
!-----------------------------------------------------------------------------------------------------------------------
if (lworld%prj%ncoupling > 0) then
  open(unit = uf_compflux, file = "compflux.dat", form = 'formatted')
  write(uf_compflux, '(a)') 'VARIABLES="t","F1","F2", "ERREUR", "Fcalcule", "ERRCALC"'
endif
!-----------------------------------------------------------------------------------------------------------------------
do while (.not. lworld%info%fin_integration)

  lworld%info%icycle = lworld%info%icycle + 1
  write(str_w,'(a,i5,a,g10.4)') "* Cycle", lworld%info%icycle, &
                                " : t = ",  lworld%info%curtps
  call print_info(6,str_w)

  call integration_macrodt(macro_dt, lworld, excht, lworld%prj%ncoupling)  
    
  lworld%info%curtps = lworld%info%curtps + macro_dt

  if (lworld%info%curtps >= lworld%prj%duree) then
    lworld%info%fin_integration = .true.
  endif

enddo

! Mise � jour des conditions aux limites, notamment de couplage pour l'affichage des donn�es :
if (lworld%prj%ncoupling > 0) then
  do ir = 1, lworld%prj%ncoupling
      call calcul_raccord(lworld, ir, iz1, iz2, ncoupl1, ncoupl2, nbc1, nbc2)
      call echange_zonedata(lworld,ir, iz1, iz2, ncoupl1, ncoupl2, nbc1, nbc2) 
  enddo
endif

do izone = 1, lworld%prj%nzone
 call conditions_limites(lworld%zone(izone))
enddo

!-----------------------------------------------------------------------------------------------------------------------
! DVT : Fermeture du fichier de comparaison des flux � l'interface
!-----------------------------------------------------------------------------------------------------------------------
!if (lworld%prj%ncoupling > 0) then
  deallocate(excht)
  close(uf_compflux)
!endif
!-----------------------------------------------------------------------------------------------------------------------
endsubroutine integration

!------------------------------------------------------------------------------!
! Historique des modifications
!
! juil 2002 (v0.0.1b): cr�ation de la proc�dure
! juin 2003          : instant d'�change excht
!                      mise � jour des CL pour le fichier de sortie
!------------------------------------------------------------------------------!
