import copy

# TEST_AREA_MIN = 7
# TEST_AREA_MAX = 27
TEST_AREA_MIN = 200000000000000
TEST_AREA_MAX = 400000000000000


def main():
    hailstones = []
    with open("input") as f:
        for line in f.read().splitlines():
            position, _, velocity = line.partition(" @ ")
            hailstones.append(
                (
                    [float(s.strip()) for s in position.split(",")],
                    [float(s.strip()) for s in velocity.split(",")],
                )
            )
    intersect_count = 0
    for i, (h1_position, h1_velocity) in enumerate(hailstones):
        h1_next_position = copy.deepcopy(h1_position)
        h1_next_position[0] += h1_velocity[0]
        h1_next_position[1] += h1_velocity[1]
        for h2_position, h2_velocity in hailstones[i + 1 :]:
            h2_next_position = copy.deepcopy(h2_position)
            h2_next_position[0] += h2_velocity[0]
            h2_next_position[1] += h2_velocity[1]
            x1 = h1_position[0]
            x2 = h1_next_position[0]
            y1 = h1_position[1]
            y2 = h1_next_position[1]
            x3 = h2_position[0]
            x4 = h2_next_position[0]
            y3 = h2_position[1]
            y4 = h2_next_position[1]
            # print(h1_position, h1_velocity)
            # print(h1_next_position)
            # print(h2_position, h2_velocity)
            # print(h2_next_position)
            # print("-----------")

            try:
                p = [0, 0]
                p[0] = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / (
                    (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
                )
                p[1] = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / (
                    (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
                )
            except ZeroDivisionError:
                continue
            # print(p)

            diff1 = copy.deepcopy(p)
            diff1[0] -= h1_position[0]
            diff1[1] -= h1_position[1]
            diff2 = copy.deepcopy(p)
            diff2[0] -= h2_position[0]
            diff2[1] -= h2_position[1]

            dot1 = h1_velocity[0] * diff1[0] + h1_velocity[1] * diff1[1]
            dot2 = h2_velocity[0] * diff2[0] + h2_velocity[1] * diff2[1]

            if (
                p[0] >= TEST_AREA_MIN
                and p[1] >= TEST_AREA_MIN
                and p[0] <= TEST_AREA_MAX
                and p[1] <= TEST_AREA_MAX
                and dot1 > 0
                and dot2 > 0
            ):
                # print("here", dot1, dot2)
                intersect_count += 1
    print(intersect_count)


if __name__ == "__main__":
    main()
