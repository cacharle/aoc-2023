package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

MAX_RED_CUBES   :: 12
MAX_GREEN_CUBES :: 13
MAX_BLUE_CUBES  :: 14

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    game_id_sum := 0
    game_powers_sum := 0
    i := 0
    for line in strings.split_lines_iterator(&s) {
        i += 1
        valid := true
        _, _, handfulls := strings.partition(line, ": ")
        red_max := 0
        green_max := 0
        blue_max := 0
        red_sum := 0
        green_sum := 0
        blue_sum := 0
        for handfull in strings.split_iterator(&handfulls, "; ") {
            handfull := handfull
            for cubes in strings.split_iterator(&handfull, ", ") {
                count_string, _, color := strings.partition(cubes, " ")
                count := strconv.atoi(count_string)
                max_count: int
                switch color {
                case "red":
                    max_count = MAX_RED_CUBES
                    red_max = max(red_max, count)
                case "green":
                    max_count = MAX_GREEN_CUBES
                    green_max = max(green_max, count)
                case "blue":
                    max_count = MAX_BLUE_CUBES
                    blue_max = max(blue_max, count)
                }
                if count > max_count do valid = false
            }
        }
        if valid do game_id_sum += i
        game_powers_sum += red_max * green_max * blue_max
    }
    fmt.println("part 1:", game_id_sum)
    fmt.println("part 2:", game_powers_sum)
}
