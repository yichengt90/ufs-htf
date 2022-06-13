#
set( test_scripts
  run_test_ATM_c96_p8.sh
  run_test_S2S_c96mx100_p8.sh
  run_test_S2SW_c96mx100_p8.sh
)

#
set( test_names
  ${CMAKE_CURRENT_SOURCE_DIR}/tests/cpld_control_nowav_noaero_p8
  ${CMAKE_CURRENT_SOURCE_DIR}/tests/cpld_control_nowav_p8
)

#
set( nems_parms
  ${CMAKE_CURRENT_SOURCE_DIR}/parm/nems.configure.cpld_nowav_noaero.IN
  ${CMAKE_CURRENT_SOURCE_DIR}/parm/nems.configure.cpld_nowav.IN
)

#
foreach(FILENAME ${test_scripts})
    execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
           ${CMAKE_CURRENT_SOURCE_DIR}/cases/${FILENAME}
           ${CMAKE_CURRENT_BINARY_DIR}/${FILENAME} )
endforeach(FILENAME)

execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/create_case.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/create_case.sh )

execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/detect_machine.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/detect_machine.sh )

execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ctest 
      ${CMAKE_CURRENT_BINARY_DIR}/run_ctest )

# test names 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
foreach(FILENAME ${test_names})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/tests/${filename} )
endforeach()

# nems parms 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/parm)
foreach(FILENAME ${nems_parms})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/parm/${filename} )
endforeach()

#
add_test ( NAME test_ATM_c96_p8
           COMMAND bash run_test_ATM_c96_p8.sh
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_ATM_c96_p8 PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_S2S_c96mx100_p8
           COMMAND bash run_test_S2S_c96mx100_p8.sh
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_S2S_c96mx100_p8 PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_S2SW_c96mx100_p8
           COMMAND bash run_test_S2SW_c96mx100_p8.sh
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_S2S_c96mx100_p8 PROPERTIES TIMEOUT 7200)
