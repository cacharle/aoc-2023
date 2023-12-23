package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

    // for row, y in forest {
    //     for tile, x in row {
    //         if ([2]int{x, y} in visited) {
    //             fmt.print('O')
    //         } else {
    //             fmt.print(tile)
    //         }
    //     }
    //     fmt.println()
    // }
    // fmt.println("-----------------------")

INFINITY :: 0x7fffffffffffffff

invalid_tile :: proc(forest: [][]rune, current: [2]int) -> bool {
    return (
        current.x < 0 ||
        current.y < 0 ||
        current.x >= len(forest[0]) ||
        current.y >= len(forest) ||
        forest[current.y][current.x] == '#'
    )
}

// TODO: maybe try to make this function faster with "contextless" or a visited that is a static array and doesn't require any allocations
dfs :: proc(
    forest: [][]rune,
    current,
    end: [2]int,
    visited: ^map[[2]int]struct{},
) -> int {
    if current == end do return 0
    if invalid_tile(forest, current) || current in visited do return 0
    visited[current] = {}
    switch forest[current.y][current.x] {
    case '^': return 1 + dfs(forest, current + { 0, -1}, end, visited)
    case 'v': return 1 + dfs(forest, current + { 0,  1}, end, visited)
    case '<': return 1 + dfs(forest, current + {-1,  0}, end, visited)
    case '>': return 1 + dfs(forest, current + { 1,  0}, end, visited)
    }
    max_path_length := 0
    mods := [?][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
    for mod in mods {
        neighbour := current + mod
        if  invalid_tile(forest, neighbour) || neighbour in visited do continue
        visited_clone := make(map[[2]int]struct{}, len(visited))
        defer delete(visited_clone)
        for k, v in visited do visited_clone[k] = v
        max_path_length = max(max_path_length, dfs(forest, neighbour, end, &visited_clone))
    }
    return 1 + max_path_length
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    forest := [dynamic][]rune{}
    defer delete(forest)
    defer for row in forest do delete(row)
    for line in strings.split_lines_iterator(&s) {
        append(&forest, utf8.string_to_runes(line))
    }
    start: [2]int
    for tile, x in forest[0] do if tile == '.' do start = {x, 0}
    end: [2]int
    for tile, x in forest[len(forest) - 1] do if tile == '.' do end = {x, len(forest) - 1}
    {
        visited := map[[2]int]struct{}{}
        defer delete(visited)
        max_path_length := dfs(forest[:], start, end, &visited)
        fmt.println("part 1:", max_path_length)
    }

    // NOTE: maybe Dijkstra for longest path wasn't a good idea after all
    // distances := map[[2]int]int{}
    // defer delete(distances)
    // distances[start] = 0
    // unvisited := make(map[[2]int]struct{}, len(forest) * len(forest[0]))
    // defer delete(unvisited)
    // for row, y in forest do for tile, x in row do if tile != '#' do unvisited[{x, y}] = {}
    // for len(unvisited) != 0 {
    //     current_max := -1
    //     current: [2]int
    //     for pos in unvisited {
    //         d := distances[pos] or_else -1
    //         if d > current_max {
    //             current_max = d
    //             current = pos
    //         }
    //     }
    //     delete_key(&unvisited, current)
    //     // fmt.println(current, distances)
    //     mods := [?][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
    //     for mod in mods {
    //         neighbour := current + mod
    //         if invalid_tile(forest[:], neighbour) /*|| neighbour not_in unvisited*/ do continue
    //         dist := distances[current] + 1
    //         if dist > (distances[neighbour] or_else -1) {
    //             distances[neighbour] = dist
    //         }
    //     }
    // }
    // fmt.println(distances[end])
    // 4986: too low
}
