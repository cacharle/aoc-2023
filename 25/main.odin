package main

import "core:fmt"
import "core:os"
import "core:strings"

Components :: map[string]map[string]struct{}

has_multiple_groups :: proc(components: Components) -> bool {
    rec :: proc(
        components: Components,
        current: string,
        visited: ^map[string]struct{},
    ) {
        if current in visited do return
        visited[current] = {}
        assert(current in components)
        for neighbour in components[current] {
            rec(components, neighbour, visited)
        }
    }
    visited := map[string]struct{}{}
    defer delete(visited)
    start: string
    for c in components {
        start = c
        break
    }
    rec(components, start, &visited)
    return len(visited) != len(components)
}


main :: proc() {
    data := os.read_entire_file("example") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    components := Components{}
    defer delete(components)
    defer for _, c in components do delete(c)
    for line in strings.split_lines_iterator(&s) {
        origin, _, connections := strings.partition(line, ": ")
        for conn in strings.split_iterator(&connections, " ") {
            v := components[origin]
            v[conn] = {}
            components[origin] = v
            v = components[conn]
            v[origin] = {}
            components[conn] = v
        }
    }
    // for c, n in components do fmt.println(c, n)
    // fmt.println(has_multiple_groups(components))
    for c1 in components do for c2 in components do for c3 in components {
        if c1 == c2 || c1 == c3 || c2 == c3 do continue
        components_clone := new_clone(components)
        defer delete(components_clone^)
        // delete_key(components_clone[c1,
    }
}
