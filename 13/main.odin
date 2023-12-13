package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:math"
import "core:unicode/utf8"
import "core:slice"

// part 1
mirror_at :: proc(pattern: [][]rune) -> int {
    for row, i in pattern[:len(pattern) - 1] {
        is_mirror := true
        for j := 0; i - j >= 0 && i + j + 1 < len(pattern); j += 1 {
            if !slice.equal(pattern[i - j], pattern[i + j + 1]) {
                is_mirror = false
                break
            }
        }
        if is_mirror do return i + 1
    }
    return 0
}

// part 2
flip :: proc(c: ^rune) -> rune {
    c^ = (c^ == '#') ? '.' : '#'
    return c^
}

smudge_match :: proc(row, top, bot: []rune) -> bool {
    for _, k in row {
        flip(&row[k])
        defer flip(&row[k])
        if slice.equal(top, bot) do return true
    }
    return false
}

smudge_mirror_at :: proc(pattern: [][]rune) -> int {
    for row, i in pattern[:len(pattern) - 1] {
        is_mirror := true
        smudge_found := false
        for j := 0; i - j >= 0 && i + j + 1 < len(pattern); j += 1 {
            top := pattern[i - j]
            bot := pattern[i + j + 1]
            if !smudge_found && smudge_match(top, top, bot) || smudge_match(bot, top, bot) {
                smudge_found = true
                continue
            }
            if !slice.equal(top, bot) {
                is_mirror = false
                break
            }
        }
        if is_mirror && smudge_found do return i + 1
    }
    return 0
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(2)
    defer delete(data)
    s := string(data)
    pattern := [dynamic][]rune{}
    defer delete(pattern)
    sum := 0
    smudge_sum := 0
    for line in strings.split_lines_iterator(&s) {
        if line != "" {
            append(&pattern, utf8.string_to_runes(line))
            continue
        }
        pattern_transpose := make([][]rune, len(pattern[0]))
        defer delete(pattern_transpose)
        defer for row in pattern_transpose do delete(row)
        for _, i in pattern_transpose {
            pattern_transpose[i] = make([]rune, len(pattern))
            for _, j in pattern_transpose[i] do pattern_transpose[i][j] = pattern[j][i]
        }
        sum += 100 * mirror_at(pattern[:]) + mirror_at(pattern_transpose[:])
        smudge_sum += 100 * smudge_mirror_at(pattern[:]) + smudge_mirror_at(pattern_transpose[:])
        for row in pattern do delete(row)
        clear(&pattern)
    }
    fmt.println("part 1:", sum)
    fmt.println("part 2:", smudge_sum)
}
