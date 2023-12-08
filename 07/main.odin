package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:unicode/utf8"

CARD_RANK := [?]rune{
    '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A',
}
CARD_RANK_JOKER := [?]rune{
    'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A',
}

Hand :: struct {
    cards: []rune,
    bid: int,
}

CardsType :: enum {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
}

hand_type :: proc(cards: []rune) -> CardsType {
    cards_counts := map[rune]int{}
    defer delete(cards_counts)
    for card in cards {
        cards_counts[card] = (cards_counts[card] or_else 0) + 1
    }
    cs := slice.map_values(cards_counts) or_else os.exit(1)
    defer delete(cs)
    if len(cs) == 1 && cs[0] == 5 {
        return .FiveOfAKind
    }
    if len(cs) == 2 && (cs[0] == 4 || cs[1] == 4) {
        return .FourOfAKind
    }
    if len(cs) == 2 {
        return .FullHouse
    }
    if len(cs) == 3 && slice.any_of(cs, 3) {
        return .ThreeOfAKind
    }
    if len(cs) == 3 {
        return .TwoPair
    }
    if len(cs) == 4 {
        return .OnePair
    }
    return .HighCard
}

hand_type_joker :: proc(cards: []rune) -> CardsType {
    joker_count := slice.count(cards, 'J')
    if joker_count == 5 || joker_count == 4 { // to avoid 13 ** 5 combinations
        return .FiveOfAKind
    }
    replacement_cards: []rune = nil
    replacement_cards_type: CardsType = .HighCard
    for c, i in cards {
        if c != 'J' do continue
        for replacement in CARD_RANK_JOKER[1:] {
            cards[i] = replacement
            t := hand_type_joker(cards)
            if t >= replacement_cards_type {
                if replacement_cards != nil do delete(replacement_cards)
                replacement_cards = slice.clone(cards)
                replacement_cards_type = t
            }
            cards[i] = 'J'
        }
    }
    defer delete(replacement_cards)
    t := hand_type(cards)
    if replacement_cards != nil && replacement_cards_type > t {
        return replacement_cards_type
    }
    return t
}

current_card_rank: []rune
current_hand_type_func: proc([]rune) -> CardsType

rank_sum :: proc(hands: []Hand) -> int {
    slice.sort_by(hands[:], proc(h1, h2: Hand) -> bool {
        h1_cards_type := current_hand_type_func(h1.cards)
        h2_cards_type := current_hand_type_func(h2.cards)
        if h1_cards_type != h2_cards_type {
            return h1_cards_type < h2_cards_type
        }
        for c1, i in h1.cards {
            if c1 != h2.cards[i] {
                c1_rank := slice.linear_search(current_card_rank, c1) or_else os.exit(1)
                c2_rank := slice.linear_search(current_card_rank, h2.cards[i]) or_else os.exit(1)
                return c1_rank < c2_rank
            }
        }
        assert(false)
        return true
    })
    sum := 0
    for h, i in hands {
        sum += (i + 1) * h.bid
    }
    return sum
}

main :: proc() {
    data := os.read_entire_file("input") or_else os.exit(1)
    defer delete(data)
    s := string(data)
    hands := [dynamic]Hand{}
    defer delete(hands)
    defer for h in hands do delete(h.cards)
    for line in strings.split_lines_iterator(&s) {
        hand, _, bid_string := strings.partition(line, " ")
        append(&hands, Hand{utf8.string_to_runes(hand), strconv.atoi(bid_string)} )
    }
    // Can't capture local variables in local functions so I have to use globals
    current_card_rank = CARD_RANK[:]
    current_hand_type_func = hand_type
    fmt.println("part 1:", rank_sum(hands[:]))
    current_card_rank = CARD_RANK_JOKER[:]
    current_hand_type_func = hand_type_joker
    fmt.println("part 2:", rank_sum(hands[:]))
}
