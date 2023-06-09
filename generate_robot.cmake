# Helper to generate URDF models from VRML

# Find openrhp-export-collada
find_program(OPENHRP_EXPORT_COLLADA openhrp-export-collada REQUIRED)
message(STATUS "Found openhrp-export-collada: ${OPENHRP_EXPORT_COLLADA}")

# Find rospack/rosrun to check for collada_urdf
find_program(ROSPACK rospack REQUIRED)
find_program(ROSRUN rosrun REQUIRED)

if(NOT HAS_COLLADA_URDF)
  execute_process(COMMAND ${ROSPACK} find collada_urdf OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE FIND_COLLADA_URDF_RESULT)
  if(FIND_COLLADA_URDF_RESULT EQUAL 0)
    set(HAS_COLLADA_URDF TRUE CACHE INTERNAL "Has collada_urdf ROS package")
  else()
    message(FATAL_ERROR "collada_urdf ROS package is missing, perhaps you should install ros-$ENV{ROS_DISTRO}-collada-urdf")
  endif()
endif()
message(STATUS "collada_urdf is installed")

find_program(MESH_SAMPLING mesh_sampling REQUIRED)
message(STATUS "Found mesh_sampling: ${MESH_SAMPLING}")

find_program(QCONVEX qconvex REQUIRED)
message(STATUS "Found qconvex: ${QCONVEX}")

# Generate a URDF file from the provided VRML file and install the result in DEST_FOLDER
function(generate_urdf VRML DEST_FOLDER)
  cmake_path(GET VRML FILENAME VRML_FILE)
  cmake_path(REMOVE_EXTENSION VRML_FILE LAST_ONLY OUTPUT_VARIABLE NAME)
  cmake_path(REPLACE_EXTENSION VRML_FILE LAST_ONLY dae OUTPUT_VARIABLE DAE_OUT)
  cmake_path(REPLACE_EXTENSION VRML_FILE LAST_ONLY urdf OUTPUT_VARIABLE URDF_OUT)
  set(DAE_OUT "${CMAKE_CURRENT_BINARY_DIR}/${NAME}/collada/${DAE_OUT}")
  set(URDF_OUT "${CMAKE_CURRENT_BINARY_DIR}/${NAME}/urdf/${URDF_OUT}")
  add_custom_command(
    OUTPUT ${DAE_OUT}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${NAME}/collada
    COMMAND ${OPENHRP_EXPORT_COLLADA} -i ${VRML} -o ${DAE_OUT}
    DEPENDS ${VRML}
    VERBATIM
    COMMENT "Generate ${NAME} collada model"
  )
  add_custom_target(generate-${NAME}-collada ALL DEPENDS ${DAE_OUT})
  add_custom_command(
    OUTPUT ${URDF_OUT}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${NAME}/meshes/${NAME}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${NAME}/urdf
    COMMAND rosrun collada_urdf collada_to_urdf ${DAE_OUT} --output_file ${URDF_OUT} --mesh_output_dir ${CMAKE_CURRENT_BINARY_DIR}/${NAME}/meshes/${NAME} --mesh_prefix "file://${DEST_FOLDER}/${NAME}/meshes/${NAME}" -G -A
    DEPENDS ${DAE_OUT}
    VERBATIM
    COMMENT "Generate ${NAME} URDF model"
  )
  add_custom_target(generate-${NAME}-urdf ALL DEPENDS ${URDF_OUT})
  set(POSTPROCESS_STAMP "${CMAKE_CURRENT_BINARY_DIR}/${NAME}/post-process-meshes.stamp")
  add_custom_command(
    OUTPUT ${POSTPROCESS_STAMP}
    COMMAND ${CMAKE_COMMAND} -DSTAMP=${POSTPROCESS_STAMP} -DMESH_DIR=${CMAKE_CURRENT_BINARY_DIR}/${NAME}/meshes -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/post-process-meshes.cmake
    DEPENDS ${URDF_OUT}
    COMMENT "Post-process ${NAME} meshes"
  )
  add_custom_target(post-process-${NAME}-meshes ALL DEPENDS ${POSTPROCESS_STAMP})
  set(GEN_CONVEX_STAMP "${CMAKE_CURRENT_BINARY_DIR}/${NAME}/gen-convex.stamp")
  add_custom_command(
    OUTPUT ${GEN_CONVEX_STAMP}
    COMMAND ${CMAKE_COMMAND} -DNSAMPLES=1000 -DMESH_SAMPLING=${MESH_SAMPLING} -DQCONVEX=${QCONVEX} -DSTAMP=${GEN_CONVEX_STAMP} -DBASE_DIR=${CMAKE_CURRENT_BINARY_DIR}/${NAME} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts/generate-convexes.cmake
    DEPENDS ${URDF_OUT}
    COMMENT "Generate ${NAME} convexes"
  )
  add_custom_target(generate-${NAME}-convexes ALL DEPENDS ${GEN_CONVEX_STAMP})
  # FIXME Handle mimic.yaml if we use the CMake approach for more complex robots
  install(FILES ${URDF_OUT} DESTINATION ${DEST_FOLDER}/${NAME}/urdf/)
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${NAME}/convex DESTINATION ${DEST_FOLDER}/${NAME} FILES_MATCHING PATTERN "*-ch.txt")
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${NAME}/meshes DESTINATION ${DEST_FOLDER}/${NAME} FILES_MATCHING PATTERN "*.dae")
endfunction()
