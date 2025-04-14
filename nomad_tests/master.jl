seeds = 3000:1000:50000

function launch_solar()
    # run(`cd /home/sblelong/dev/DFOTools/nomad_tests/solar/EB`)
    for seed in seeds
        run(`mkdir $seed`; wait=false)
        param_file = "/home/sblelong/dev/DFOTools/nomad_tests/solar/param.txt"
        (tmppath, tmpio) = mktemp()
        open(param_file) do io
            for line in eachline(io, keep=true)
                if startswith(line, "BB_EXE")
                    line = "BB_EXE \"\$/home/sblelong/dev/solar/bin/solar \$1 \$-seed=$seed\"\n"
                elseif startswith(line, "BB_OUTPUT_TYPE")
                    println("Modifying output")
                    println(line)
                    line = "BB_OUTPUT_TYPE OBJ EB EB EB EB EB\n"
                    println(line)
                elseif startswith(line, "STATS_FILE")
                    line = "STATS_FILE \"/home/sblelong/dev/DFOTools/nomad_tests/solar/EB/$seed/stats.txt\" BBE OBJ BBO\n"
                end
                write(tmpio, line)
            end
        end
        close(tmpio)
        mv(tmppath, param_file, force=true)
        run(`/home/sblelong/dev/nomad/build/release/src/nomad /home/sblelong/dev/DFOTools/nomad_tests/solar/param.txt`; wait=true)
    end
end