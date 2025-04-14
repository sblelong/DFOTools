export evaluate_solar_problem

using DelimitedFiles

function evaluate_solar_problem(pb_name::String, x)
    # Write x as a .txt file
    run(Cmd(`mkdir tmp`, dir="/home/sblelong/"))
    open("/home/sblelong/tmp/x.txt", "w") do io
        write(io, join(x, " "))
    end

    p = pipeline(ignorestatus(`/home/sblelong/dev/solar/bin/solar $pb_name /home/sblelong/tmp/x.txt`); stdout="/home/sblelong/tmp/f.txt")
    run(p; wait=true)

    result = readdlm("/home/sblelong/tmp/f.txt")
    run(Cmd(`rm -rf tmp`, dir="/home/sblelong/"))
    return result
end