package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:thread"
import "core:c"
import "core:simd"

RangeMapping :: struct {
    source: int,
    destination: int,
    length: int,
}

mappings := [dynamic][dynamic]RangeMapping{}

location :: proc(n: int) -> int {
    n := n
    for mapping in mappings {
        for range in mapping {
            using range
            if n >= source && n < source + length {
                n = destination + math.abs(source - n)
                break
            }
        }
    }
    return n
}

// simd implementation: 15s faster
location_min :: proc(start, length: int) -> int {
    lowest_location: i64 = c.INT64_MAX
    start := start
    length := length
    for ; length % 8 != 0 && length > 0; length -= 1 {
        lowest_location = math.min(lowest_location, i64(location(start + length - 1)))
    }
    setup := simd.i64x8{0, 1, 2, 3, 4, 5, 6, 7}
    for n := start; n < start + length; n += 8 {
        ns: simd.i64x8 = i64(n)
        ns += setup
        for mapping in mappings {
            already_mapped: simd.u64x8
            for range in mapping {
                s: simd.i64x8 = i64(range.source)
                d: simd.i64x8 = i64(range.destination)
                l: simd.i64x8 = i64(range.length)
                mask := simd.and_not(simd.lanes_ge(ns, s) & simd.lanes_lt(ns, s + l), already_mapped)
                if simd.reduce_or(mask) == 0 do continue
                ns = simd.select(mask , d + simd.abs(s - ns), ns)
                already_mapped = already_mapped | mask
                if simd.reduce_and(already_mapped) != 0 do break
            }
        }
        lowest_location = math.min(lowest_location, simd.reduce_min(ns))
    }
    return int(lowest_location)
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(2)
    defer delete(data)
    s := string(data)
    seed_line, _, rest := strings.partition(s, "\n")
    seed_line = seed_line[7:]
    seeds_strings := strings.split(seed_line, " ")
    defer delete(seeds_strings)
    seeds := make([]int, len(seeds_strings))
    defer delete(seeds)
    for s, i in seeds_strings do seeds[i] = strconv.atoi(s)
    defer delete(mappings)
    defer for m in mappings do delete(m)

    for line in strings.split_lines_iterator(&rest) {
        if line == "" {
            append(&mappings, [dynamic]RangeMapping{})
            continue
        }
        if strings.contains(line, "map:") do continue
        destition_s, _, rest := strings.partition(line, " ")
        source_s, _, length_s := strings.partition(rest, " ")
        source := strconv.atoi(source_s)
        destination := strconv.atoi(destition_s)
        length := strconv.atoi(length_s)
        append(&mappings[len(mappings) - 1], RangeMapping{source, destination, length})
    }

    lowest_location := 0x7fffffffffffffff
    for n in seeds {
        lowest_location = math.min(lowest_location, location(n))
    }
    fmt.println("part 1:", lowest_location)

    // Took 2min18s to complete on i5-12600 (fuck trying to be smart) (single thread)
    // multithreaded is 36s
    pool: thread.Pool
    thread.pool_init(&pool, context.allocator, len(seeds) / 2)
    defer thread.pool_destroy(&pool)
    thread.pool_start(&pool)
    TaskData :: struct {
        start: int,
        length: int,
        lowest_location: int,
    }
    for i := 0; i < len(seeds); i += 2 {
        data := new(TaskData)
        data.start = seeds[i]
        data.length = seeds[i + 1]
        data.lowest_location = 0x7fffffffffffffff
        thread.pool_add_task(
            &pool,
            context.allocator,
            proc(t: thread.Task) {
                data := transmute(^TaskData)t.data
                using data
                lowest_location = location_min(start, length)
                // for n in start..<(start + length) {
                //     lowest_location = math.min(lowest_location, location(n))
                // }
            },
            data,
        )
    }
    thread.pool_finish(&pool)
    lowest_location = 0x7fffffffffffffff
    for {
        task, ok := thread.pool_pop_done(&pool)
        if !ok do break
        data := transmute(^TaskData)task.data
        lowest_location = math.min(lowest_location, data.lowest_location)
        free(data)
    }
    fmt.println("part 2:", lowest_location)
}
