!-----------------------------------------------------------------------------!
! Procedure : output_vtk_vect                   Auteur : J. Gressier
!                                               Date   : July 2004
! Function                                      Modif  : (cf historique)
!   Ecriture fichier des champs NON STRUCTURES de chaque zone au format VTK
!   Valeurs au centre des cellules / Ecriture de champs VECTORIELS
!
! Defauts/Limitations/Divers :
!
!------------------------------------------------------------------------------!

subroutine output_vtk_vect(uf, ust_mesh, name, vecfld)

use TYPHMAKE
use OUTPUT
use VARCOM
use GEO3D
use USTMESH
use DEFFIELD

implicit none

! -- Declaration des entrees --
integer           :: uf            ! unite d'ecriture
type(st_ustmesh)  :: ust_mesh      ! maillage a ecrire
type(st_vecfield) :: vecfld        ! champ de valeurs
character(len=*)  :: name          ! nom de la variable

! -- Declaration des sorties --

! -- Declaration des variables internes --
integer   :: i, ielem

! -- BODY --

write(uf,'(A)')    'VECTORS '//trim(name)//' double'

do ielem = 1, ust_mesh%cellvtex%ntype

  do i = 1, ust_mesh%cellvtex%elem(ielem)%nelem
    write(uf,'(:,1P,3E17.8E3)') vecfld%vect(ust_mesh%cellvtex%elem(ielem)%ielem(i))
  enddo

enddo

endsubroutine output_vtk_vect

!------------------------------------------------------------------------------!
! Changes history
!
! July 2004 : subroutine creation, from output_vtk_cell
!------------------------------------------------------------------------------!
