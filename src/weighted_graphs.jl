using Graphs
using Random
using SparseArrays
using SimpleWeightedGraphs
using SimpleValueGraphs

"""
    DataGraph

Graph is stored in an adjacency list where neighbor and weigth are stored in a tuple.
"""

struct DataGraph{T<:Integer,U<:Real} <: AbstractGraph{T}
    fadjlist::Vector{Vector{Tuple{T,U}}}
end

DataGraph{T,U}(swg::SimpleWeightedGraph{T,U}) where {T<:Integer,U<:Real} = 
    DataGraph{T,U}([ [ (v,w) for (v,w) in incident(swg, u) ] for u in vertices(swg) ])

Graphs.is_directed(::Type{DataGraph{T,U}}) where {T<:Integer,U<:Real} = false

Graphs.nv(g::DataGraph) = length(g.fadjlist)

Graphs.ne(g::DataGraph) = div(sum(length.(g.fadjlist)),2)

Graphs.vertices(g::DataGraph) = 1:nv(g)

Graphs.edges(g::DataGraph) = [ SimpleWeightedEdge(u,v,w) for u in vertices(g) for (v,w) in incident(g, u) if u < v ]

function Graphs.has_edge(g::DataGraph, u::Integer, v::Integer)
    verts = vertices(g)
    (u in verts && v in verts) || return false  # edge out of bounds
    if degree(g, u) < degree(g, v)
        return insorted(v, outneighbors(g, u))
    else
        return insorted(u, outneighbors(g, v))
    end
end

Graphs.degree(g::DataGraph, u::Integer) = length(g.fadjlist[u])

incident(g::DataGraph, u::Integer) = g.fadjlist[u]

Graphs.outneighbors(g::DataGraph, u::Int) = DataGraphIterOutNeighbors(g, u)

#Graphs.weights(g::DataGraph) = sparse([u for u in vertices(g) for (v,w) in g.fadjlist[u]], [v for u in vertices(g) for (v,w) in g.fadjlist[u]], [w for u in vertices(g) for (v,w) in g.fadjlist[u]], nv(g), nv(g), +)
Graphs.weights(g::DataGraph) = transpose(sparse(transpose(sparse([u for u in vertices(g) for (v,w) in g.fadjlist[u]], [v for u in vertices(g) for (v,w) in g.fadjlist[u]], [w for u in vertices(g) for (v,w) in g.fadjlist[u]], nv(g), nv(g), +))))


struct DataGraphIterOutNeighbors{T<:Integer,U<:Real} <: AbstractVector{T}
    g::DataGraph{T,U}
    u::T
end

Base.size(gi::DataGraphIterOutNeighbors) = (degree(gi.g, gi.u),)

function Base.getindex(gi::DataGraphIterOutNeighbors, i::Integer)
#    1 <= i <= degree(gi.g, gi.u) || throw(BoundsError(DataGraphIterOutNeighbors, i))
    return gi.g.fadjlist[gi.u][i][1]
end


"""
    DataGraphSplit

Neighbors and weights are stored in two separate adjacency lists.
"""

struct DataGraphSplit{T<:Integer,U<:Real} <: AbstractGraph{T}
    fadjlist::Vector{Vector{T}}
    edge_data::Vector{Vector{U}}
end
DataGraphSplit{T,U}(swg::SimpleWeightedGraph{T,U}) where {T<:Integer,U<:Real} = 
DataGraphSplit{T,U}([ [ v for (v,w) in incident(swg, u) ] for u in vertices(swg) ], [ [ w for (v,w) in incident(swg, u) ] for u in vertices(swg) ])

Graphs.is_directed(::Type{DataGraphSplit{T,U}}) where {T<:Integer,U<:Real} = false

Graphs.nv(g::DataGraphSplit) = length(g.fadjlist)

Graphs.ne(g::DataGraphSplit) = div(sum(length.(g.fadjlist)),2)

Graphs.vertices(g::DataGraphSplit) = 1:nv(g)

Graphs.edges(g::DataGraphSplit) = [ SimpleWeightedEdge(u,v,w) for u in vertices(g) for (v,w) in incident(g, u) if u < v ]

function Graphs.has_edge(g::DataGraphSplit, s::Integer, d::Integer)
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        d = s
        list_s = list_d
    end
    return insorted(d, list_s)
end


Graphs.degree(g::DataGraphSplit, u::Integer) = length(g.fadjlist[u])        

incident(g::DataGraphSplit, u::Integer) = zip(g.fadjlist[u], g.edge_data[u])

Graphs.outneighbors(g::DataGraphSplit, u::Integer) = g.fadjlist[u]

Graphs.weights(g::DataGraphSplit) = sparse([u for u in vertices(g) for v in g.fadjlist[u]], [v for u in vertices(g) for v in g.fadjlist[u]], [w for u in vertices(g) for w in g.edge_data[u]], nv(g), nv(g), +)


"""
    incident(g, v)

Implement function incident for other types of graph.
"""

function incident(g::AbstractSimpleWeightedGraph, v::Integer)
    mat = g.weights
    indices = mat.colptr[v]:mat.colptr[v+1]-1
    return zip(view(mat.rowval, indices), view(mat.nzval, indices))
end

incident(g::ValGraph, u::Integer) = zip(g.fadjlist[u], g.edgevals[1][u])

Graphs.is_directed(::Type{ValGraph}) = false
