!------------------------------------------------------------------------------!
! Procedure : build_implicit_bdlu               Authors : J. Gressier
!
! Function
!   Build implicit system with jacobian matrices to BDLU structure (SPARSE MAT)
!
! Defaults/Limitations/Misc :
!
!------------------------------------------------------------------------------!
subroutine build_implicit_bdlu(dtloc, umesh, jacL, jacR, matbdlu)

use TYPHMAKE
use OUTPUT
use VARCOM
use MENU_SOLVER
use MENU_NUM
use USTMESH
use DEFFIELD
use MATRIX_ARRAY
use SPARSE_MAT

implicit none

! -- Inputs --
type(st_ustmesh) :: umesh        ! unstructured mesh
real(krp)        :: dtloc(1:umesh%ncell)
type(mnu_time)   :: deftime      ! time integration parameter
type(st_mattab)  :: jacL, jacR   ! flux jacobian matrices

! -- Outputs --
type(st_bdlu)    :: matbdlu

! -- Internal variables --
integer(kip)          :: i_f, ic1, ic2, ic, info, dim
integer(kip)          :: i, dimb

! -- Body --

dimb = jacL%dim   ! dimension of a block

!-------------------------------------------------------
! matrix construction - internal faces only

do i_f = 1, umesh%nface_int

  ic1 = matbdlu%couple%fils(i_f,1)     ! ic1 cell is supposed to the lowest index
  ic2 = matbdlu%couple%fils(i_f,2)     ! ic2 cell is supposed to the highest index
  !if (ic1 > ic2) print*,'!!!!! ARGH !!!!'

  ! contribution of the face to left cell (n vector is outward)

  matbdlu%diag (1:dimb, 1:dimb, ic1) = matbdlu%diag(1:dimb, 1:dimb, ic1) + jacL%mat(1:dimb, 1:dimb, i_f)*dtloc(ic1)/umesh%mesh%volume(ic1,1,1)
  matbdlu%upper(1:dimb, 1:dimb, i_f) =                                   + jacR%mat(1:dimb, 1:dimb, i_f)*dtloc(ic1)/umesh%mesh%volume(ic1,1,1)

  ! contribution of the face to right cell (n vector is inward)

  matbdlu%diag (1:dimb, 1:dimb, ic2) = matbdlu%diag(1:dimb, 1:dimb, ic2) - jacR%mat(1:dimb, 1:dimb, i_f)*dtloc(ic2)/umesh%mesh%volume(ic2,1,1)
  matbdlu%lower(1:dimb, 1:dimb, i_f) =                                   - jacL%mat(1:dimb, 1:dimb, i_f)*dtloc(ic2)/umesh%mesh%volume(ic2,1,1)

enddo

!-------------------------------------------------------
! matrix construction - boundary faces only

do i_f = umesh%nface_int+1, umesh%nface

  ic1 = matbdlu%couple%fils(i_f,1)     ! ic1 cell is supposed to the lowest index  (internal cell)
  ic2 = matbdlu%couple%fils(i_f,2)     ! ic2 cell is supposed to the highest index (ghost    cell)

  ! contribution of the face to left cell (internal cell)

  matbdlu%diag (1:dimb, 1:dimb, ic1) = matbdlu%diag(1:dimb, 1:dimb, ic1) + jacL%mat(1:dimb, 1:dimb, i_f)*dtloc(ic1)/umesh%mesh%volume(ic1,1,1)
  matbdlu%upper(1:dimb, 1:dimb, i_f) =                                   + jacR%mat(1:dimb, 1:dimb, i_f)*dtloc(ic1)/umesh%mesh%volume(ic1,1,1)

  ! contribution of the face to right cell

  matbdlu%diag (1:dimb, 1:dimb, ic2) = 0._krp
  do i = 1, dimb
    matbdlu%diag (i, i, ic2) = 1._krp
  enddo
  matbdlu%lower(1:dimb, 1:dimb, i_f) = 0._krp

enddo


endsubroutine build_implicit_bdlu

!------------------------------------------------------------------------------!
! Changes history
!
! Aug 2005 : creation
!------------------------------------------------------------------------------!
