package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:strconv"
import "core:unicode/utf8"
import "core:math"
import "core:time"

arrangements_count :: proc "fast" (
    springs: []rune,
    records: []int,
    previous_operational_count: int = 0,
) -> int {
    springs := springs
    // if slice.count(springs, '#') > math.sum(records) do return 0
    if len(records) == 0 {
        for s in springs do if s == '#' do return 0
        return 1
    }
    if previous_operational_count > records[0] do return 0
    // if previous_operational_count + slice.count(springs, '#') + slice.count(springs, '?') < math.sum(records) {
    //     return 0
    // }

    if len(springs) == 0 {
        if records[0] == previous_operational_count {
            return arrangements_count(springs[:], records[1:])
        }
        return 0
    }

    switch springs[0] {
    case '.':
        if records[0] == previous_operational_count {
            return arrangements_count(springs[1:], records[1:])
        }
        if previous_operational_count == 0 {
            return arrangements_count(springs[1:], records)
        }
    case '#':
        return arrangements_count(springs[1:], records, previous_operational_count + 1)
    case '?':
        unknown_count := 0
        for s in springs {
            if s == '?' do break
            unknown_count += 1
        }
        // handle can't be contiguous: just objects-(len(records) - 1)
        // ????  1,1
        // #?#?  1,1
        // ?#?#  1,1
        // #??#  1,1

        // ?????  1,1,1
        // #?#??  1,1
        // ?#?#?  1,1
        // #??#?  1,1
        // #???#  1,1
        // ?#??#  1,1
        // ??#?#  1,1

        // ?????  1,1,1
        // #?#?#  1,1,1

        // if unknown_count > 2 && records[0] == 1 {
        //     combinations := factorial(unknown_count) / factorial()
        // }
        springs[0] = '#'
        // c1 := arrangements_count(springs, records, previous_operational_count)
        c1 := arrangements_count(springs[1:], records, previous_operational_count + 1)
        springs[0] = '.'
        c2 := arrangements_count(springs, records, previous_operational_count)
        springs[0] = '?'
        return c1 + c2
    }
    return 0
}

main :: proc() {
    data := os.read_entire_file("./input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    sum := 0
    for line in strings.split_lines_iterator(&s) {
        // line := "??#??.???#?. 1,3,2"
        springs, _, records_string := strings.partition(line, " ")
        if springs == "???????????#???" do continue
        // if springs != "????.######..#####." do continue
        records_split := strings.split(records_string, ",")
        defer delete(records_split)
        records := slice.mapper(
            records_split,
            proc(s: string) -> int { return strconv.atoi(s) },
        )
        defer delete(records)
        o := utf8.string_to_runes(springs)
        xs := make([][]rune, 5)
        for i in 0..<5 {
            xs[i] = make([]rune, len(o) + 1)
            copy(xs[i], o)
            xs[i][len(xs[i]) - 1] = '?'
        }
        unfolded_springs := slice.concatenate(xs)
        unfolded_springs = unfolded_springs[:len(unfolded_springs) - 1]

        unfolded_records := make([]int, 5 * len(records))
        for _, i in unfolded_records do unfolded_records[i] = records[i % len(records)]
        // fmt.println(unfolded_springs, unfolded_records)

        stopwatch := time.Stopwatch{}
        time.stopwatch_start(&stopwatch)
        fmt.println(springs, records)
        sum = arrangements_count(unfolded_springs, unfolded_records)
        time.stopwatch_stop(&stopwatch)
        fmt.println("time:", time.stopwatch_duration(stopwatch), sum)
        time.stopwatch_reset(&stopwatch)
        fmt.println("-----------------------")
        // sum += arrangements_count(o, o, records)
        // break
    }
    // too high: 7572
    fmt.println("part 1:", sum)
}
