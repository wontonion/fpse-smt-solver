(* 数独板的类型定义 *)
type board = int array array

(* 创建空数独板 *)
let create_empty_board () : board = 
  Array.make_matrix 9 9 0

(* 检查在指定位置放置数字是否有效 *)
let is_valid (board: board) (row: int) (col: int) (num: int) : bool =
  (* 检查行 *)
  let row_valid = 
    not (Array.exists (fun x -> x = num) board.(row)) in
  
  (* 检查列 *)
  let col_valid = 
    not (Array.init 9 (fun i -> board.(i).(col))
    |> Array.exists (fun x -> x = num)) in
    
  (* 检查3x3方块 *)
  let block_valid =
    let start_row = (row / 3) * 3 in
    let start_col = (col / 3) * 3 in
    let exists_in_block = ref false in
    for i = 0 to 2 do
      for j = 0 to 2 do
        if board.(start_row + i).(start_col + j) = num then
          exists_in_block := true
      done;
    done;
    not !exists_in_block in
    
  row_valid && col_valid && block_valid

(* 找到下一个空位置 *)
let find_empty (board: board) : (int * int) option =
  let found = ref false in
  let result = ref None in
  for i = 0 to 8 do
    for j = 0 to 8 do
      if board.(i).(j) = 0 && not !found then begin
        result := Some (i, j);
        found := true
      end
    done;
  done;
  !result

(* 解数独，返回解的数量 *)
let rec solve_and_count (board: board) (count: int ref) (max_solutions: int) : unit =
  if !count >= max_solutions then
    ()
  else
    match find_empty board with
    | None -> 
        (* 找到一个解 *)
        incr count
    | Some (row, col) ->
        (* 尝试填数字1-9 *)
        for num = 1 to 9 do
          if is_valid board row col num then begin
            board.(row).(col) <- num;
            solve_and_count board count max_solutions;
            board.(row).(col) <- 0  (* 回溯 *)
          end
        done

(* 生成随机数独板 *)
let generate_puzzle () : board =
  let board = create_empty_board () in
  
  (* 随机填入一些初始数字 *)
  let fill_random_cells () =
    for _ = 1 to 17 do  (* 填入17个数字 *)
      let filled = ref false in
      while not !filled do
        let row = Random.int 9 in
        let col = Random.int 9 in
        let num = Random.int 9 + 1 in
        if board.(row).(col) = 0 && is_valid board row col num then begin
          board.(row).(col) <- num;
          filled := true
        end
      done
    done in
    
  (* 检查是否只有唯一解 *)
  let has_unique_solution (board: board) : bool =
    let count = ref 0 in
    solve_and_count board count 2;
    !count = 1 in
    
  (* 生成完整的数独板 *)
  fill_random_cells ();
  let count = ref 0 in
  solve_and_count board count 1;  (* 填充剩余空格 *)
  
  (* 逐个移除数字并检查是否保持唯一解 *)
  let numbers = Array.init 81 (fun i -> i) in
  Array.sort (fun _ _ -> Random.int 3 - 1) numbers;  (* 随机打乱顺序 *)
  
  Array.iter (fun i ->
    let row = i / 9 in
    let col = i mod 9 in
    let temp = board.(row).(col) in
    board.(row).(col) <- 0;
    if not (has_unique_solution board) then
      board.(row).(col) <- temp  (* 恢复数字 *)
  ) numbers;
  
  board

(* 打印数独板 *)
let print_board (board: board) : unit =
  for i = 0 to 8 do
    if i mod 3 = 0 && i <> 0 then
      print_endline "---------------------";
    for j = 0 to 8 do
      if j mod 3 = 0 && j <> 0 then
        print_string "| ";
      if board.(i).(j) = 0 then
        print_string ". "
      else
        Printf.printf "%d " board.(i).(j)
    done;
    print_newline ()
  done