package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

parse_numbers_line :: proc(input: string) -> ([]int, int) {
    _, _, line := strings.partition(input, ":")
    line = strings.trim_space(line)
    strings_with_empties := strings.split(line, " ")
    defer delete(strings_with_empties)
    numbers_strings := slice.filter(strings_with_empties, proc(s: string) -> bool { return len(s) != 0 })
    defer delete(numbers_strings)
    single_number_string := strings.concatenate(numbers_strings)
    defer delete(single_number_string)
    n := strconv.atoi(single_number_string)
    ns := make([]int, len(numbers_strings))
    for s, i in numbers_strings do ns[i] = strconv.atoi(s)
    return ns, n
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    lines := strings.split_lines(s)
    defer delete(lines)
    times, single_time := parse_numbers_line(lines[0])
    defer delete(times)
    distances, single_distance := parse_numbers_line(lines[1])
    defer delete(distances)
    assert(len(distances) == len(times))

    margin_of_error := 1
    for time, i in times {
        win_possibility_count := 0
        for try_time in 0..=time {
            speed := try_time
            time_to_move := time - try_time
            travelled_millimeters := speed * time_to_move
            if travelled_millimeters > distances[i] do win_possibility_count += 1
        }
        margin_of_error *= win_possibility_count
    }
    fmt.println("part 1:", margin_of_error)

    win_possibility_count := 0
    for try_time in 0..=single_time {
        speed := try_time
        time_to_move := single_time - try_time
        travelled_millimeters := speed * time_to_move
        if travelled_millimeters > single_distance do win_possibility_count += 1
    }
    fmt.println("part 2:", win_possibility_count)
}
