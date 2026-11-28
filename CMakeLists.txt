# Builds cage.elf (double precision) from this repository and its vendor/ subtrees.
# Configure with the riscv64 sysroot toolchain:
#   cmake -S . -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=<repository-riscv64-sysroot>/toolchain.cmake
cmake_minimum_required(VERSION 3.20)
project(cage_guest C CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(GUEST_RUNTIME_ROOT ${CMAKE_SOURCE_DIR}/vendor/guest-runtime)
include(${GUEST_RUNTIME_ROOT}/cmake/guest_runtime.cmake)

set(PMP_SUBSET ${CMAKE_SOURCE_DIR}/vendor/sketch-mesh-guest/vendor/pmp-subset)
file(GLOB PMP_SUBSET_SOURCES "${PMP_SUBSET}/pmp/*.cpp" "${PMP_SUBSET}/pmp/algorithms/*.cpp")
add_library(pmp_subset STATIC ${PMP_SUBSET_SOURCES})
target_include_directories(pmp_subset PUBLIC "${PMP_SUBSET}")
target_compile_definitions(pmp_subset PUBLIC _USE_MATH_DEFINES PMP_SCALAR_TYPE_64=1 PMP_NO_EIGEN)
target_compile_options(pmp_subset PRIVATE -ffp-contract=off -w)

set(SOLVE ${CMAKE_SOURCE_DIR}/vendor/solve/core/lbfgsb)
file(GLOB CAGE_SOURCES "${CMAKE_SOURCE_DIR}/guest/cage/*.cpp")
add_stage_elf(cage
	${CAGE_SOURCES}
	guest/common/deform/bhc13/bhc13.cpp
	guest/common/deform/cage_kernels.cpp
	guest/common/deform/skin_bake.cpp
	${SOLVE}/guest/drape/lbfgsb.cpp
	${SOLVE}/guest/drape/vec_cpu.cpp)
target_compile_options(cage PRIVATE -ffp-contract=off)
target_include_directories(cage PRIVATE
	guest/cage
	guest/common/deform
	guest/common
	guest
	${CMAKE_SOURCE_DIR}
	${SOLVE}/guest/drape
	${SOLVE}/kernels/drape/cpp
	${CMAKE_SOURCE_DIR}/vendor/anny-kernels/kernels/anny/cpp
	${GUEST_RUNTIME_ROOT}/guest/avbd/slang-rt
	${CMAKE_SOURCE_DIR}/vendor/guest-common/guest)
target_link_libraries(cage PRIVATE pmp_subset)
