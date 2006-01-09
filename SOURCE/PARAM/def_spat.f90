!------------------------------------------------------------------------------!
! Procedure : def_spat                    Auteur : J. Gressier
!                                         Date   : Novembre 2002
! Fonction                                Modif  : (cf historique)
!   Traitement des parametres du fichier menu principal
!   Parametres principaux du projet
!
! Defauts/Limitations/Divers :
!
!------------------------------------------------------------------------------!
subroutine def_spat(block, defsolver, defspat)

use RPM
use TYPHMAKE
use OUTPUT
use VARCOM
use MENU_SOLVER
use MENU_NUM

implicit none

! -- Declaration des entrees --
type(rpmblock), target :: block
type(mnu_solver)       :: defsolver

! -- Declaration des sorties --
type(mnu_spat) :: defspat

! -- Declaration des variables internes --
type(rpmblock), pointer  :: pblock, pcour  ! pointeur de bloc RPM
integer                  :: nkey           ! nombre de clefs
integer                  :: i
character(len=dimrpmlig) :: str            ! chaine RPM intermediaire

! -- Debut de la procedure --

call print_info(5,"- Definition of spatial numerical parameters")

! -- Initialisation --

defspat%calc_grad = .false.

! -- Recherche du BLOCK:SPAT_PARAM --

pblock => block
call seekrpmblock(pblock, "SPAT_PARAM", 0, pcour, nkey)

! DEV : est-ce que la presence du bloc est obligatoire ?
if (nkey /= 1) call erreur("parameters parsing", &
                           "SPAT_PARAM block not found")

defspat%calc_grad = .false.

select case(defsolver%typ_solver)

case(solNS)

  !-----------------------------------------
  ! Euler numerical Scheme

  call rpmgetkeyvalstr(pcour, "SCHEME", str, "HLLC")
  defspat%sch_hyp = inull

  if (samestring(str,"ROE"))             defspat%sch_hyp = sch_roe
  if (samestring(str,"OSHER-NO"))        defspat%sch_hyp = sch_osher_no
  if (samestring(str,"OSHER-IO"))        defspat%sch_hyp = sch_osher_io
  if (samestring(str,"OSHER"))           defspat%sch_hyp = sch_osher_no
  if (samestring(str,"HUS"))             defspat%sch_hyp = sch_efmo
  if (samestring(str,"EFMO"))            defspat%sch_hyp = sch_efmo
  if (samestring(str,"HLL"))             defspat%sch_hyp = sch_hlle
  if (samestring(str,"HLLE"))            defspat%sch_hyp = sch_hlle
  if (samestring(str,"HLLK"))            defspat%sch_hyp = sch_hllk
  if (samestring(str,"HLLC"))            defspat%sch_hyp = sch_hllc
  if (samestring(str,"HLLCK"))           defspat%sch_hyp = sch_hllck
  if (samestring(str,"STEGER-WARMING"))  defspat%sch_hyp = sch_stegwarm
  if (samestring(str,"VANLEER"))         defspat%sch_hyp = sch_vanleer
  if (samestring(str,"EFM"))             defspat%sch_hyp = sch_efm
  if (samestring(str,"KFVS"))            defspat%sch_hyp = sch_efm
  if (samestring(str,"AUSMM"))           defspat%sch_hyp = sch_ausmm

  if (defspat%sch_hyp == inull) &
    call erreur("parameters parsing","unknown numerical scheme")

  !-----------------------------------------
  ! Jacobian matrix (if needed)

  call rpmgetkeyvalstr(pcour, "JACOBIAN", str, "HLL")
  defspat%jac_hyp = inull

  if (samestring(str,"HLL"))        defspat%jac_hyp = jac_hll
  if (samestring(str,"HLL-DIAG"))   defspat%jac_hyp = jac_hlldiag
  if (samestring(str,"EFM"))        defspat%jac_hyp = jac_efm

  if (defspat%jac_hyp == inull) &
    call erreur("parameters parsing","unknown numerical scheme for jacobian matrices")

  !-----------------------------------------
  ! Dissipative flux method

  select case(defsolver%defns%typ_fluid)
  case(eqEULER)
  case(eqNSLAM, eqRANS)
    call get_dissipmethod(pcour, "DISSIPATIVE_FLUX", defspat)
  case default
    call erreur("parameters parsing","unexpected fluid dynamical model")
  endselect

  !-----------------------------------------
  ! High resolution method

  defspat%method = cnull
  call rpmgetkeyvalstr(pcour, "HIGHRES", str, "NONE")
  if (samestring(str,"NONE"))       defspat%method = hres_none
  if (samestring(str,"MUSCL"))      defspat%method = hres_muscl
  if (samestring(str,"MUSCL-FAST")) defspat%method = hres_musclfast
  if (samestring(str,"ENO"))        defspat%method = hres_eno
  if (samestring(str,"WENO"))       defspat%method = hres_weno
  if (samestring(str,"SPECTRAL"))   defspat%method = hres_spect
  
  if (defspat%method == cnull) &
    call erreur("parameters parsing","unexpected high resolution method")
    
  select case(defspat%method)
  case(hres_none)

  case(hres_muscl, hres_musclfast)

    ! -- High resolution order
    call rpmgetkeyvalint(pcour, "ORDER", defspat%order, 2_kpp)

    ! -- High resolution gradient computation                  
    call get_gradientmethod(pcour, defspat)

    defspat%muscl%limiter = cnull
    call rpmgetkeyvalstr(pcour, "LIMITER", str, "VAN_ALBADA")
    if (samestring(str,"NONE"))        defspat%muscl%limiter = lim_none
    if (samestring(str,"MINMOD"))      defspat%muscl%limiter = lim_minmod
    if (samestring(str,"VAN_ALBADA"))  defspat%muscl%limiter = lim_albada
    if (samestring(str,"ALBADA"))      defspat%muscl%limiter = lim_albada
    if (samestring(str,"VAN_LEER"))    defspat%muscl%limiter = lim_vleer
    if (samestring(str,"VANLEER"))     defspat%muscl%limiter = lim_vleer
    if (samestring(str,"SUPERBEE"))    defspat%muscl%limiter = lim_sbee
    if (samestring(str,"KIM3"))        defspat%muscl%limiter = lim_kim3

    if (defspat%muscl%limiter == cnull) &
      call erreur("parameters parsing","unexpected high resolution limiter")

  case default
    call erreur("parameters parsing","unexpected high resolution method")
  endselect
  

case(solKDIF)

  ! -- Methode de calcul des flux dissipatifs --
  call get_dissipmethod(pcour, "DISSIPATIVE_FLUX", defspat)

case(solVORTEX)

endselect


endsubroutine def_spat

!------------------------------------------------------------------------------!
! Changes history
!
! nov  2002 : creation, lecture de bloc vide
! oct  2003 : choix de la methode de calcul des flux dissipatifs
! mars 2004 : traitement dans le cas solVORTEX
! july 2004 : NS solver parameters
! nov  2004 : NS high resolution parameters
! jan  2006 : basic parameter routines moved to MENU_NUM
!------------------------------------------------------------------------------!
