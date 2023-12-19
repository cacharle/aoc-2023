package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Rule :: struct {
    rating_label: string,
    condition: rune,
    condition_value: int,
    jump: string,
}

Part :: struct {
    x: int,
    m: int,
    a: int,
    s: int,
}

PartRange :: struct {
    x_start: int,
    m_start: int,
    a_start: int,
    s_start: int,
    x_end: int,
    m_end: int,
    a_end: int,
    s_end: int,
}

count_accepted :: proc(
    workflows: ^map[string][dynamic]Rule,
    current_label: string,
    part_range: PartRange,
) -> int {
    assert(part_range.x_end > part_range.x_start)
    assert(part_range.m_end > part_range.m_start)
    assert(part_range.a_end > part_range.a_start)
    assert(part_range.s_end > part_range.s_start)
    part_range := part_range
    if current_label == "R" do return 0
    if current_label == "A" {
        return (
            (part_range.x_end - part_range.x_start + 1) *
            (part_range.m_end - part_range.m_start + 1) *
            (part_range.a_end - part_range.a_start + 1) *
            (part_range.s_end - part_range.s_start + 1)
        )
    }
    count := 0
    for rule in workflows[current_label] {
        if rule.rating_label == "" {
            return count + count_accepted(workflows, rule.jump, part_range)
        }
        switch rule.rating_label {
        case "x":
            if rule.condition == '<' {
                part_range_bellow := part_range
                part_range_bellow.x_end = rule.condition_value - 1
                count += count_accepted(workflows, rule.jump, part_range_bellow)
                part_range.x_start = rule.condition_value
            }
            else if rule.condition == '>' {
                part_range_above := part_range
                part_range_above.x_start = rule.condition_value + 1
                count += count_accepted(workflows, rule.jump, part_range_above)
                part_range.x_end = rule.condition_value
            }
        case "m":
            if rule.condition == '<' {
                part_range_bellow := part_range
                part_range_bellow.m_end = rule.condition_value - 1
                count += count_accepted(workflows, rule.jump, part_range_bellow)
                part_range.m_start = rule.condition_value
            }
            else if rule.condition == '>' {
                part_range_above := part_range
                part_range_above.m_start = rule.condition_value + 1
                count += count_accepted(workflows, rule.jump, part_range_above)
                part_range.m_end = rule.condition_value
            }
        case "a":
            if rule.condition == '<' {
                part_range_bellow := part_range
                part_range_bellow.a_end = rule.condition_value - 1
                count += count_accepted(workflows, rule.jump, part_range_bellow)
                part_range.a_start = rule.condition_value
            }
            else if rule.condition == '>' {
                part_range_above := part_range
                part_range_above.a_start = rule.condition_value + 1
                count += count_accepted(workflows, rule.jump, part_range_above)
                part_range.a_end = rule.condition_value
            }
        case "s":
            if rule.condition == '<' {
                part_range_bellow := part_range
                part_range_bellow.s_end = rule.condition_value - 1
                count += count_accepted(workflows, rule.jump, part_range_bellow)
                part_range.s_start = rule.condition_value
            }
            else if rule.condition == '>' {
                part_range_above := part_range
                part_range_above.s_start = rule.condition_value + 1
                count += count_accepted(workflows, rule.jump, part_range_above)
                part_range.s_end = rule.condition_value
            }
        case: panic("unknown field")
        }
    }
    panic("undefined")
}


apply_rule :: proc(rule: Rule, part: Part) -> (string, bool) {
    switch rule.rating_label {
    case "x":
        if      rule.condition == '<' && part.x < rule.condition_value { return rule.jump, true }
        else if rule.condition == '>' && part.x > rule.condition_value { return rule.jump, true }
    case "m":
        if      rule.condition == '<' && part.m < rule.condition_value { return rule.jump, true }
        else if rule.condition == '>' && part.m > rule.condition_value { return rule.jump, true }
    case "a":
        if      rule.condition == '<' && part.a < rule.condition_value { return rule.jump, true }
        else if rule.condition == '>' && part.a > rule.condition_value { return rule.jump, true }
    case "s":
        if      rule.condition == '<' && part.s < rule.condition_value { return rule.jump, true }
        else if rule.condition == '>' && part.s > rule.condition_value { return rule.jump, true }
    }
    return "", false
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)


    workflows := map[string][dynamic]Rule{}
    defer delete(workflows)
    defer for name in workflows do delete(workflows[name])
    for line in strings.split_lines_iterator(&s) {
        if line == "" do break
        name, _, rules := strings.partition(line, "{")
        rules = strings.trim(rules, "}")
        workflows[name] = [dynamic]Rule{}
        for rule in strings.split_iterator(&rules, ",") {
            rating_condition, collon, jump := strings.partition(rule, ":")
            if collon == ":" {
                rating_label, condition, condition_value: string
                if strings.index(rating_condition, "<") != -1 {
                    rating_label, condition, condition_value = strings.partition(rating_condition, "<")
                } else {
                    rating_label, condition, condition_value = strings.partition(rating_condition, ">")
                }
                append(
                    &workflows[name],
                    Rule{rating_label, rune(condition[0]), strconv.atoi(condition_value), jump},
                )
            } else {
                // rating_condition is the jump label in this case
                append(
                    &workflows[name],
                    Rule{"", 0, -1, rating_condition},
                )
            }
        }
    }
    parts := [dynamic]Part{}
    defer delete(parts)
    for line in strings.split_lines_iterator(&s) {
        line := strings.trim(line, "{}")
        part: Part
        for rating in strings.split_iterator(&line, ",") {
            rating_label, _, rating_value := strings.partition(rating, "=")
            switch rating_label {
            case "x": part.x = strconv.atoi(rating_value)
            case "m": part.m = strconv.atoi(rating_value)
            case "a": part.a = strconv.atoi(rating_value)
            case "s": part.s = strconv.atoi(rating_value)
            case: panic("invalid rating label")
            }
        }
        append(&parts, part)
    }

    sum := 0
    for part in parts {
        current_label := "in"
        for current_label != "A" && current_label != "R" {
            for rule in workflows[current_label] {
                if rule.rating_label == "" {
                    current_label = rule.jump
                    break
                }
                if label, ok := apply_rule(rule, part); ok {
                    current_label = label
                    break
                }
            }
        }
        if current_label == "A" {
            sum += part.x + part.a + part.m + part.s
        }
    }
    fmt.println("part 1:", sum)

    count := count_accepted(&workflows, "in", PartRange{1, 1, 1, 1, 4000, 4000, 4000, 4000})
    fmt.println("part 2:", count)
}
