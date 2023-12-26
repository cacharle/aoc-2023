package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math/linalg"
import "core:math/big"

Hailstone :: struct {
    position, velocity: [3]f64
}

TEST_AREA_MIN :: 7
TEST_AREA_MAX :: 27
// TEST_AREA_MIN :: 200000000000000
// TEST_AREA_MAX :: 400000000000000

main :: proc() {
    data := os.read_entire_file("example") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    hailstones := [dynamic]Hailstone{}
    defer delete(hailstones)
    for line in strings.split_lines_iterator(&s) {
        position_string, _, velocity_string := strings.partition(line, " @ ")
        hailstone: Hailstone
        i := 0
        for n in strings.split_iterator(&position_string, ",") {
            hailstone.position[i] = f64(strconv.atoi(strings.trim_space(n)))
            i += 1
        }
        i = 0
        for n in strings.split_iterator(&velocity_string, ",") {
            hailstone.velocity[i] = f64(strconv.atoi(strings.trim_space(n)))
            i += 1
        }
        append(&hailstones, hailstone)
    }
    intersect_inside_count := 0
    for h1, i in hailstones {
        h1_next := h1
        h1_next.position += h1_next.velocity
        for h2 in hailstones[i+1:] {
            h2_next := h2
            h2_next.position += h2_next.velocity
            x1 := h1.position.x
            x2 := h1_next.position.x
            y1 := h1.position.y
            y2 := h1_next.position.y
            x3 := h2.position.x
            x4 := h2_next.position.x
            y3 := h2.position.y
            y4 := h2_next.position.y

            // not an overflow error, see python implementation (python as builtin big floats)
            p: [2]f64
            p.x = ((x1*y2 - y1*x2) * (x3-x4) - (x1-x2) * (x3*y4 - y3*x4)) /
                ((x1-x2) * (y3-y4) - (y1-y2) * (x3-x4))
            p.y = ((x1*y2 - y1*x2) * (y3-y4) - (y1-y2) * (x3*y4 - y3*x4)) /
                ((x1-x2) * (y3-y4) - (y1-y2) * (x3-x4))

            // fmt.println(
            //     p.x,
            //     p.y,
            // //    // p.y,linalg.dot(h1.velocity.xy, p - h1.position.xy) > 0 &&
            // //    // linalg.dot(h2.velocity.xy, p - h2.position.xy) > 0 )
            //     linalg.dot(h1.velocity.xy, p - h1.position.xy),
            //     linalg.dot(h2.velocity.xy, p - h2.position.xy),
            // )

            if p.x >= TEST_AREA_MIN &&
               p.y >= TEST_AREA_MIN &&
               p.x <= TEST_AREA_MAX &&
               p.y <= TEST_AREA_MAX &&
               linalg.dot(h1.velocity.xy, p - h1.position.xy) > 0 &&
               linalg.dot(h2.velocity.xy, p - h2.position.xy) > 0 {
                // fmt.println("INSIDE")
                intersect_inside_count += 1
            }
        }
    }
    fmt.println(intersect_inside_count)
    // 16936: too low
}

        // hailstone_min := hailstone
        // hailstone_max := hailstone
        // for hailstone_max.position.x >= 7 &&
        //     hailstone_max.position.y >= 7 &&
        //     hailstone_max.position.x <= 27 &&
        //     hailstone_max.position.y <= 27 {
        //     hailstone_max.position += hailstone.velocity
        // }
