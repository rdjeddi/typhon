## FFLAGS depend on the compiler

#SET(CMAKE_Fortran_FLAGS "  " ${CMAKE_Fortran_FLAGS})
if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  SET(CMAKE_Fortran_FLAGS "-cpp -ffree-line-length-none -ffixed-line-length-none -fno-range-check" ${CMAKE_Fortran_FLAGS})
  SET (CMAKE_Fortran_FLAGS_RELEASE "-O3 ")
  set (CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-g ${CMAKE_Fortran_FLAGS_RELEASE}")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-g -O0")
  set (CMAKE_Fortran_FLAGS_PROFILING    "-p ${CMAKE_Fortran_FLAGS_RELEASE}")
elseif (CMAKE_Fortran_COMPILER_ID STREQUAL  "Intel") 
  SET(CMAKE_Fortran_FLAGS "-cpp " ${CMAKE_Fortran_FLAGS})
  set (CMAKE_Fortran_FLAGS_RELEASE "-O3 -g -ip -xSSE4.2")
  set (CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-g ${CMAKE_Fortran_FLAGS_RELEASE}")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-g -fpe0 -CA -CB -CS -CV -traceback -debug all -ftrapuv -WB -warn unused")
  set (CMAKE_Fortran_FLAGS_PROFILING    "-p ${CMAKE_Fortran_FLAGS_RELEASE}")
elseif (CMAKE_Fortran_COMPILER_ID STREQUAL  "PGI") 
  # cray compilers nersc
  set (CMAKE_Fortran_FLAGS_RELEASE "-O3 -ip -xSSE4.2")
  set (CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O3 -g -ip -xSSE4.2")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-g -CA -CB -CS -CV -traceback -debug all -ftrapuv -WB -warn unused")
else (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  message ("CMAKE_Fortran_COMPILER full path: " ${CMAKE_Fortran_COMPILER})
  message ("Fortran compiler: " ${Fortran_COMPILER_NAME})
  message ("No optimized Fortran compiler flags are known, we just try -O2...")
  set (CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-O0 -g")
  set (CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-g ${CMAKE_Fortran_FLAGS_RELEASE}")
  set (CMAKE_Fortran_FLAGS_PROFILING    "-p ${CMAKE_Fortran_FLAGS_RELEASE}")
endif (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")

#get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)
#
#if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
#  # gfortran
#  SET (CMAKE_Fortran_FLAGS "-cpp -ffree-line-length-none -ffixed-line-length-none -fno-range-check" ${CMAKE_Fortran_FLAGS})
#  SET (CMAKE_Fortran_FLAGS_RELEASE "-O3 ")
#  set (CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-g ${CMAKE_Fortran_FLAGS_RELEASE}")
#  set (CMAKE_Fortran_FLAGS_DEBUG   "-g -O0")
#  set (CMAKE_Fortran_FLAGS_PROFILING    "-p ${CMAKE_Fortran_FLAGS_RELEASE}")
#
#  set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3")
#  set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -g")
#elseif (Fortran_COMPILER_NAME MATCHES "ifort.*")
#  # ifort (untested)
#  SET (CMAKE_Fortran_FLAGS "-cpp " ${CMAKE_Fortran_FLAGS})
#  set (CMAKE_Fortran_FLAGS_RELEASE "-O3 -g -ip -xSSE4.2")
#  set (CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-g ${CMAKE_Fortran_FLAGS_RELEASE}")
#  set (CMAKE_Fortran_FLAGS_DEBUG     "-g -fpe0 -CA -CB -CS -CV -traceback -debug all -ftrapuv -WB -warn unused")
#  set (CMAKE_Fortran_FLAGS_PROFILING "-p ${CMAKE_Fortran_FLAGS_RELEASE}")
#elseif (Fortran_COMPILER_NAME MATCHES "g77")
#  # g77
#  set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3 -m32")
#  set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -g -m32")
#else (Fortran_COMPILER_NAME MATCHES "gfortran.*")
#  message ("CMAKE_Fortran_COMPILER full path: " ${CMAKE_Fortran_COMPILER})
#  message ("Fortran compiler: " ${Fortran_COMPILER_NAME})
#  message ("No optimized Fortran compiler flags are known, we just try -O2...")
#  SET (CMAKE_Fortran_FLAGS "-cpp -ffree-line-length-none -ffixed-line-length-none -fno-range-check" ${CMAKE_Fortran_FLAGS})
#  set (CMAKE_Fortran_FLAGS_RELEASE "-O2")
#  set (CMAKE_Fortran_FLAGS_DEBUG   "-O0 -g")
#endif (Fortran_COMPILER_NAME MATCHES "gfortran.*")
#
