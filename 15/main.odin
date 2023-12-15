package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

hash :: proc(s: string) -> int {
    current := 0
    for c in transmute([]u8)s {
        current += int(c)
        current *= 17
        current %= 256
    }
    return current
}

Lens :: struct {
    label: string,
    focal_length: int,
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    boxes := [256][dynamic]Lens{}
    defer for slot in boxes do delete(slot)
    part1_sum := 0
    for command in strings.split_iterator(&s, ",") {
        part1_sum += hash(command)
        if command[len(command) - 1] == '-' {
            label := command[:len(command) - 1]
            slot := &boxes[hash(label)]
            for lens, i in slot {
                if lens.label == label {
                    ordered_remove(slot, i);
                    break
                }
            }
        }
        else {
            label, _, focal_length_string := strings.partition(command, "=")
            slot := &boxes[hash(label)]
            inserted_lens := Lens{label, strconv.atoi(focal_length_string)}
            found := false
            for lens, i in slot {
                if lens.label == label {
                    slot[i] = inserted_lens
                    found = true
                }
            }
            if !found {
                append(slot, inserted_lens)
            }
        }
    }
    part2_sum := 0
    for slot, i in boxes {
        for lens, j in slot {
            part2_sum += (i + 1) * (j + 1) * lens.focal_length
        }
    }
    fmt.println("part 1:", part1_sum)
    fmt.println("part 2:", part2_sum)
}
