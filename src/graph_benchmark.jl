module GraphBenchmark

using Graphs
using SimpleWeightedGraphs
using SimpleValueGraphs
using Random
using SparseArrays
using BenchmarkTools
using DataFrames

include("weighted_graphs.jl")
include("weighted_graph_generators.jl")
include("main_benchmarks.jl")
include("bellman_ford.jl")

end
