using DFOTools
using DelimitedFiles

export read_data, find_dimensions

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
        raw_data = readdlm(joinpath(dir, file, filename))
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