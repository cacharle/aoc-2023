package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:math"

distances_sum :: proc(
    galaxies: [][2]int,
    expanded_row_indices,
    expanded_col_indices: []int,
    expansion_factor: int,
) -> int {
    sum := 0
    for galaxy1, i in galaxies {
        for galaxy2 in galaxies[i + 1:] {
            expanded_row_between_count := 0
            expanded_col_between_count := 0
            y_min := math.min(galaxy1.y, galaxy2.y)
            x_min := math.min(galaxy1.x, galaxy2.x)
            y_max := math.max(galaxy1.y, galaxy2.y)
            x_max := math.max(galaxy1.x, galaxy2.x)
            for index in expanded_row_indices {
                if index > y_min && index < y_max do expanded_row_between_count += 1
            }
            for index in expanded_col_indices {
                if index > x_min && index < x_max do expanded_col_between_count += 1
            }
            dist := (
                math.abs(galaxy1.x - galaxy2.x)
                + expanded_col_between_count * (expansion_factor - 1)
                + math.abs(galaxy1.y - galaxy2.y)
                + expanded_row_between_count * (expansion_factor - 1)
            )
            sum += dist
        }
    }
    return sum
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)

    image := [dynamic][dynamic]rune{}
    defer delete(image)
    defer for r in image do delete(r)
    for line in strings.split_lines_iterator(&s) {
        append(&image, [dynamic]rune{})
        for r in line do append(&image[len(image) - 1], r)
    }
    expanded_row_indices := [dynamic]int{}
    defer delete(expanded_row_indices)
    for row, i in image {
        if slice.all_of(row[:], '.') do append(&expanded_row_indices, i)
    }
    expanded_col_indices := [dynamic]int{}
    defer delete(expanded_col_indices)
    for _, j in image[0] {
        col := make([]rune, len(image))
        defer delete(col)
        for _, i in image do col[i] = image[i][j]
        if slice.all_of(col[:], '.') do append(&expanded_col_indices, j)
    }

    galaxies := [dynamic][2]int{}
    defer delete(galaxies)
    for row, y in image do for c, x in row do if c == '#' do append(&galaxies, [2]int{x, y})

    fmt.println("part 1:", distances_sum(galaxies[:], expanded_row_indices[:], expanded_col_indices[:], expansion_factor = 2))
    fmt.println("part 2:", distances_sum(galaxies[:], expanded_row_indices[:], expanded_col_indices[:], expansion_factor = 1_000_000))
}
