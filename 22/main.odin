package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Brick :: struct {
    start, end: [3]int,
}

position_3d_init :: proc(position: ^[3]int, s: ^string) {
    i := 0
    for elem in strings.split_iterator(s, ",") {
        position[i] = strconv.atoi(elem)
        i += 1
    }
}

bricks_collision :: proc(b1, b2: Brick) -> bool {
    b1_start_x := min(b1.start.x, b1.end.x)
    b1_start_y := min(b1.start.y, b1.end.y)
    b1_start_z := min(b1.start.z, b1.end.z)
    b1_end_x   := max(b1.start.x, b1.end.x)
    b1_end_y   := max(b1.start.y, b1.end.y)
    b1_end_z   := max(b1.start.z, b1.end.z)
    b2_start_x := min(b2.start.x, b2.end.x)
    b2_start_y := min(b2.start.y, b2.end.y)
    b2_start_z := min(b2.start.z, b2.end.z)
    b2_end_x   := max(b2.start.x, b2.end.x)
    b2_end_y   := max(b2.start.y, b2.end.y)
    b2_end_z   := max(b2.start.z, b2.end.z)
    for x1 in b1_start_x..=b1_end_x do for y1 in b1_start_y..=b1_end_y do for z1 in b1_start_z..=b1_end_z {
        for x2 in b2_start_x..=b2_end_x do for y2 in b2_start_y..=b2_end_y do for z2 in b2_start_z..=b2_end_z {
            if x1 == x2 && y1 == y2 && z1 == z2 do return true
        }
    }
    return false
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    bricks := [dynamic]Brick{}
    defer delete(bricks)
    for line in strings.split_lines_iterator(&s) {
        start_string, _, end_string := strings.partition(line, "~")
        brick: Brick
        position_3d_init(&brick.start, &start_string)
        position_3d_init(&brick.end, &end_string)
        append(&bricks, brick)
    }
    slice.sort_by_key(
        bricks[:],
        proc(b: Brick) -> int { return min(b.start.z, b.end.z) },
    )
    // for b in bricks do fmt.println(b)
    // fmt.println("---------------")
    for brick, i in bricks {
        candidate := brick
        fall_loop: for candidate.start.z >= 2 && candidate.end.z >= 2 {
            candidate.start.z -= 1
            candidate.end.z -= 1
            for other in bricks {
                if other == brick do continue
                if bricks_collision(candidate, other) {
                    bricks[i] = candidate
                    bricks[i].start.z += 1
                    bricks[i].end.z += 1
                    break fall_loop
                }
            }
        }
    }

    // for b in bricks do fmt.println(b)
    // fmt.println("---------------")

    valid_disintegrate := map[Brick]struct{}{}
    defer delete(valid_disintegrate)
    invalid_disintegrate := map[Brick]struct{}{}
    defer delete(invalid_disintegrate)
    for brick in bricks {
        // try going up once in z-axis, if no collision do disintegrate_count += 1
        temp := brick
        temp.start.z += 1
        temp.end.z += 1
        has_collisions_up := false
        for other in bricks {
            if other == brick do continue
            if bricks_collision(temp, other) do has_collisions_up = true
        }
        if !has_collisions_up do valid_disintegrate[brick] = {}
        // drop brick by one cube on z-axis
        // count collisions with other bricks
        //     if more than 1 collisions do disintegrate_count += collisions_count
        temp = brick
        temp.start.z -= 1
        temp.end.z -= 1
        collisions_bricks := [dynamic]Brick{}
        defer delete(collisions_bricks)
        for other in bricks {
            if other == brick do continue
            if bricks_collision(temp, other) do append(&collisions_bricks, other)
        }
        if len(collisions_bricks) > 1 {
            for b in collisions_bricks do valid_disintegrate[b] = {}
        } else {
            for b in collisions_bricks do invalid_disintegrate[b] = {}
        }
    }
    // fmt.println(len(valid_disintegrate), len(invalid_disintegrate))
    for b in invalid_disintegrate do delete_key(&valid_disintegrate, b)
    // for b in valid_disintegrate do fmt.println(b)
    fmt.println(len(valid_disintegrate))
    // 549: too high
    // 500: too high
    // 473: too low
    // 486: invalid
}
