package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"
import "core:slice"

Direction :: enum {
    DirectionNorth,
    DirectionWest,
    DirectionSouth,
    DirectionEast,
}

roll :: proc(row: []rune) {
    rounded_count := 0
    top := 0
    for x, i in row {
        switch x {
        case '.': continue
        case 'O': rounded_count += 1
        case '#':
            slice.fill(row[top + rounded_count:i], '.')
            slice.fill(row[top :top+rounded_count], 'O')
            rounded_count = 0
            top = i + 1
        }
    }
    slice.fill(row[top + rounded_count:], '.')
    slice.fill(row[top :top+rounded_count], 'O')
}

roll_direction :: proc(platform: [][]rune,  direction: Direction) {
    col := make([]rune, len(platform))
    defer delete(col)
    switch direction {
    case .DirectionNorth:
        for _, i in platform {
            for _, j in col do col[j] = platform[j][i]
            roll(col)
            for _, j in col do platform[j][i] = col[j]
        }
    case .DirectionWest:
        for row in platform do roll(row)
    case .DirectionSouth:
        for _, i in platform {
            for _, j in col do col[j] = platform[j][i]
            slice.reverse(col)
            roll(col)
            slice.reverse(col)
            for _, j in col do platform[j][i] = col[j]
        }
    case .DirectionEast:
        for row in platform {
            slice.reverse(row)
            roll(row)
            slice.reverse(row)
        }
    }
}

total_load :: proc(platform: [][]rune) -> int {
    sum := 0
    col := make([]rune, len(platform))
    defer delete(col)
    for _, i in platform {
        for _, j in col do col[j] = platform[j][i]
        for x, i in col {
            if x == 'O' do sum += len(col) - i
        }
    }
    return sum
}

platform_delete :: proc(platform: [][]rune) {
    for row in platform do delete(row)
    delete(platform)
}

PlatformWithLoad :: struct {
    platform: [][]rune,
    total_load: int,
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    platform := [dynamic][]rune{}
    defer platform_delete(platform[:])
    for line in strings.split_lines_iterator(&s) {
        append(&platform, utf8.string_to_runes(line));
    }
    roll_direction(platform[:],  .DirectionNorth)
    fmt.println("part 1:", total_load(platform[:]))

    // shift 1bil back to 0 by doing minus pattern start
    // modulo that by the length of the pattern
    // then shift it back by adding pattern start
    //     V v    v
    // 17393 1234 1
    // 17393 1234 1234 1234 1234 1234        x
    //                                       ^
    //                                      1bil
    previous_east_platforms := [dynamic]PlatformWithLoad{}
    defer delete(previous_east_platforms)
    defer for p in previous_east_platforms do platform_delete(p.platform)
    loop: for i in 0..<1_000_000_000 {
        for direction in Direction do roll_direction(platform[:], direction)

        for previous, j in previous_east_platforms {
            found_in_previous := true
            for row, i in platform {
                if !slice.equal(row, previous.platform[i]) do found_in_previous = false
            }
            if found_in_previous {
                load := previous_east_platforms[j + (1_000_000_000-1 - j) % (i-j)].total_load
                fmt.println("part 2:", load)
                break loop
            }
        }
        platform_clone := make([][]rune, len(platform))
        for row, i in platform do platform_clone[i] = slice.clone(row)
        append(
            &previous_east_platforms,
            PlatformWithLoad{platform_clone, total_load(platform_clone)},
        )
    }
}
