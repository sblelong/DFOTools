using DFOTools
using DelimitedFiles

export read_data, find_dimensions, compute_optimals, compute_initials

"""
Current state, to be modified to handle all kinds of data preprocessing.

Input: raw data of each evaluation
"""
function preprocess_data(raw_data::Matrix{<:Any})::Vector{Float64}
    n_evals = size(raw_data, 1)

    preprocessed_data = fill(typemax(Float64), n_evals)

    current_min = Inf

    for eval in 1:n_evals
        if typeof(raw_data[eval, end]) <: Real
            current_bbo_value = raw_data[eval, end]
            if current_bbo_value < current_min
                current_min = current_bbo_value
            end
        end
        preprocessed_data[eval] = current_min
    end

    return preprocessed_data
end

"""
    read_data(dir::String; mode::String="nomad", filename::String="history.0.txt")::Dict{Int,Array{Float64}}
"""
function read_data(dir::String; filename::String="history.0.txt")::Dict{Int,Vector{Float64}}
    files = readdir(dir)

    data = Dict{Int,Array{Float64}}()

    # For each instance
    for file in files
        # Intermediate table: will gather all the clean data
        raw_data = readdlm(joinpath(dir, file))
        preprocessed_data = preprocess_data(raw_data)
        data[parse(Int, splitext(file)[1])] = preprocessed_data
    end
    return data
end

function find_dimensions(dir::String; filename::String="history.0.txt")::Dict{Int,Int}
    files = readdir(dir)

    dimensions = Dict{Int,Int}()

    for file in files
        raw_data = readdlm(joinpath(dir, file, filename))
        dimensions[parse(Int, splitext(file)[1])] = size(raw_data, 2) - 1
    end

    return dimensions
end

function compute_optimals(data::Vector{Dict{Int,Vector{Float64}}})::Dict{Int,Float64}
    n_algs = length(data)
    n_instances = length(data[1])

    optimals = Dict{Int,Float64}()

    for instance in 1:n_instances
        algs_optimals = Float64[]
        for alg in 1:n_algs
            if instance in keys(data[alg])
                push!(algs_optimals, minimum(data[alg][instance]))
            end
        end

        if length(algs_optimals) ≥ 1
            optimals[instance] = minimum(algs_optimals)
        else
            optimals[instance] = typemax(Float64)
        end
    end

    return optimals
end

function compute_initials(data::Vector{Dict{Int,Vector{Float64}}})::Dict{Int,Float64}
    n_algs = length(data)
    n_instances = length(data[1])

    initials = Dict{Int,Float64}()

    for instance in 1:n_instances
        initials_algs = Float64[]
        for alg in 1:n_algs
            if instance in keys(data[alg])
                push!(initials_algs, data[alg][instance][1])
            end
        end
        if length(initials_algs) ≥ 1
            initials[instance] = minimum(initials_algs)
        else
            initials[instance] = typemax(Float64)
        end
    end

    return initials
end