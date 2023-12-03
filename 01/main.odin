package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode"

get_first_digit :: proc(s: string) -> (int, int) {
    for c, i in s {
        if unicode.is_digit(c) {
            return int(c - '0'), i
        }
    }
    return 0, -1
}

calibration_value_part1 :: proc(line: string) -> int {
    first, _ := get_first_digit(line)
    r := strings.reverse(line)
    defer delete(r)
    last, _ := get_first_digit(r)
    return first * 10 + last
}

SPELLED_DIGITS :: [?]string{
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
}

calibration_value_part2 :: proc(line: string) -> int {
    first_digit, first_digit_position := get_first_digit(line)
    r := strings.reverse(line)
    defer delete(r)
    last_digit, last_digit_position := get_first_digit(r)
    if last_digit_position != -1 {
        last_digit_position = len(line) - last_digit_position
    }
    first_spelled: string
    last_spelled: string
    first_spelled_position: int = 100000
    last_spelled_position: int = -100000
    for spelled in SPELLED_DIGITS {
        first_position := strings.index(line, spelled)
        last_position := strings.last_index(line, spelled)
        if first_position != -1 && first_position < first_spelled_position {
            first_spelled = spelled
            first_spelled_position = first_position
        }
        if last_position != -1 && last_position > last_spelled_position {
            last_spelled = spelled
            last_spelled_position = last_position
        }
    }
    first: int
    last: int
    if first_digit_position != -1 && first_digit_position < first_spelled_position {
        first = first_digit
    } else {
        for spelled, i in SPELLED_DIGITS {
            if first_spelled == spelled {
                first = i + 1
            }
        }
    }
    if last_digit_position != -1 && last_digit_position > last_spelled_position {
        last = last_digit
    } else {
        for spelled, i in SPELLED_DIGITS {
            if last_spelled == spelled {
                last = i + 1
            }
        }
    }
    return first * 10 + last
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    sum1 := 0
    sum2 := 0
    for line in strings.split_iterator(&s, "\n") {
        sum1 += calibration_value_part1(line)
        sum2 += calibration_value_part2(line)
    }
    fmt.println("part 1:", sum1)
    fmt.println("part 2:", sum2)
}
