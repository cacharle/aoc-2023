package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"
import "core:slice"

main :: proc() {
    // fmt.println(-1 %% 10)
    data := os.read_entire_file("example") or_else os.exit(1)
    defer delete(data)
    s := string(data)

    garden := [dynamic][]rune{}
    defer delete(garden)
    defer for row in garden do delete(row)
    for line in strings.split_lines_iterator(&s) {
        append(&garden, utf8.string_to_runes(line))
    }
    start: [2]int
    for row, y in garden do for tile, x in row do if tile == 'S' do start = {x, y}
    mods := [?][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

    {
        // part 1
        current_tiles := map[[2]int]struct{}{}
        current_tiles[start] = {}
        for _ in 0..<64 {
            current_tiles_update := map[[2]int]struct{}{}
            for tile in current_tiles {
                for mod in mods {
                    neighbour := tile + mod
                    if neighbour.x < 0 ||
                       neighbour.y < 0 ||
                       neighbour.x >= len(garden[0]) ||
                       neighbour.y >= len(garden) ||
                       garden[neighbour.y][neighbour.x] == '#' {
                        continue
                    }
                    current_tiles_update[neighbour] = {}
                }
            }
            delete(current_tiles)
            current_tiles = current_tiles_update
        }
        fmt.println("part 1:", len(current_tiles))
    }

    {
        // part 2
        current_tiles := map[[2]int]int{}
        current_tiles[start] = 1
        for _ in 0..<10 {
            current_tiles_update := map[[2]int]int{}
            for row, y in garden do for tile_value, x in row {
                tile := [2]int{x, y}
                if tile_value == '#' do continue
                max_count := 0
                outside_count := 0
                for mod in mods {
                    neighbour := tile + mod
                    original := neighbour
                    neighbour.x %%= len(garden[0])
                    neighbour.y %%= len(garden)
                    if garden[neighbour.y][neighbour.x] == '#' do continue
                    neighbour_count := current_tiles[neighbour] or_else 0
                    if original != neighbour {
                        // TODO: when and how to handle when we need to +1 for new garden containing this tile
                        // outside_count += neighbour_count//max(outside_count, neighbour_count)
                        max_count = max(max_count, neighbour_count)
                    } else {
                        max_count = max(max_count, neighbour_count)
                    }
                }
                current_tiles_update[tile] = max_count + outside_count
                // fmt.println(outside_count)
            }
            delete(current_tiles)
            current_tiles = current_tiles_update
        }
        // for t, v in current_tiles do if v > 0 do fmt.print(t, ",")
        // fmt.println()
        // fmt.println(len(current_tiles))
        sum := 0
        for _, c in current_tiles do sum += c
        fmt.println("part 2:", sum)

        counter := 0
        for row, y in garden {
            for tile, x in row {
                if tile == '.' do counter += 1
                is_possible := false
                for t, c in current_tiles {
                    if (t == [2]int{x, y}) && c > 0 do is_possible = true
                }
                if is_possible { fmt.print('O') } else { fmt.print(tile) }
            }
            fmt.println()
        }
        fmt.println(counter)
    }

    // fmt.println(current_tiles)
}
