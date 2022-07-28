# cpp-20-modules-build-system
A build system for C++ modules made in bash (for `gcc`).

## Compile
```sh
scripts/compile.sh example/example.target
```

## Run
```sh
scripts/run.sh example/example.target
```

## Variables
| Variable | Default | Description  | Related Function(s) |
| -------- | ------- | ------------ | ------------------- |
| `CXX_COMPILER` | `g++` | The C++ compiler that should be used to compile the files.
| `OUTPUT_DIR` | `build` | The directory where the build files will be stored. | `output_directory`
| `DEEP_CHECK` | `1` | Should we evaluate the macros in the source files to invalidate the cache?
| `DELETE_OBSOLETE` | `1` | Should we delete the obsolete object files that weren't used in the current build?
| `STANDARD` | `c++20` | The C++ standard that we should use. | `standard`
| `CFLAGS` | `""` | The additional flags that will be passed to the C++ compiler. | `add_compiler_flags`
| `LFLAGS` | `""` | The additional flags that will be passed to the C++ compiler when linking the application. | `add_linker_flags`
| `SYSTEM_HEADERS` | `()` | The system headers that this target requires. | `add_system_headers`
| `FILES` | `()` | The files that will get compiled for this target. | `add_files`
| `OUTPUT` | `a.out` | The output file. | `shared_library`, `executable`, `static_library`
| `ARCHIVE` | `0` | Is this target a static library? | `static_library`
| `AR` | `ar` | The `ar` executable.
| `ARFLAGS` | `rcs` | The flags that get passed to the `ar` executable. | `add_ar_flags`

## Function behaviors and arguments
- `add_compiler_flags`, `add_linker_flags`, `add_ar_flags` take a single string argument that will get concatenated with the previous value with a space in between.
- `include` takes multiple string arguments and it will source all those files.
- `add_files`, `add_system_headers` take multiple string arguments that get appended to their respective lists.
- `standard` takes a single string argument which sets the `STANDARD` variable with `c++` prepended to the string.
- `output_directory` takes a single string argument that sets the variable.
- `shared_library` adds `-shared` to `LFLAGS`, `-fPIC` to `CFLAGS`, sets the output to `lib` + the first argument + `.so`, and `ARCHIVE` to `0`.
- `executable` adds `-flto -fwhole-program` to `CFLAGS`, sets the output the first argument, and `ARCHIVE` to `0`.
- `static_library` sets the output to `lib` + the first argument + `.a` and `ARCHIVE` to `1`.

## Target files
A target file is a shell script, you need to specify files (using the `FILES` variable or the `add_files` function) and change the default values of the variables to something that meets your requirements.
