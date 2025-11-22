import gleam/list
import gleam/string

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

pub fn bits_to_string(bits: List(Bit)) -> String {
  case bits {
    [] -> ""
    [b, ..rest] ->
      {
        case b {
          Zero -> "0"
          One -> "1"
        }
      }
      <> bits_to_string(rest)
  }
}

pub fn encode(message: List(a), code: Code(a)) -> List(Bit) {
  message |> list.flat_map(code.encode)
}

pub fn encode_string(s: String, code: Code(String)) -> List(Bit) {
  string.split(s, "") |> list.flat_map(code.encode)
}

pub fn to_bit(b: Bool) -> Bit {
  case b {
    False -> Zero
    True -> One
  }
}

pub fn binary(k: Int, n: Int) -> List(Bit) {
  case k > 0 {
    True -> list.append(binary(k - 1, n / 2), [to_bit(n % 2 != 0)])
    False -> []
  }
}

pub fn unary(n) -> List(Bit) {
  case n > 0 {
    True -> [One, ..unary(n - 1)]
    False -> [Zero]
  }
}

pub fn main() -> Nil {
  let same = Code(fn(b: Bit) { [flip(b)] })
  echo [Zero, One, Zero] |> encode(same) |> show()
  Nil
}
