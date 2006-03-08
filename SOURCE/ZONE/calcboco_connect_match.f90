!------------------------------------------------------------------------------!
! Procedure : calcboco_connect_match                   Authors : J. Gressier
!                                                      Created : October 2005
! Fonction 
!   Computation & exchange of boundary conditonis for connection conditions
!
!------------------------------------------------------------------------------!
subroutine calcboco_connect_match(defsolver, umesh, prim, boco)

use TYPHMAKE
use OUTPUT
use VARCOM
use COMMTAG
use MENU_SOLVER
use USTMESH
use GENFIELD

implicit none

! -- Inputs --
type(mnu_solver)       :: defsolver        ! type d'equation a resoudre
type(st_ustmesh)       :: umesh
type(st_ustboco)       :: boco

! -- Inputs/Outputs --
type(st_genericfield)  :: prim             ! primitive variables fields

! -- Internal variables --
integer :: if, ic, dim, ideb, var
integer :: idef                      ! index de definitions des conditions aux limites
integer :: nrac                      ! numero de raccord
real(krp), allocatable :: bocodata(:) ! packed array of data

! -- BODY --

dim = prim%nscal + 3*prim%nvect
allocate(bocodata(boco%nface*dim))

! -- pack internal variables --

do if = 1, boco%nface
  ic   = umesh%facecell%fils(boco%iface(if), 1)      ! internal cell of limit face
  ideb = (if-1)*dim
  do var = 1, prim%nscal
    bocodata(ideb+var) = prim%tabscal(var)%scal(ic)
  enddo
  ideb = ideb+prim%nscal
  do var = 1, prim%nvect
    bocodata(ideb+(var-1)*3+1:ideb+var*3) = tab(prim%tabvect(var)%vect(ic))
  enddo
enddo

! -- send internal variables --

!print*,"send",boco%gridcon%grid_id, dim*boco%nface, bocodata
call sendtogrid(boco%gridcon%grid_id, dim*boco%nface, bocodata, mpitag_field)

! -- receive boundary conditions --

call receivefromgrid(boco%gridcon%grid_id, dim*boco%nface, bocodata, mpitag_field)
!print*,"recv",boco%gridcon%grid_id, dim*boco%nface, bocodata

! -- unpack boundary conditions --

!print*,"list icell",umesh%facecell%fils(boco%iface(1:boco%nface), 2)
do if = 1, boco%nface
  ic   = umesh%facecell%fils(boco%iface(if), 2)     ! ghost cell
  ideb = (if-1)*dim
  do var = 1, prim%nscal
    prim%tabscal(var)%scal(ic) = bocodata(ideb+var)
  enddo
  ideb = ideb+prim%nscal
  do var = 1, prim%nvect
    prim%tabvect(var)%vect(ic) = v3d_of(bocodata(ideb+(var-1)*3+1:ideb+var*3))
  enddo
enddo

!print*,"end exchange matching conditions"

deallocate(bocodata)

endsubroutine calcboco_connect_match

!------------------------------------------------------------------------------!
! Changes history
!
! Oct   2005 : Created
!------------------------------------------------------------------------------!