#
set( case_envs
  ${CMAKE_CURRENT_SOURCE_DIR}/case/Barry.env
)

#
set( obs_data
  ${CMAKE_CURRENT_SOURCE_DIR}/data/bal022019_post.dat 
)

#
set( vrfy_scripts
#  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/Barry_ws_ts.py 
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/Barry_track.py
)

#
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/build_global-workflow.sh
      ${CMAKE_CURRENT_BINARY_DIR}/build_global-workflow.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ctest.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/run_ctest.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/prep.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/prep.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/detect_machine.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/detect_machine.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ws_ts.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/run_ws_ts.sh )

# case env files 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/case)
foreach(FILENAME ${case_envs})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/case/${filename} )
endforeach()

# vrfy scripts 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/vrfy)
foreach(FILENAME ${vrfy_scripts})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/vrfy/${filename} )
endforeach()

# obs data files 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data)
foreach(FILENAME ${obs_data})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/data/${filename} )
endforeach()

# create inputdata folder
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/inputdata)

#
add_test ( NAME test_build_ufs
           COMMAND bash build_global-workflow.sh
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_build_ufs PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_get_ufs_fix_data
           COMMAND bash prep.sh 
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_get_ufs_fix_data PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_ATM_c96_Barry
           COMMAND bash run_ctest.sh --app=ATM --grid=96 --case=Barry --ctest -v 
           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_ATM_c96_Barry PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_S2S_c96_Barry
           COMMAND bash run_ctest.sh --app=S2S --grid=96 --case=Barry --ctest -v
           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_S2S_c96_Barry PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_Barry_track
           COMMAND bash run_ws_ts.sh
           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_Barry_track PROPERTIES TIMEOUT 7200)
