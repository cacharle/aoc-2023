package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"

Command :: struct {
    direction: rune,
    meters: int,
    color: string,
}

main :: proc() {
    data := os.read_entire_file("example_simpler") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    commands := [dynamic]Command{}
    for line in strings.split_lines_iterator(&s) {
        direction, _, rest := strings.partition(line, " ")
        meters_string, _, color := strings.partition(rest, " ")
        assert(len(direction) == 1)
        append(
            &commands,
            Command{rune(direction[0]), strconv.atoi(meters_string), strings.trim(color, "()")},
        )
    }
    vertices := make([][2]int, len(commands))
    vertices[0] = {0, 0}
    up_sum := 0
    down_sum := 0
    left_sum := 0
    right_sum := 0
    for command, i in commands[:len(commands) - 1] {
        command := command
        // if i < 2 {
        //     command.meters -= 1
        // }
        vertices[i + 1] = vertices[i]
        switch command.direction {
        case 'U': vertices[i + 1].y -= command.meters; up_sum += command.meters
        case 'D': vertices[i + 1].y += command.meters; down_sum += command.meters
        case 'L': vertices[i + 1].x -= command.meters; left_sum += command.meters
        case 'R': vertices[i + 1].x += command.meters; right_sum += command.meters
        case: panic("invalid direction")
        }
    }
    fmt.println(vertices)
    // vertices = vertices[:len(vertices) - ]

    // min_x := 10000000
    // min_y := 10000000
    // max_x := -10000000
    // max_y := -10000000
    // for vertex in vertices {
    //     min_x = min(min_x, vertex.x)
    //     min_y = min(min_y, vertex.y)
    //     max_x = max(min_x, vertex.x)
    //     max_y = max(min_y, vertex.y)
    // }
    // for y in min_y..=max_y {
    //     for x in min_x..=max_x {
    //         for v in vertices {
    //         }
    //     }
    // }

    // #####
    // #   #
    // #   ##
    // #    #
    // ######

    area := 0
    for vertex, i in vertices {
        next := vertices[(i + 1) % len(vertices)]
        fmt.println("[", vertex, ",", next, "],")
        // area += (next.x + vertex.x) * (next.y - vertex.y)
        area += vertex.x * next.y
        area -= vertex.y * next.x
    }
    // area = abs(area) / 2
    // 92282: too high

    // fmt.println(area - (up_sum + down_sum + right_sum + left_sum) / 2 - 3)
    // fmt.println(area + 1 - (38) / 2)
    fmt.println(area)
}
