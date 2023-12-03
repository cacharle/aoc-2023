package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:unicode"

Position :: struct {
    y: int,
    x: int,
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)

    lines := strings.split_lines(s)
    defer delete(lines)
    parts_positions := [dynamic]Position{}
    defer delete(parts_positions)
    gears_positions := map[Position]struct{}{}
    defer delete(gears_positions)

    for line, y in lines {
        for c, x in line {
            if c != '.' && !unicode.is_digit(c) {
                append(&parts_positions, Position{y, x})
                if c == '*' do gears_positions[Position{y, x}] = {}
            }
        }
    }
    sum: uint = 0
    sum_gears: uint = 0
    visited := map[Position]struct{}{}
    defer delete(visited)
    for position in parts_positions {
        gear_numbers := [dynamic]uint{}
        defer delete(gear_numbers)
        for y_modifier in -1..=1 {
            for x_modifier in -1..=1 {
                if x_modifier == 0 && y_modifier == 0 do continue
                y := position.y + y_modifier
                x := position.x + x_modifier
                if (
                    y >= 0 && y < len(lines) &&
                    x >= 0 && x < len(lines[0]) &&
                    unicode.is_digit(rune(lines[y][x])) &&
                    Position{y, x} not_in visited
                ) {
                    digits := [dynamic]u8{lines[y][x] - '0'}
                    defer delete(digits)
                    visited[Position{y, x}] = {}
                    for i in (x + 1)..<len(lines[0]) {
                        if !unicode.is_digit(rune(lines[y][i])) || (Position{y, i} in visited) do break
                        visited[Position{y, i}] = {}
                        inject_at(&digits, 0, lines[y][i] - '0')
                    }
                    for i := x - 1; i >= 0; i -= 1 {
                        if !unicode.is_digit(rune(lines[y][i])) || (Position{y, i} in visited) do break
                        visited[Position{y, i}] = {}
                        append(&digits, lines[y][i] - '0')
                    }
                    num: uint = 0
                    #reverse for digit in digits {
                        num *= 10
                        num += uint(digit)
                    }
                    sum += num
                    if position in gears_positions {
                        append(&gear_numbers, num)
                    }
                }
            }
        }
        if len(gear_numbers) == 2 {
            sum_gears += gear_numbers[0] * gear_numbers[1]
        }
    }
    fmt.println("part 1:", sum)
    fmt.println("part 2:", sum_gears)
}
