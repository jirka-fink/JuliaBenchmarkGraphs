# Return a list of triples: two end-vertices and weight
function random_dense_weighted_graph(n::Int; rng=MersenneTwister(0))
    # Random points in a plane
    pos = [ (rand(rng, -10000:10000), rand(rng, -10000:10000)) for _ in 1:n ]
    # Distance of two points is d*log(d+2)+1 where d is their Euclidean distance.
    # The log-factor ensures that long edges do not need to be on shortest paths
    dist(i, j, d = sqrt(sum((pos[i] .- pos[j]) .^ 2))) = ceil(Int, d * log(d+2))+1
    return [ (i,j,dist(i,j)) for i in 1:n for j in i+1:n ]
end


function load_edges_from_dimacs_format(filename::String)
    return [(u,v,w) for line in eachline(filename) if line[1] == 'a' for (u,v,w) in (tuple(parse.(Int, split(line)[2:4])...),) if u < v]
end

function create_graph_from_edge_list(all_edges)
    swg = SimpleWeightedGraph([ x[1] for x in all_edges ], [ x[2] for x in all_edges ], [ x[3] for x in all_edges ]; combine = max)
    dg = DataGraph{Int,Int}(swg)
    dgs = DataGraphSplit{Int,Int}(swg)
    svg = ValGraph{Int}(nv(swg), edgeval_types = (Int,))
    for e in edges(swg)
        u,v = src(e),dst(e)
        w = get_weight(swg, u, v)
        add_edge!(svg, u, v, (w,))
    end

    return [
        ("SimpleWeightedGraph", swg),
        ("DataGraph", dg),
        ("DataGraphSplit", dgs),
        ("SimpleValueGraphs", svg),
    ]
end
