!------------------------------------------------------------------------------!
! Procedure : output_zone
!
! Function
!   Write the field of each zone
!
!------------------------------------------------------------------------------!
subroutine output_zone(nom, defio, zone)

use TYPHMAKE
use OUTPUT
use VARCOM
use DEFZONE
use MENU_GEN

implicit none

! -- INPUTS --
character(len=*), intent(in) :: nom       ! filename
type(mnu_output)             :: defio     ! output parameter
type(st_zone)                :: zone      ! zone

! -- OUPUTS --

! -- Internal variables --
integer               :: izone, i, dim, ufc, ir
integer               :: info
type(st_genericfield) :: vfield
character(len=10)     :: suffix

! -- BODY --


!------------------------------------------------------------------
! prepare DATA to save
!------------------------------------------------------------------

select case(defio%dataset)
case(dataset_node)
case(dataset_cell)
!case(dataset_bococell)
!case(dataset_bococell)
case default
  call error_stop("internal error(output_zone): unknown dataset parameter")
endselect

if (mpi_run) then
  defio%filename = trim(nom)//"_p"//strof_full_int(myprocid,3)
else
  defio%filename = trim(nom)
endif

select case(defio%format)

case(fmt_VTK)

  call print_info(2,"* write VTK file: " // trim(defio%filename))
  call output_vtk(defio, zone)

case(fmt_VTKBIN)

  call print_info(2,"* write VTK Binary file: " // trim(defio%filename))
  call output_vtkbin(defio, zone)

case(fmt_TECPLOT)

  call print_info(2,"* write TECPLOT file: " // trim(defio%filename))
  call output_tecplot(trim(defio%filename), defio, zone)

case(fmt_CGNS, fmt_CGNS_linked)
  call print_info(2,"* write CGNS file: " // trim(defio%filename))
  ! write sol in GENERAL OUTPUT

case default
  call error_stop("Internal error (output_zone): unknown output format parameter")
endselect

!------------------------------------------------------------------
! General output
!------------------------------------------------------------------

select case(defio%format)
case(fmt_VTK, fmt_VTKBIN, fmt_TECPLOT)
  ! already saved
case(fmt_CGNS, fmt_CGNS_linked)

  call outputzone_open   (defio, zone) 
  call outputzone_ustmesh(defio, zone) 
  call outputzone_sol    (defio, zone) 
  call outputzone_close  (defio, zone) 

case default
  call error_stop("Internal error (output_zone): unknown output format parameter")
endselect

endsubroutine output_zone
!------------------------------------------------------------------------------!
! Changes history
!
! May  2008: creation from output_result
! JuLy 2009: restructuration, general output routines
!------------------------------------------------------------------------------!
