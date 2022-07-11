# JuliaBenchmarkGraphs

The goal of this repository is to provide benchmarking for various representation of weighted graphs in Julia.

# Initialization

First, download and unpack the following datasets:

* https://data.4tu.nl/articles/dataset/Network_instance_Chordal_fixed_treewidth_edition_1/12697523/1 into directory 4tu_chordal
* http://www.diag.uniroma1.it//challenge9/download.shtml into directory dimacs9
* Run `include("graph_benchmark.jl")` in directory src

# Benchmarks

* `GraphBenchmark.benchmark_bellman_ford()`: Bellman-Ford for finding shortest paths
* `GraphBenchmark.benchmark_unweighed_algorithm()`: Some algorithms not using weights
* 