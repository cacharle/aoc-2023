package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    sequences := [dynamic][dynamic]int{}
    defer delete(sequences)
    for line in strings.split_lines_iterator(&s) {
        line := line
        append(&sequences, [dynamic]int{})
        for number_string in strings.split_iterator(&line, " ") {
            append(&sequences[len(sequences) - 1], strconv.atoi(number_string))
        }
        append(&sequences[len(sequences) - 1], 0)
        inject_at(&sequences[len(sequences) - 1], 0, 0)
    }
    previous_sum := 0
    next_sum := 0
    for sequence in sequences {
        differences := [dynamic][dynamic]int{}
        defer delete(differences)
        defer for ds in differences do delete(ds)
        append(&differences, sequence)
        for !slice.all_of(differences[len(differences) - 1][:], 0) {
            ds := [dynamic]int{}
            up := slice.last(differences[:])
            for i in 1..<(len(up) - 2) {
                append(&ds, up[i + 1] - up[i])
            }
            append(&ds, 0)
            inject_at(&ds, 0, 0)
            append(&differences, ds)
        }
        #reverse for ds, i in differences[:len(differences) - 1] {
            bot := differences[i + 1]
            ds[0] = ds[1] - bot[0]
            ds[len(ds) - 1] = ds[len(ds) - 2] + bot[len(bot) - 1]
        }
        previous_sum += differences[0][0]
        next_sum += slice.last(differences[0][:])
    }
    fmt.println("part 1:", next_sum)
    fmt.println("part 2:", previous_sum)
}
