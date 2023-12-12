package main

import "core:fmt"
import "core:os"
import "core:strings"

flood_fill :: proc(
    loop_tiles: map[[2]int]struct{},
    visited_tiles: map[[2]int]struct{},
    current: [2]int,
) {
    if current in loop_tiles || current in visited_tiles do return
    modifiers := [?][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
    for mod in modifiers {
        explored := current + mod
        flood_fill(loop_tiles, visited_tiles, explored)
    }
}

main :: proc() {
    data := os.read_entire_file("./example2") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    sketch := strings.split_lines(s)
    defer delete(sketch)
    start: [2]int
    for row, y in sketch do for tile, x in row do if tile == 'S' do start = {x, y}

    mod: [2]int
    current: [2]int
    if t := sketch[start.y - 1][start.x]; t == 'F' || t == '7' || t == '|' {
        current = {start.x, start.y - 1}
        if t == '|' do mod.y = -1
    }
    else if t := sketch[start.y + 1][start.x]; t == 'L' || t == 'J' || t == '|' {
        current = {start.x, start.y + 1}
        if t == '|' do mod.y = 1
    }
    else if t := sketch[start.y][start.x - 1]; t == '7' || t == 'J' || t == '-' {
        current = {start.x - 1, start.y}
        if t == '-' do mod.x = -1
    }
    else if t := sketch[start.y][start.x + 1]; t == 'L' || t == 'F' || t == '-' {
        current = {start.x + 1, start.y}
        if t == '-' do mod.x = 1
    }
    else do panic("invalid start tile")
    //          | direction  1 ^
    //          J
    //          7
    //          | direction -1 v
    loop := [dynamic][2]int{start}
    mods := [dynamic][2]int{mod}
    defer delete(loop)
    for current != start {
        append(&loop, current)
        switch sketch[current.y][current.x] {
        case '|': current.y += mod.y
        case '-': current.x += mod.x
        case '7': if mod.x ==  1 { current.y += 1; mod = {0,  1}} else { current.x -= 1; mod = {-1, 0}}
        case 'L': if mod.x == -1 { current.y -= 1; mod = {0, -1}} else { current.x += 1; mod = { 1, 0}}
        case 'J': if mod.x ==  1 { current.y -= 1; mod = {0, -1}} else { current.x -= 1; mod = {-1, 0}}
        case 'F': if mod.x == -1 { current.y += 1; mod = {0,  1}} else { current.x += 1; mod = { 1, 0}}
        case: panic("invalid tile")
        }
        append(&mods, mod)
    }
    // F------7
    // S----7I|OO
    //      |I|
    //      L-J
    //
    // ........
    // S----7|.
    // |IIII||.
    // L----J|.
    //
    fmt.println("part 1:", len(loop) / 2)
    // fmt.println(len(mods), len(loop))

    visited_tiles := map[[2]int]struct{}{}
    defer delete(visited_tiles)
    loop_tiles := make(map[[2]int]struct{}, len(loop))
    defer delete(loop_tiles)
    for tile in loop do loop_tiles[tile] = {}

    for tile, i in loop {
        mod := mods[i]
        flood_fill(loop_tiles, visited_tiles, tile)
    }
}
