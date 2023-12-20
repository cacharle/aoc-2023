package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:container/queue"
import "core:slice"

Module :: struct {
    type: rune,  // either %, &, b (for broadcaster) or 'n' for nil
    label: string,
    destinations: []string,
    state: bool,
    previous_inputs: map[string]bool
}

PulseOn :: struct {
    pulse: bool,
    module: ^Module,
    from: string,
    singleton: string,
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    modules := map[string]Module{}
    defer delete(modules)
    for line in strings.split_lines_iterator(&s) {
        label, _, destinations_string := strings.partition(line, " -> ")
        m: Module
        if label != "broadcaster" {
            m.type = rune(label[0])
            label = label[1:]
        } else {
            m.type = rune(label[0])
        }
        m.label = label
        m.destinations = strings.split(destinations_string, ", ")
        m.state = false
        modules[label] = m
    }
    for label, m in modules {
        label :=label
        if m.type != '&' do continue
        for input_label, input_module in modules {
            if slice.any_of(input_module.destinations, label) {
                module_copy := modules[label]
                module_copy.previous_inputs[input_label] = false
                modules[label] = module_copy
            }
        }
    }
    // for _, m in modules do fmt.println(m)

    high_count := 0
    low_count := 0
    count_until_rx: int = -1
    for i in 1..=1000 {
        processing_queue: queue.Queue(PulseOn)
        queue.init(&processing_queue)
        defer queue.destroy(&processing_queue)
        queue.push_back(&processing_queue, PulseOn{false, &modules["broadcaster"], "button", ""})
        low_count += 1  // for the button press
        for queue.len(processing_queue) != 0 {
            pulse_on := queue.pop_front(&processing_queue)
            m := pulse_on.module
            pulse := pulse_on.pulse
            if m == nil {
                if pulse_on.singleton == "rx" {
                    // fmt.println(pulse_on)
                    if count_until_rx == -1 && !pulse {
                        count_until_rx = i
                        fmt.println("HERE")
                    }
                }
                continue
            }
            switch m.type {
            case '%':
                if !pulse {
                    m.state = !m.state
                    for d in m.destinations {
                        queue.push_back(&processing_queue, PulseOn{m.state, &modules[d] or_else nil, m.label, d})
                        if m.state { high_count += 1 } else { low_count += 1 }
                    }
                }
            case '&':
                m.previous_inputs[pulse_on.from] = pulse
                all_on := true
                for _, v in m.previous_inputs do if !v do all_on = false

                // if m.label == "con" {
                //     fmt.println(m.previous_inputs, all_on, m.destinations)
                // }
                for d in m.destinations {
                    queue.push_back(&processing_queue, PulseOn{!all_on, &modules[d] or_else nil, m.label, d})
                    if !all_on { high_count += 1 } else { low_count += 1 }
                }
            case 'b':
                for d in m.destinations {
                    queue.push_back(&processing_queue, PulseOn{pulse, &modules[d] or_else nil, m.label, d})
                    if pulse { high_count += 1 } else { low_count += 1 }
                }
            }
        }
        // break
    }
    fmt.println("part 1:", high_count * low_count)
    fmt.println("part 2:", count_until_rx)
}
