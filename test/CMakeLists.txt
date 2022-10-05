#
set( case_envs
  ${CMAKE_CURRENT_SOURCE_DIR}/case/Barry.env
  ${CMAKE_CURRENT_SOURCE_DIR}/case/toy.env
)

#
set( tests_LISTFILEs
  ${CMAKE_CURRENT_SOURCE_DIR}/tests/ATM_c48_toy
  ${CMAKE_CURRENT_SOURCE_DIR}/tests/S2S_c48_toy
)

#
set( obs_data
  ${CMAKE_CURRENT_SOURCE_DIR}/data/bal022019_post.dat 
)

#
set( vrfy_scripts
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/TC_Tracks_error.py
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/drive_preprocess.sh
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/preprocess.sh
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/drive_map_obs.sh 
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/map_compare_obs.sh
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/drive_anoms.sh
  ${CMAKE_CURRENT_SOURCE_DIR}/vrfy/anoms12.sh
)

#
set( ncl_files
  ${CMAKE_CURRENT_SOURCE_DIR}/ncl/basicres.ncl
  ${CMAKE_CURRENT_SOURCE_DIR}/ncl/panelopts.ncl
  ${CMAKE_CURRENT_SOURCE_DIR}/ncl/setcolors.ncl 
  ${CMAKE_CURRENT_SOURCE_DIR}/ncl/smallmean.ncl
)

#
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/build_global-workflow.sh
      ${CMAKE_CURRENT_BINARY_DIR}/build_global-workflow.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/build_global-workflow-docker.sh
      ${CMAKE_CURRENT_BINARY_DIR}/build_global-workflow-docker.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/prep.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/prep.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/prep-docker.sh
      ${CMAKE_CURRENT_BINARY_DIR}/prep-docker.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ctest.sh
      ${CMAKE_CURRENT_BINARY_DIR}/run_ctest.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ctest_norocoto_fcst_only.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/run_ctest_norocoto_fcst_only.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/run_ctest_norocoto_fcst_only-docker.sh
      ${CMAKE_CURRENT_BINARY_DIR}/run_ctest_norocoto_fcst_only-docker.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/run_vrfy.sh
      ${CMAKE_CURRENT_BINARY_DIR}/run_vrfy.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/detect_machine.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/detect_machine.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/run_trk_err.sh 
      ${CMAKE_CURRENT_BINARY_DIR}/run_trk_err.sh )
execute_process( COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_CURRENT_SOURCE_DIR}/compare_ncfile.py
      ${CMAKE_CURRENT_BINARY_DIR}/compare_ncfile.py )

# case env files 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/case)
foreach(FILENAME ${case_envs})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/case/${filename} )
endforeach()

# test list files 
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
foreach(FILENAME ${tests_LISTFILEs})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/tests/${filename} )
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
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/obs/era5/1p00/dailymean)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/obs/sst_OSTIA/1p00/dailymean)
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/data/t2m.day.mean.20190712.1p00.nc
      ${CMAKE_CURRENT_BINARY_DIR}/obs/era5/1p00/dailymean/t2m.day.mean.20190712.1p00.nc )
execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${CMAKE_CURRENT_SOURCE_DIR}/data/sst_OSTIA.day.mean.20190712.1p00.nc
      ${CMAKE_CURRENT_BINARY_DIR}/obs/sst_OSTIA/1p00/dailymean/sst_OSTIA.day.mean.20190712.1p00.nc )

foreach(FILENAME ${obs_data})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/data/${filename} )
endforeach()

# ncl files
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ncl)
foreach(FILENAME ${ncl_files})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/ncl/${filename} )
endforeach()

# create inputdata folder
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/inputdata)

#
#add_test ( NAME build_ufs
#           COMMAND bash build_global-workflow.sh
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(build_ufs PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME get_ufs_fix_data
#           COMMAND bash prep.sh 
#           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(get_ufs_fix_data PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME ATM_c96_Barry
#           COMMAND bash run_ctest.sh --app=ATM --grid=96 --case=Barry --ctest -v 
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(ATM_c96_Barry PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME S2S_c96_Barry
#           COMMAND bash run_ctest.sh --app=S2S --grid=96 --case=Barry --ctest -v
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(S2S_c96_Barry PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME S2SW_c96_Barry
#           COMMAND bash run_ctest.sh --app=S2SW --grid=96 --case=Barry --ctest -v
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(S2SW_c96_Barry PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME S2SWA_c96_Barry
#           COMMAND bash run_ctest.sh --app=S2SWA --grid=96 --case=Barry --ctest -v
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(S2SWA_c96_Barry PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME Barry_track_err
#           COMMAND bash run_trk_err.sh 
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(Barry_track_err PROPERTIES TIMEOUT 7200)

#
#add_test ( NAME model_vrfy
#           COMMAND bash run_vrfy.sh
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(model_vrfy PROPERTIES TIMEOUT 1500)

#
#add_test ( NAME fcst_only_S2S_c96_Barry
#           COMMAND bash run_ctest_norocoto_fcst_only.sh --app=S2S --grid=96 --case=Barry --ctest -v
#           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
#set_tests_properties(fcst_only_S2S_c96_Barry PROPERTIES TIMEOUT 1800)

#
add_test ( NAME docker_build_ufs
           COMMAND bash build_global-workflow-docker.sh
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(docker_build_ufs PROPERTIES TIMEOUT 1800)

#
add_test ( NAME docker_stage_ufs_data
           COMMAND bash prep-docker.sh -a 48 -o 500
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(docker_stage_ufs_data PROPERTIES TIMEOUT 1800)

#
add_test ( NAME docker_ATM_c48_toy
	COMMAND bash run_ctest_norocoto_fcst_only-docker.sh --app=ATM --grid=48 --case=toy --ctest -v
           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(docker_ATM_c48_toy PROPERTIES TIMEOUT 1800)
set_tests_properties(docker_ATM_c48_toy PROPERTIES DEPENDS "docker_build_ufs;docker_stage_ufs_data")

#
add_test ( NAME docker_S2S_c48_toy
	COMMAND bash run_ctest_norocoto_fcst_only-docker.sh --app=S2S --grid=48 --case=toy --ctest -v
           WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(docker_S2S_c48_toy PROPERTIES TIMEOUT 1800)   
set_tests_properties(docker_S2S_c48_toy PROPERTIES DEPENDS "docker_build_ufs;docker_stage_ufs_data")
