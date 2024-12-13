
CELL_HEIGHT, CELL_WIDTH = (2, 2)
N = CELL_WIDTH * CELL_HEIGHT

clauses = []


def value_constraint(row, col):
    global clauses
    value = row * N * N + col * N

    clauses.append(range(value + 1, value + N + 1))
    for x in range(1, N):
        for y in range(x + 1, N + 1):
            clauses.append([-value - x, -value - y])


def row_constraint(row):
    global clauses
    values = [row * N * N + col * N for col in range(N)]

    for num in range(1, N + 1):
        clauses.append([values[col] + num for col in range(N)])


def col_constraint(col):
    global clauses
    values = [row * N * N + col * N for row in range(N)]

    for num in range(1, N + 1):
        clauses.append([values[row] + num for row in range(N)])


def cell_constraint(row, col):
    global clauses

    ROW = row * CELL_HEIGHT
    COL = col * CELL_WIDTH
    values = [(ROW + row) * N * N + (COL + col) *
              N for row in range(CELL_HEIGHT) for col in range(CELL_WIDTH)]

    for num in range(1, N + 1):
        clauses.append([values[idx] + num for idx in range(N)])


for row in range(N):
    for col in range(N):
        value_constraint(row, col)

for row in range(N):
    row_constraint(row)

for col in range(N):
    col_constraint(col)

for row in range(CELL_WIDTH):
    for col in range(CELL_HEIGHT):
        cell_constraint(row, col)

print('p cnf %d %d' % (N * N * N, len(clauses)))
for c in clauses:
    print(' '.join(map(str, c)) + ' 0')
