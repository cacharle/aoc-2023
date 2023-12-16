package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

PositionDirection :: struct {
    pos: [2]int,
    direction: [2]int,
}

count_energized :: proc(
    visited: ^map[PositionDirection]struct{},
    energized: ^map[[2]int]struct{},
    contraption: [][]rune,
    pos: [2]int,
    direction: [2]int,
) {
    pos_dir := PositionDirection{pos, direction}
    if (pos_dir in visited) do return
    visited[pos_dir] = {}
    direction := direction
    if pos.x < 0 || pos.y < 0 || pos.x >= len(contraption[0]) || pos.y >= len(contraption) {
        return
    }
    energized[pos] = {}
    switch contraption[pos.y][pos.x] {
    case '.':
        count_energized(visited, energized, contraption, pos + direction, direction)
    case '/':
        switch direction {
        case { 1, 0}: direction = { 0, -1}
        case {-1, 0}: direction = { 0,  1}
        case {0,  1}: direction = {-1,  0}
        case {0, -1}: direction = { 1,  0}
        }
        count_energized(visited, energized, contraption, pos + direction, direction)
    case '\\':
        switch direction {
        case { 1, 0}: direction = { 0,  1}
        case {-1, 0}: direction = { 0, -1}
        case {0,  1}: direction = { 1,  0}
        case {0, -1}: direction = {-1,  0}
        }
        count_energized(visited, energized, contraption, pos + direction, direction)
    case '|':
        if direction.y != 0 {
            count_energized(visited, energized, contraption, pos + direction, direction)
            break
        }
        count_energized(visited, energized, contraption, pos + {0, -1}, {0, -1})
        count_energized(visited, energized, contraption, pos + {0, 1}, {0, 1})
    case '-':
        if direction.x != 0 {
            count_energized(visited, energized, contraption, pos + direction, direction)
            break
        }
        count_energized(visited, energized, contraption, pos + {-1, 0}, {-1, 0})
        count_energized(visited, energized, contraption, pos + {1, 0}, {1, 0})
    case:
        panic("unknown character")
    }
}

count_energized_wrap :: proc(contraption: [][]rune, pos, direction: [2]int) -> int {
    visited := map[PositionDirection]struct{}{}
    defer delete(visited)
    energized := map[[2]int]struct{}{}
    defer delete(energized)
    count_energized(&visited, &energized, contraption[:], pos, direction)
    return len(energized)
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    contraption := [dynamic][]rune{}
    defer delete(contraption)
    defer for row in contraption do delete(row)
    for line in strings.split_lines_iterator(&s) {
        append(&contraption, utf8.string_to_runes(line))
    }
    fmt.println("part 1:", count_energized_wrap(contraption[:], [2]int{0, 0}, [2]int{1, 0}))
    energized_max := 0
    for row, y in contraption {
        energized_max = max(
            energized_max,
            count_energized_wrap(contraption[:], [2]int{0, y}, [2]int{1, 0}),
            count_energized_wrap(contraption[:], [2]int{len(row) - 1, y}, [2]int{-1, 0})
        )
    }
    for _, x in contraption[0] {
        energized_max = max(
            energized_max,
            count_energized_wrap(contraption[:], [2]int{x, 0}, [2]int{0, 1}),
            count_energized_wrap(contraption[:], [2]int{x, len(contraption) - 1}, [2]int{0, -1})
        )
    }
    fmt.println("part 2:", energized_max)
}
