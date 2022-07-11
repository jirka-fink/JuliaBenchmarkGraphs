function bellman_ford_shortest_paths_incident(graph::AbstractGraph, sources::AbstractVector{<:Integer})
    nvg = nv(graph)
    active = falses(nvg)
    active[sources] .= true
    dists = fill(typemax(Int), nvg)
    parents = zeros(Int, nvg)
    dists[sources] .= 0
    no_changes = false
    new_active = falses(nvg)

    for i in vertices(graph)
        no_changes = true
        new_active .= false
        for u in vertices(graph)[active]
            for (v,w) in incident(graph, u)
                relax_dist = w + dists[u]
                if dists[v] > relax_dist
                    dists[v] = relax_dist
                    parents[v] = u
                    no_changes = false
                    new_active[v] = true
                end
            end
        end
        if no_changes
            break
        end
        active, new_active = new_active, active
    end
    no_changes || throw(NegativeCycleError())
    return Graphs.BellmanFordState(parents, dists)
end

function bellman_ford_test(state1, state2)
    @assert all(state1.dists .== state2.dists)
end

function benchmark_bellman_ford()
    edges_sources = [
        () -> load_edges_from_dimacs_format("../dimacs9/USA-road-d.NY.gr"),
        () -> load_edges_from_dimacs_format("../dimacs9/USA-road-d.LKS.gr"),
        () -> random_dense_weighted_graph(100),
        () -> random_dense_weighted_graph(3000),
    ]

    algorithms = [
        ("original", g -> bellman_ford_shortest_paths(g, [1]))
        ("incident", g -> bellman_ford_shortest_paths_incident(g, [1]))
    ]

    benchmark_graphset_algorithms(edges_sources, algorithms, bellman_ford_test)
end