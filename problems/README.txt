# Using Custom Problem Libraries in OptiProfiler

This guide explains how to create and integrate your own optimization problem library into OptiProfiler using the `custom_example` as a reference.

## Overview

OptiProfiler allows benchmarking solvers using custom problem libraries. To use your own problem library, you need to implement two key functions:

1. A loading function that retrieves problems by name
2. A selection function that filters problems based on criteria

The `custom_example` folder demonstrates one possible implementation approach.

## Detailed Steps

### 1. Create Problem Library Folder

First, create a new subfolder (e.g., `your_problem_lib/`) within the `problems/` folder in the OptiProfiler project root directory:

    optiprofiler/
    ├── problems/
    │   ├── custom_example/       <-- Example implementation
    │   │   ├── custom_example_load.m
    │   │   ├── custom_example_select.m
    │   │   └── matlab_problems/  <-- MATLAB implementation of example problems
    │   ├── your_problem_lib/     <-- Your custom problem library folder
    │   │   ├── your_problem_lib_load.m
    │   │   └── your_problem_lib_select.m
    │   ├── s2mpj/                <-- Built-in problem library
    │   └── matcutest/            <-- Another built-in problem library
    ├── matlab/                   <-- Core MATLAB functions
    └── ...                       <-- Other OptipProfiler components

### 2. Implement Core Functions

#### 2.1 Problem Loading Function (refer to `custom_example_load.m`)

Create a function that loads a specific optimization problem by name and returns a Problem class object. This function must:

- Name the file `your_problem_lib_load.m`, where `your_problem_lib` is the name of your subfolder
- Accept a problem name as input
- Return a valid Problem class object

The internal implementation is flexible - you can organize your problem files however you prefer. The example in `custom_example_load.m` demonstrates one approach, but you can use any method as long as the function correctly returns Problem objects.

#### 2.2 Problem Selection Function (refer to `custom_example_select.m`)

Create a function that filters and returns problems matching specified criteria. This function must:

- Name the file `your_problem_lib_select.m`, where `your_problem_lib` is the name of your subfolder
- Accept an options structure containing filtering criteria, such as:
  - `options.ptype`: Problem type (e.g., 'u', 'b', 'l', 'n')
  - `options.mindim`: Minimum dimension
  - `options.maxdim`: Maximum dimension
  - `options.minb`: Minimum number of bound constraints
  - `options.maxb`: Maximum number of bound constraints
  - `options.mincon`: Minimum number of linear and nonlinear constraints
  - `options.maxcon`: Maximum number of linear and nonlinear constraints
  - `excludelist`: List of problem names to exclude
- Return a cell array of problem names that satisfy the criteria

The example in `custom_example_select.m` shows one implementation approach where we pre-compute problem data and store it in a .mat file for faster access. This is particularly useful for large problem libraries.

### 3. Create Problem Definitions

You have complete flexibility in how you organize and define your optimization problems. Some options include:

- Individual MATLAB files (one per problem)
- A single file containing multiple problem definitions
- Problem definitions stored in MAT files

The only requirement is that your `your_problem_lib_select.m` function can retrieve these problems by name and return them as Problem class objects.

### 4. Using Your Custom Problem Library

In your benchmarking script, use your custom problem library by setting the `options.plibs` parameter:

```matlab
% Set options
options = struct();
options.plibs = {'your_problem_lib'};  % Use your custom library only
% Or:
% options.plibs = {'s2mpj', 'your_problem_lib'};  % Use both built-in and custom libraries

% Run benchmark
scores = benchmark({@solver1, @solver2}, options);
```

## Problem Class Properties

When creating Problem class objects, you have to set at least two properties:

- `fun`: The function handle for the objective function
- `x0`: The initial guess for the optimization variable

You can create the Problem class object using the constructor:

```matlab
problem = Problem(struct('fun', @your_objective_function, 'x0', initial_guess));
```

More details on the Problem class and its properties can be found by helping the class in MATLAB:

```matlab
help Problem
```

## Example Implementation

The `custom_example` folder provides a reference implementation that you can study and adapt for your own problem library. It demonstrates:

1. One way to organize problem files
2. How to implement the required functions

You are encouraged to examine the files in the `custom_example` folder to understand the implementation details and adapt them to your specific needs.

You may also want to view our website for more information on how to use OptiProfiler: www.optprof.com