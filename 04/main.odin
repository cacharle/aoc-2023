package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:math"

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)

    lines := strings.split_lines(s)
    defer delete(lines)
    cards_counts := make([]int, len(lines) - 1)
    defer delete(cards_counts)
    slice.fill(cards_counts, 1)

    total_points := 0
    for line, i in lines {
        if line == "" do continue
        line := line[8:]
        winning_numbers_string, _, numbers_string := strings.partition(line, " | ")
        spaces := [?]string{"  ", " "}
        winning_numbers := strings.split_multi(winning_numbers_string, spaces[:])
        numbers := strings.split_multi(numbers_string, spaces[:])
        defer delete(winning_numbers)
        defer delete(numbers)

        win_count: uint = 0
        for wn in winning_numbers {
            for n in numbers {
                if n == wn {
                    win_count += 1
                }
            }
        }
        for _ in 0..<cards_counts[i] {
            for card_index in (i + 1)..<(i + 1 + int(win_count)) {
                cards_counts[card_index] += 1
            }
        }

        total_points += (1 << win_count) >> 1
    }
    fmt.println("part 1:", total_points)
    fmt.println("part 2:", math.sum(cards_counts))
}
