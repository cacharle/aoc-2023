package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

INFINITY :: 0x7fffffffffffffff
UNDEFINED :: -10

main :: proc() {
    data := os.read_entire_file("example_simpler") or_else os.exit(1)
    defer delete(data)
    s := string(data)

    city_map := [dynamic][]int{}
    defer delete(city_map)
    defer for row in city_map do delete(row)
    for line in strings.split_lines_iterator(&s) {
        row := make([]int, len(line))
        for c, i in line do row[i] = int(c - '0')
        append(&city_map, row)
    }

    distances := map[[2]int]int{}
    defer delete(distances)
    distances[{0, 0}] = 0
    unvisited := make(map[[2]int]struct{}, len(city_map) * len(city_map[0]))
    defer delete(unvisited)
    for row, y in city_map do for _, x in row do unvisited[{x, y}] = {}
    previous := map[[2]int][dynamic][2]int{}
    append(&previous[{UNDEFINED, UNDEFINED}], [2]int{UNDEFINED, UNDEFINED})
    append(&previous[{0, 0}], [2]int{UNDEFINED, UNDEFINED})
    // TODO: find how to add to a dynamic array in a map
    fmt.println(previous)

    for len(unvisited) != 0 {
        current_min := INFINITY
        current := [2]int{UNDEFINED, UNDEFINED}
        for block in unvisited {
            dist := (distances[block] or_else INFINITY)
            if dist < current_min {
                current_min = dist
                current = block
            }
        }
        if current == {UNDEFINED, UNDEFINED} do break
        // fmt.println(current, current_min, len(unvisited))
        // fmt.println(unvisited)
        delete_key(&unvisited, current)
        // fmt.println(">>", current, distances[current])

        mods := [?][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
        for mod in mods {
            neighbour := current + mod
            if (
                neighbour.x < 0 ||
                neighbour.y < 0 ||
                neighbour.x >= len(city_map[0]) ||
                neighbour.y >= len(city_map)
                // neighbour not_in unvisited
            ) {
                continue
            }

            all_previous_are_straight_lines :: proc(
                previous: map[[2]int][dynamic][2]int,
                previous_nodes: [][2]int,
                node: [2]int,
                depth: int,
            ) -> bool {
                if depth <= 0 do return false
                fmt.println(node, depth, previous_nodes)
                if len(previous_nodes) == 0 do return false
                ret := true
                for p in previous_nodes {
                    fmt.println(p)
                    if p.x == UNDEFINED {
                        ret = false
                        continue
                    }
                    if p.x - node.x == 0 && abs(p.y - node.y) != depth do ret = false
                    if p.y - node.y == 0 && abs(p.x - node.x) != depth do ret = false
                    all_previous_are_straight_lines(previous, previous[p][:], node, depth - 1)
                }
                return ret
            }
            if all_previous_are_straight_lines(previous, previous[current][:], current, 3) {
                fmt.println("ehll")
                continue
            }

            // third_previous := previous[previous[previous[current]]]
            // if (
            //     third_previous.x != UNDEFINED &&
            //     third_previous.x - neighbour.x == 0 &&
            //     abs(third_previous.y - neighbour.y) == 4
            // ) {
            //     continue
            // }
            // if (
            //     third_previous.y != UNDEFINED &&
            //     third_previous.y - neighbour.y == 0 &&
            //     abs(third_previous.x - neighbour.x) == 4
            // ) {
            //     continue
            // }

            // Why current version is taking the wrong path sometimes:
            // if we have two possible ways to a block but one of them is wrong
            // according to the 'at most 3 block in the same direction' rule,
            // if it assumes it's wrong it won't try to discover the shorter
            // way.
            //  s>>>
            //  v  v
            //  v>>v <-- this one has 2 ways to it
            //     v
            //     d

            update := distances[current] + city_map[neighbour.y][neighbour.x]
            if update <= (distances[neighbour] or_else INFINITY) {
                distances[neighbour] = update
                if update < (distances[neighbour] or_else INFINITY) {
                    clear(&previous[neighbour])
                }
                append(&previous[neighbour], current)
            }
            fmt.println(previous[neighbour])
        }
        // for key, d in distances do if key in unvisited do fmt.print(key, d, "| ")
        // fmt.println()
    }

    // 1382: too high
    // fmt.println(previous[{2, 1}])
    p := [2]int{len(city_map[0]) - 1, len(city_map) - 1}
    best_path := [dynamic][2]int{}
    // total_heat_loss := 0
    // for p != {0, 0} {
    //     // total_heat_loss += city_map[p.y][p.x]
    //     // fmt.println(p, previous[p])
    //     append(&best_path, p)
    //     p = previous[p][0]
    // }
    // fmt.println("total_heat_loss:", total_heat_loss)
    append(&best_path, p)
    for row, y in city_map {
        for block, x in row {
            f := false
            for b in best_path {
                if b.y == y && b.x == x do f = true
            }
            if f {
                fmt.print(".")
            } else {
                fmt.print(block)
            }
        }
        fmt.println()
    }
    fmt.println("min distance:", distances[{len(city_map[0]) - 1, len(city_map) - 1}])
    fmt.println(distances[{len(city_map[0]) - 2, len(city_map) - 1}])
    fmt.println(distances[{len(city_map[0]) - 1, len(city_map) - 2}])
}
