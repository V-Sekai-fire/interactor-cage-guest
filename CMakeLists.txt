# cage.elf: the cage stage as a riscv64 guest, built from this repository and the four subtrees under vendor/ (no sibling checkouts).
#   cmake -S . -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=<repository-riscv64-sysroot>/toolchain.cmake && cmake --build build
cmake_minimum_required(VERSION 3.16)
project(cage_guest C CXX)

set(GUEST_RUNTIME_ROOT ${CMAKE_CURRENT_LIST_DIR}/vendor/guest-runtime)
set(GUEST_ELF_DIR ${CMAKE_BINARY_DIR})
include(${GUEST_RUNTIME_ROOT}/cmake/guest_runtime.cmake)

set(R ${CMAKE_CURRENT_LIST_DIR})
set(PMP_SUBSET ${R}/vendor/sketch-mesh-guest/vendor/pmp-subset)
file(GLOB_RECURSE PMP_SOURCES ${PMP_SUBSET}/pmp/*.cpp)
add_library(pmp_subset STATIC ${PMP_SOURCES})
target_include_directories(pmp_subset PUBLIC ${PMP_SUBSET})
target_compile_definitions(pmp_subset PUBLIC _USE_MATH_DEFINES PMP_SCALAR_TYPE_64=1 PMP_NO_EIGEN)
target_compile_options(pmp_subset PRIVATE -ffp-model=strict -Wno-unsupported-floating-point-opt -w)

add_stage_elf(cage
	${R}/guest/cage/main.cpp
	${R}/guest/cage/cage_api.cpp
	${R}/guest/cage/cage_fit.cpp
	${R}/guest/cage/cage_net.cpp
	${R}/guest/cage/checks.cpp
	${R}/guest/cage/fit_driver.cpp
	${R}/guest/cage/fixtures.cpp
	${R}/guest/common/deform/bhc13/bhc13.cpp
	${R}/guest/common/deform/cage_kernels.cpp
	${R}/guest/common/deform/skin_bake.cpp
	${R}/vendor/solve/core/lbfgsb/guest/drape/lbfgsb.cpp
	${R}/vendor/solve/core/lbfgsb/guest/drape/vec_cpu.cpp)
target_compile_options(cage PRIVATE -ffp-contract=off -Wno-unused-function)
target_include_directories(cage PRIVATE ${R}/guest ${R}/guest/cage ${R}/guest/common ${R}/vendor/solve/core/lbfgsb/guest/drape ${R}/vendor/solve/core/lbfgsb/kernels/drape/cpp ${R}/vendor/solve/core/slang_rt ${R}/guest/common/deform
	${R}/vendor/anny-kernels/kernels/anny/cpp ${R}/vendor/guest-runtime/guest/avbd/slang-rt ${R}/vendor/guest-common/guest)
target_link_libraries(cage PRIVATE pmp_subset)
