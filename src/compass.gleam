import gleam/list

pub type Bit {
  Zero
  One
}

pub type Code(alfa) {
  Code(encode: fn(alfa) -> List(Bit))
}

pub fn flip(bit: Bit) -> Bit {
  case bit {
    Zero -> One
    One -> Zero
  }
}

pub fn show(bits: List(Bit)) -> String {
  case bits {
    [] -> ""
    [b, ..rest] ->
      case b {
        Zero -> "0"
        One -> "1"
      }
      <> show(rest)
  }
}

pub fn encode(message: List(a), code: Code(a)) -> List(Bit) {
  message |> list.flat_map(code.encode)
}

pub fn main() -> Nil {
  let same = Code(fn(b: Bit) { [flip(b)] })
  echo [Zero, One, Zero] |> encode(same) |> show()
  Nil
}
