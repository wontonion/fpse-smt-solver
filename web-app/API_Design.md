# All API use JSON format
## Basic API Design
```json
{
    "method": "POST" | "GET",
    "problem_type": "sudoku" | "SAT" | "SMT",
    "status"?: "success" | "error",
    "message": "message",
    "data"?: "data"
}
```
- message: console message
- status: only used in response
- data: In the case of success, it is the data returned by the API. In the case of error, it is the error message. Detail structure depends on the problem. Some GET API may not request with data.


# Sudoku API Design

## 1. generateSudoku
```url
/api/sudoku/generate
```
```json
// response
{
    "method": "GET",
    "problem_type": "sudoku",
    "message": "Generating sudoku...",
    "data": {
        "size": 9,
        "grid": [
            [{"value": "1", "is_initial": true, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "4", "is_initial": true, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "8", "is_initial": true, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}],
            [{"value": "", "is_initial": false, "is_valid": true}, {"value": "5", "is_initial": true, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "9", "is_initial": true, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "", "is_initial": false, "is_valid": true}, {"value": "3", "is_initial": true, "is_valid": true}],
        ]
    }
}
```
- size: the size of the sudoku grid
- grid: the sudoku grid, each element is a cell, each cell has three attributes: value, is_initial, is_valid.
    - value: the value of the cell, "" means empty
    - is_initial: whether the cell is initial, if true, the value cannot be changed
    - is_valid: whether the cell is valid, if false, the value is invalid   
    
## 2. solveSudoku
```url
/api/sudoku/solve
```
```json
// request
{
    "method": "POST",
    "problem_type": "sudoku",
    "message": "Solving sudoku...",
    "data": {
        "size": 9,
        "grid": [

        ]
    }
}
// response
{
    "method": "POST",
    "problem_type": "sudoku",
    "status": "success" | "error",
    "message": "sudoku solved",
    "data": {
        "size": 9,
        "grid": [
            ...
        ]
    }
}
```

# SAT/SMT API Design

## 1. requestSAT/requestSMT
```url
/api/sat/solve
/api/smt/solve
```
```json
// request
{
    "method": "POST",
    "problem_type": "SAT" | "SMT",
    "message": "Requesting SAT/SMT...",
    "data": string
}
// response
{
    "method": "POST",
    "problem_type": "SAT" | "SMT",
    "status": "success" | "error",
    "message": "SAT/SMT requested",
    "data": string
}
```
- problem: the problem to be solved, the format depends on the problem type
