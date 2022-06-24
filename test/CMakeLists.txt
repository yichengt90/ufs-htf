#
set( case_envs
  ${CMAKE_CURRENT_SOURCE_DIR}/case/Barry.env
)

#
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ctest.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/run_ctest.sh )

execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/prep.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/prep.sh )

execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/detect_machine.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/detect_machine.sh )

# case env files 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/case)
foreach(FILENAME ${case_envs})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/case/${filename} )
endforeach()

# create inputdata folder
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/inputdata)

#
#add_test ( NAME test_ATM_regional
#           COMMAND bash run_test_ATM_regional.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(test_ATM_regional PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME test_ATM_c96_p8
#           COMMAND bash run_test_ATM_c96_p8.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(test_ATM_c96_p8 PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME test_S2S_c96mx100_p8
#           COMMAND bash run_test_S2S_c96mx100_p8.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(test_S2S_c96mx100_p8 PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME test_S2SW_c96mx100_p8
#           COMMAND bash run_test_S2SW_c96mx100_p8.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(test_S2SW_c96mx100_p8 PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME test_S2SWA_c96mx100_p8
#           COMMAND bash run_test_S2SWA_c96mx100_p8.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(test_S2SWA_c96mx100_p8 PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME test_S2SWA_c192mx050_p8
#           COMMAND bash run_test_S2SWA_c192mx050_p8.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(test_S2SWA_c192mx050_p8 PROPERTIES TIMEOUT 7200)
