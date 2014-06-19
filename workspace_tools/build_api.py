"""
mbed SDK
Copyright (c) 2011-2013 ARM Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
from os.path import join, exists, basename
from shutil import rmtree
from types import ListType

from workspace_tools.utils import mkdir, run_cmd
from workspace_tools.toolchains import TOOLCHAIN_CLASSES
from workspace_tools.paths import MBED_TARGETS_PATH, MBED_LIBRARIES, MBED_API, MBED_HAL, MBED_COMMON
from workspace_tools.libraries import Library
from workspace_tools.targets import TARGET_NAMES, TARGET_MAP


def build_project(src_path, build_path, target, toolchain_name,
        libraries_paths=None, options=None, linker_script=None,
        clean=False, notify=None, verbose=False, name=None, macros=None):
    # Toolchain instance
    toolchain = TOOLCHAIN_CLASSES[toolchain_name](target, options, notify, macros)
    toolchain.VERBOSE = verbose
    toolchain.build_all = clean

    src_paths = [src_path] if type(src_path) != ListType else src_path
    if name is None:
        name = basename(src_paths[0])
    toolchain.info("\n>>> BUILD PROJECT: %s (%s, %s)" % (name.upper(), target.name, toolchain_name))

    # Scan src_path and libraries_paths for resources
    resources = toolchain.scan_resources(src_paths[0])
    for path in src_paths[1:]:
        resources.add(toolchain.scan_resources(path))
    if libraries_paths is not None:
        src_paths.extend(libraries_paths)
        for path in libraries_paths:
            resources.add(toolchain.scan_resources(path))

    if linker_script is not None:
        resources.linker_script = linker_script

    # Build Directory
    if clean:
        if exists(build_path):
            rmtree(build_path)
    mkdir(build_path)

    # Compile Sources
    for path in src_paths:
        src = toolchain.scan_resources(path)
        objects = toolchain.compile_sources(src, build_path, resources.inc_dirs)
        resources.objects.extend(objects)

    # Link Program
    return toolchain.link_program(resources, build_path, name)


"""
src_path: the path of the source directory
build_path: the path of the build directory
target: ['LPC1768', 'LPC11U24', 'LPC2368']
toolchain: ['ARM', 'uARM', 'GCC_ARM', 'GCC_CS', 'GCC_CR']
library_paths: List of paths to additional libraries
clean: Rebuild everything if True
notify: Notify function for logs
verbose: Write the actual tools command lines if True
"""
def build_library(src_paths, build_path, target, toolchain_name,
         dependencies_paths=None, options=None, name=None, clean=False,
         notify=None, verbose=False, macros=None):
    if type(src_paths) != ListType: src_paths = [src_paths]

    for src_path in src_paths:
        if not exists(src_path):
            raise Exception("The library source folder does not exist: %s", src_path)

    # Toolchain instance
    toolchain = TOOLCHAIN_CLASSES[toolchain_name](target, options, macros=macros, notify=notify)
    toolchain.VERBOSE = verbose
    toolchain.build_all = clean

    # The first path will give the name to the library
    name = basename(src_paths[0])
    toolchain.info("\n>>> BUILD LIBRARY %s (%s, %s)" % (name.upper(), target.name, toolchain_name))

    # Scan Resources
    resources = []
    for src_path in src_paths:
        resources.append(toolchain.scan_resources(src_path))

    # Dependencies Include Paths
    dependencies_include_dir = []
    if dependencies_paths is not None:
        for path in dependencies_paths:
            lib_resources = toolchain.scan_resources(path)
            dependencies_include_dir.extend(lib_resources.inc_dirs)

    # Create the desired build directory structure
    bin_path = join(build_path, toolchain.obj_path)
    mkdir(bin_path)
    tmp_path = join(build_path, '.temp', toolchain.obj_path)
    mkdir(tmp_path)

    # Copy Headers
    for resource in resources:
        toolchain.copy_files(resource.headers, build_path, rel_path=resource.base_path)
    dependencies_include_dir.extend(toolchain.scan_resources(build_path).inc_dirs)

    # Compile Sources
    objects = []
    for resource in resources:
        objects.extend(toolchain.compile_sources(resource, tmp_path, dependencies_include_dir))

    toolchain.build_library(objects, bin_path, name)


def build_lib(lib_id, target, toolchain, options=None, verbose=False, clean=False, macros=None, notify=None):
    lib = Library(lib_id)
    if lib.is_supported(target, toolchain):
        build_library(lib.source_dir, lib.build_dir, target, toolchain,
                      lib.dependencies, options,
                      verbose=verbose, clean=clean, macros=macros, notify=notify)
    else:
        print '\n\nLibrary "%s" is not yet supported on target %s with toolchain %s' % (lib_id, target.name, toolchain)


# We do have unique legacy conventions about how we build and package the mbed library
def build_mbed_libs(target, toolchain_name, options=None, verbose=False, clean=False, macros=None, notify=None):
    # Check toolchain support
    if toolchain_name not in target.supported_toolchains:
        print '\n%s target is not yet supported by toolchain %s' % (target.name, toolchain_name)
        return

    # Toolchain
    toolchain = TOOLCHAIN_CLASSES[toolchain_name](target, options, macros=macros, notify=notify)
    toolchain.VERBOSE = verbose
    toolchain.build_all = clean

    # Source and Build Paths
    BUILD_TARGET = join(MBED_LIBRARIES, "TARGET_" + target.name)
    BUILD_TOOLCHAIN = join(BUILD_TARGET, "TOOLCHAIN_" + toolchain.name)
    mkdir(BUILD_TOOLCHAIN)

    TMP_PATH = join(MBED_LIBRARIES, '.temp', toolchain.obj_path)
    mkdir(TMP_PATH)

    # CMSIS
    toolchain.info("\n>>> BUILD LIBRARY %s (%s, %s)" % ('CMSIS', target.name, toolchain_name))
    cmsis_src = join(MBED_TARGETS_PATH, "cmsis")
    resources = toolchain.scan_resources(cmsis_src)

    toolchain.copy_files(resources.headers, BUILD_TARGET)
    toolchain.copy_files(resources.linker_script, BUILD_TOOLCHAIN)

    objects = toolchain.compile_sources(resources, TMP_PATH)
    toolchain.copy_files(objects, BUILD_TOOLCHAIN)

    # mbed
    toolchain.info("\n>>> BUILD LIBRARY %s (%s, %s)" % ('MBED', target.name, toolchain_name))

    # Common Headers
    toolchain.copy_files(toolchain.scan_resources(MBED_API).headers, MBED_LIBRARIES)
    toolchain.copy_files(toolchain.scan_resources(MBED_HAL).headers, MBED_LIBRARIES)

    # Target specific sources
    HAL_SRC = join(MBED_TARGETS_PATH, "hal")
    hal_implementation = toolchain.scan_resources(HAL_SRC)
    toolchain.copy_files(hal_implementation.headers + hal_implementation.hex_files, BUILD_TARGET, HAL_SRC)
    incdirs = toolchain.scan_resources(BUILD_TARGET).inc_dirs
    objects = toolchain.compile_sources(hal_implementation, TMP_PATH, [MBED_LIBRARIES] + incdirs)

    # Common Sources
    mbed_resources = toolchain.scan_resources(MBED_COMMON)
    objects += toolchain.compile_sources(mbed_resources, TMP_PATH, [MBED_LIBRARIES] + incdirs)

    # A number of compiled files need to be copied as objects as opposed to
    # being part of the mbed library, for reasons that have to do with the way
    # the linker search for symbols in archives. These are:
    #   - retarget.o: to make sure that the C standard lib symbols get overridden
    #   - board.o: mbed_die is weak
    #   - mbed_overrides.o: this contains platform overrides of various weak SDK functions
    separate_names, separate_objects = ['retarget.o', 'board.o', 'mbed_overrides.o'], []
    for o in objects:
        for name in separate_names:
            if o.endswith(name):
                separate_objects.append(o)
    for o in separate_objects:
        objects.remove(o)
    toolchain.build_library(objects, BUILD_TOOLCHAIN, "mbed")
    for o in separate_objects:
        toolchain.copy_files(o, BUILD_TOOLCHAIN)


def get_unique_supported_toolchains():
    """ Get list of all unique toolchains supported by targets """
    unique_supported_toolchains = []
    for target in TARGET_NAMES:
        for toolchain in TARGET_MAP[target].supported_toolchains:
            if toolchain not in unique_supported_toolchains:
                unique_supported_toolchains.append(toolchain)
    return unique_supported_toolchains


def mcu_toolchain_matrix():
    """  Shows target map using prettytable """
    unique_supported_toolchains = get_unique_supported_toolchains()
    from prettytable import PrettyTable # Only use it in this function so building works without extra modules

    # All tests status table print
    columns = ["Platform"] + unique_supported_toolchains
    pt = PrettyTable(["Platform"] + unique_supported_toolchains)
    # Align table
    for col in columns:
        pt.align[col] = "c"
    pt.align["Platform"] = "l"

    perm_counter = 0;
    for target in sorted(TARGET_NAMES):
        row = [target]  # First column is platform name
        for unique_toolchain in unique_supported_toolchains:
            text = "-"
            if unique_toolchain in TARGET_MAP[target].supported_toolchains:
                text = "Supported"
                perm_counter += 1
            row.append(text);
        pt.add_row(row)
    print pt
    print "Total permutations: %d"% (perm_counter)


def static_analysis_scan(target, toolchain_name, CPPCHECK_CMD, CPPCHECK_MSG_FORMAT, options=None, verbose=False, clean=False, macros=None, notify=None):
    # Toolchain
    toolchain = TOOLCHAIN_CLASSES[toolchain_name](target, options, macros=macros, notify=notify)
    toolchain.VERBOSE = verbose
    toolchain.build_all = clean

    # Source and Build Paths
    BUILD_TARGET = join(MBED_LIBRARIES, "TARGET_" + target.name)
    BUILD_TOOLCHAIN = join(BUILD_TARGET, "TOOLCHAIN_" + toolchain.name)
    mkdir(BUILD_TOOLCHAIN)

    TMP_PATH = join(MBED_LIBRARIES, '.temp', toolchain.obj_path)
    mkdir(TMP_PATH)

    # CMSIS
    toolchain.info(">>>> STATIC ANALYSIS FOR %s (%s, %s)" % ('CMSIS', target.name, toolchain_name))
    cmsis_src = join(MBED_TARGETS_PATH, "cmsis")
    resources = toolchain.scan_resources(cmsis_src)

    # Copy files before analysis
    toolchain.copy_files(resources.headers, BUILD_TARGET)
    toolchain.copy_files(resources.linker_script, BUILD_TOOLCHAIN)

    # Gather include paths, c, cpp sources and macros to transfer to cppcheck command line
    includes = ["-I%s " % i for i in resources.inc_dirs]
    includes.append(" -I%s "% str(BUILD_TARGET))
    c_sources = " ".join(resources.c_sources)
    cpp_sources = " ".join(resources.cpp_sources)
    macros = ['-D%s ' % s for s in toolchain.get_symbols() + toolchain.macros]

    check_cmd = " ".join(CPPCHECK_CMD) + " "
    check_cmd += " ".join(CPPCHECK_MSG_FORMAT) + " "
    check_cmd += " ".join(includes)
    check_cmd += " ".join(macros)
    check_cmd += c_sources
    check_cmd += " " + cpp_sources
    # print check_cmd

    #['cppcheck', includes, c_sources, cpp_sources]
    stdout, stderr, rc = run_cmd(check_cmd)

    if verbose:
        print stdout
    print stderr

    # MBED
    toolchain.info(">>> STATIC ANALYSIS FOR %s (%s, %s)" % ('MBED', target.name, toolchain_name))

    # Common Headers
    toolchain.copy_files(toolchain.scan_resources(MBED_API).headers, MBED_LIBRARIES)
    toolchain.copy_files(toolchain.scan_resources(MBED_HAL).headers, MBED_LIBRARIES)

    # Target specific sources
    HAL_SRC = join(MBED_TARGETS_PATH, "hal")
    hal_implementation = toolchain.scan_resources(HAL_SRC)

    # Copy files before analysis
    toolchain.copy_files(hal_implementation.headers + hal_implementation.hex_files, BUILD_TARGET, HAL_SRC)
    incdirs = toolchain.scan_resources(BUILD_TARGET)

    target_includes = ["-I%s " % i for i in incdirs.inc_dirs]
    target_includes.append(" -I%s "% str(BUILD_TARGET))
    target_includes.append(" -I%s "% str(HAL_SRC))
    target_c_sources = " ".join(incdirs.c_sources)
    target_cpp_sources = " ".join(incdirs.cpp_sources)
    target_macros = ['-D%s ' % s for s in toolchain.get_symbols() + toolchain.macros]

    # Common Sources
    mbed_resources = toolchain.scan_resources(MBED_COMMON)

    # Gather include paths, c, cpp sources and macros to transfer to cppcheck command line
    mbed_includes = ["-I%s " % i for i in mbed_resources.inc_dirs]
    mbed_includes.append(" -I%s "% str(BUILD_TARGET))
    mbed_includes.append(" -I%s "% str(MBED_COMMON))
    mbed_includes.append(" -I%s "% str(MBED_API))
    mbed_includes.append(" -I%s "% str(MBED_HAL))
    mbed_c_sources = " ".join(mbed_resources.c_sources)
    mbed_cpp_sources = " ".join(mbed_resources.cpp_sources)

    check_cmd = " ".join(CPPCHECK_CMD) + " "
    check_cmd += " ".join(CPPCHECK_MSG_FORMAT) + " "
    check_cmd += " ".join(target_includes)
    check_cmd += " ".join(mbed_includes)
    check_cmd += " ".join(target_macros)
    check_cmd += " " + target_c_sources
    check_cmd += " " + target_cpp_sources
    check_cmd += " " + mbed_c_sources
    check_cmd += " " + mbed_cpp_sources
    # print check_cmd

    #['cppcheck', includes, c_sources, cpp_sources]
    stdout, stderr, rc = run_cmd(check_cmd)

    if verbose:
        print stdout
    print stderr


def static_analysis_scan_lib(lib_id, target, toolchain, CPPCHECK_CMD, CPPCHECK_MSG_FORMAT, options=None, verbose=False, clean=False, macros=None, notify=None):
    lib = Library(lib_id)
    if lib.is_supported(target, toolchain):
        static_analysis_scan_library(lib.source_dir, lib.build_dir, target, toolchain, CPPCHECK_CMD, CPPCHECK_MSG_FORMAT,
                      lib.dependencies, options,
                      verbose=verbose, clean=clean, macros=macros, notify=notify)
    else:
        print 'Library "%s" is not yet supported on target %s with toolchain %s' % (lib_id, target.name, toolchain)


def static_analysis_scan_library(src_paths, build_path, target, toolchain_name, CPPCHECK_CMD, CPPCHECK_MSG_FORMAT,
         dependencies_paths=None, options=None, name=None, clean=False,
         notify=None, verbose=False, macros=None):
    if type(src_paths) != ListType: src_paths = [src_paths]

    for src_path in src_paths:
        if not exists(src_path):
            raise Exception("The library source folder does not exist: %s", src_path)


    # Toolchain instance
    toolchain = TOOLCHAIN_CLASSES[toolchain_name](target, options, macros=macros, notify=notify)
    toolchain.VERBOSE = verbose

    # The first path will give the name to the library
    name = basename(src_paths[0])
    toolchain.info(">>> STATIC ANALYSIS FOR LIBRARY %s (%s, %s)" % (name.upper(), target.name, toolchain_name))

    # Scan Resources
    resources = []
    for src_path in src_paths:
        resources.append(toolchain.scan_resources(src_path))

    # Dependencies Include Paths
    dependencies_include_dir = []
    if dependencies_paths is not None:
        for path in dependencies_paths:
            lib_resources = toolchain.scan_resources(path)
            dependencies_include_dir.extend(lib_resources.inc_dirs)

    # Create the desired build directory structure
    bin_path = join(build_path, toolchain.obj_path)
    mkdir(bin_path)
    tmp_path = join(build_path, '.temp', toolchain.obj_path)
    mkdir(tmp_path)

    # Gather include paths, c, cpp sources and macros to transfer to cppcheck command line
    includes = ["-I%s " % i for i in dependencies_include_dir + src_paths]
    c_sources = " "
    cpp_sources = " "
    macros = ['-D%s ' % s for s in toolchain.get_symbols() + toolchain.macros]

    # Copy Headers
    for resource in resources:
        toolchain.copy_files(resource.headers, build_path, rel_path=resource.base_path)
        includes += ["-I%s " % i for i in resource.inc_dirs]
        c_sources += " ".join(resource.c_sources) + " "
        cpp_sources += " ".join(resource.cpp_sources) + " "

    dependencies_include_dir.extend(toolchain.scan_resources(build_path).inc_dirs)

    check_cmd = " ".join(CPPCHECK_CMD) + " "
    check_cmd += " ".join(CPPCHECK_MSG_FORMAT) + " "
    check_cmd += " ".join(includes)
    check_cmd += " ".join(macros)
    check_cmd += " " + c_sources
    check_cmd += " " + cpp_sources

    #['cppcheck', includes, c_sources, cpp_sources]
    stdout, stderr, rc = run_cmd(check_cmd)

    if verbose:
        print stdout
    print stderr
