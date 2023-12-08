package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:math"

Neighbours :: struct {
    left: string,
    right: string,
}

step_for_label :: proc(
    nodes: map[string]Neighbours,
    instructions: string,
    current_label: string,
    end_predicate: proc(string) -> bool,
) -> int {
    current_label := current_label
    step_count := 0
    for !end_predicate(current_label) {
        for instruction in instructions {
            if instruction == 'L' do current_label = nodes[current_label].left
            if instruction == 'R' do current_label = nodes[current_label].right
            step_count += 1
            if end_predicate(current_label) do break
        }
    }
    return step_count
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    instructions, _, nodes_string := strings.partition(s, "\n\n")
    nodes := map[string]Neighbours{}
    defer delete(nodes)
    for line in strings.split_lines_iterator(&nodes_string) {
        label, _, neighbours_string := strings.partition(line, " = ")
        left, _, right := strings.partition(neighbours_string, ", ")
        left = left[1:]
        right = right[:len(right) - 1]
        nodes[label] = Neighbours{left, right}
    }

    step_count := step_for_label(
        nodes,
        instructions,
        "AAA",
        proc(l: string) -> bool { return l == "ZZZ" },
    )
    fmt.println("part 1:", step_count)

    current_labels := [dynamic]string{}
    defer delete(current_labels)
    for label in nodes do if label[2] == 'A' do append(&current_labels, label)
    step_total_count := 1
    for current_label, i in current_labels {
        current_label := current_label
        step_count := step_for_label(
            nodes,
            instructions,
            current_label,
            proc(l: string) -> bool { return l[2] == 'Z' },
        )
        step_total_count = math.lcm(step_total_count, step_count)
    }
    fmt.println("part 2:", step_total_count)
}
