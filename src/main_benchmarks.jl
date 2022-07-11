function benchmark_graphs_algorithms(algorithms, graphs, precompilation, test = (_,_)->nothing)
    println("Benchmarking a graph on $(nv(graphs[1][2])) vertices and $(ne(graphs[1][2])) edges.")

    if precompilation
        result_first = nothing
        for (ai, (an, a)) in enumerate(algorithms)
            println("Precompiling: ", an)
            for (gi, (gn, g)) in enumerate(graphs)
                @time result = a(g)
                if ai == gi == 1
                    result_first = result
                else
                    test(result_first, result)
                end
            end
        end
    end

    df = DataFrame(algorihms = [ n for (n,_) in algorithms ])

    for (gi, (gn, g)) in enumerate(graphs)
        println("Running algorithms for graph ", gn)
        times = String[]
        result_first = result = nothing

        for (ai, (an, a)) in enumerate(algorithms)
            println("Benchmarking $an on $gn")
            time = @benchmark $a($g)
            display(time)
            push!(times, BenchmarkTools.prettytime(median(time).time))
            println()
            println()
        end

        df[!,gn] = times
    end

    println(df)
    return df
end

function benchmark_graphset_algorithms(edges_sources, algorithms, test = (_,_)->nothing)
    results = []

    for (i,sources) in enumerate(edges_sources)
        graphs = create_graph_from_edge_list(sources())
        df = benchmark_graphs_algorithms(algorithms, graphs, i==1, test)
        push!(results, (df, nv(graphs[1][2]), ne(graphs[1][2])))        
    end

    println("\nSummary:")
    for (df, n, m) in results
        println("\nGraph on $n vertices and $m edges:")
        show(df, eltypes=false, summary=false, allrows=true, allcols=true, show_row_number=false)
        println()
    end
end

function benchmark_unweighed_algorithms()
    edges_sources = [
        () -> load_edges_from_dimacs_format("../dimacs9/USA-road-d.NY.gr"),
        () -> load_edges_from_dimacs_format("../dimacs9/USA-road-d.LKS.gr"),
#        () -> load_edges_from_dimacs_format("../dimacs9/USA-road-d.USA.gr"), # Requires ~ 10GB RAM"
        () -> load_edges_from_dimacs_format("../4tu_chordal/chordal-varNodes-214,211,1.dimacs"),
        () -> load_edges_from_dimacs_format("../4tu_chordal/chordal-varNodes-3125,211,1.dimacs"),
        () -> random_dense_weighted_graph(100),
        () -> random_dense_weighted_graph(5000)
    ]

    algorithms = [
        ("Connectivity", g->connected_components(g)),
        ("Articulation", g->articulation(g)),
        ("Bridges", g->bridges(g)),
        ("Dominating set", g->dominating_set(g, MinimalDominatingSet())),
        ("Vertex cover", g->vertex_cover(g, RandomVertexCover())),
    ]

    benchmark_graphset_algorithms(edges_sources, algorithms)
end
