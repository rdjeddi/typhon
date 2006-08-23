!-----------------------------------------------------------------------------!
! Procedure : output_vtkbin_cell             Auteur : J. Gressier
!                                            Date   : April 2006
! Fonction
!   Ecriture fichier des champs NON STRUCTURES de chaque zone au format VTK
!   Valeurs au centre des cellules
!
! Defauts/Limitations/Divers :
!
!------------------------------------------------------------------------------!

subroutine output_vtkbin_cell(uf, defsolver, ust_mesh, field)

use TYPHMAKE
use OUTPUT
use VARCOM
use GEO3D
use MENU_SOLVER
use USTMESH
use DEFFIELD

implicit none

! -- INPUTS --
integer         , intent(in) :: uf            ! unite d'ecriture
type(mnu_solver), intent(in) :: defsolver     ! parametres du solveur
type(st_ustmesh), intent(in) :: ust_mesh      ! maillage a ecrire
type(st_field),   intent(in) :: field         ! champ de valeurs

! -- OUTPUTS --

! -- Internal variables --
integer   :: i, ncellint
integer   :: info, ntot
type(v3d) :: vtex

! -- BODY --


! ecriture du maillage

call writestr(uf, 'DATASET UNSTRUCTURED_GRID')
write(str_w, '(a,i9,a)') 'POINTS ',ust_mesh%nvtex, ' float'
call writestr(uf, trim(str_w))

! coordonnees

do i = 1, ust_mesh%nvtex
  vtex = ust_mesh%mesh%vertex(i,1,1)
  write(uf) real(vtex%x, kind=4), real(vtex%y, kind=4), real(vtex%z, kind=4)
enddo

! connectivite 

ncellint       = ust_mesh%cellvtex%nbar   + &
                 ust_mesh%cellvtex%ntri   + ust_mesh%cellvtex%nquad + &
                 ust_mesh%cellvtex%ntetra + ust_mesh%cellvtex%npyra + &
                 ust_mesh%cellvtex%npenta + ust_mesh%cellvtex%nhexa

ntot =        3*ust_mesh%cellvtex%nbar
ntot = ntot + 4*ust_mesh%cellvtex%ntri
ntot = ntot + 5*ust_mesh%cellvtex%nquad
ntot = ntot + 5*ust_mesh%cellvtex%ntetra
ntot = ntot + 6*ust_mesh%cellvtex%npyra
ntot = ntot + 7*ust_mesh%cellvtex%npenta
ntot = ntot + 9*ust_mesh%cellvtex%nhexa

call writereturn(uf)
write(str_w, '(a,2i10)') 'CELLS ', ncellint, ntot
call writestr(uf, trim(str_w))

do i = 1, ust_mesh%cellvtex%nbar
  write(uf) 2, ust_mesh%cellvtex%bar%fils(i,:)-1
enddo
do i = 1, ust_mesh%cellvtex%ntri
  write(uf) 3, ust_mesh%cellvtex%tri%fils(i,:)-1
enddo
do i = 1, ust_mesh%cellvtex%nquad
  write(uf) 4, ust_mesh%cellvtex%quad%fils(i,:)-1
enddo
do i = 1, ust_mesh%cellvtex%ntetra
  write(uf) 4, ust_mesh%cellvtex%tetra%fils(i,:)-1
enddo
do i = 1, ust_mesh%cellvtex%npyra
  write(uf) 5, ust_mesh%cellvtex%pyra%fils(i,:)-1
enddo
do i = 1, ust_mesh%cellvtex%npenta
  write(uf) 6, ust_mesh%cellvtex%penta%fils(i,:)-1
enddo
do i = 1, ust_mesh%cellvtex%nhexa
  write(uf) 8, ust_mesh%cellvtex%hexa%fils(i,:)-1
enddo

! type de cellules

call writereturn(uf)
write(str_w, '(a,i9,a)') 'CELL_TYPES ', ncellint, ' int'
call writestr(uf, trim(str_w))

do i = 1, ust_mesh%cellvtex%nbar
  write(uf) 3     ! VTK_LINE
enddo
do i = 1, ust_mesh%cellvtex%ntri
  write(uf) 5     ! VTK_TRIANGLE
enddo
do i = 1, ust_mesh%cellvtex%nquad
  write(uf) 9     ! VTK_QUAD
enddo
do i = 1, ust_mesh%cellvtex%ntetra
  write(uf) 10    ! VTK_TETRA
enddo
do i = 1, ust_mesh%cellvtex%npyra
  write(uf) 14    ! VTK_PYRAMID
enddo
do i = 1, ust_mesh%cellvtex%npenta
  write(uf) 13    ! VTK_WEDGE
enddo
do i = 1, ust_mesh%cellvtex%nhexa
  write(uf) 12    ! VTK_HEXAHEDRON
enddo

! -- donnees --

call calc_varprim(defsolver, field)

select case(defsolver%typ_solver)
case(solNS)
  call writereturn(uf)
  write(str_w, '(a,i9)') 'CELL_DATA ', ncellint
  call writestr(uf, trim(str_w))
  call output_vtkbin_scal(uf, ust_mesh, "DENSITY",  field%etatprim%tabscal(1))
  call output_vtkbin_scal(uf, ust_mesh, "PRESSURE", field%etatprim%tabscal(2))
  call output_vtkbin_vect(uf, ust_mesh, "VELOCITY", field%etatprim%tabvect(1))

case(solKDIF)
  call writereturn(uf)
  write(str_w, '(a,i9)') 'CELL_DATA ', ncellint
  call writestr(uf, trim(str_w))
  call output_vtkbin_scal(uf, ust_mesh, "TEMPERATURE",  field%etatprim%tabscal(1))

case(solVORTEX)
case default
  call erreur("Developpement","solveur inconnu (output_vtkbin_cell)")
endselect


endsubroutine output_vtkbin_cell

!------------------------------------------------------------------------------!
! Changes history
!
! avr  2004 : creation de la procedure
! juin 2004 : ecriture de format CELL_DATA
! july 2004 : extension to NS solver outputs (write scalar and vector fields)
! mar  2006 : bug correction (umesh%ncell was changed by outputs)
!------------------------------------------------------------------------------!