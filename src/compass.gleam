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

// floor(log2(n))
pub fn log(n: Int) {
  case n <= 1 {
    True -> 0
    False -> 1 + log(n / 2)
  }
}

// ceil(log2(n))
pub fn clog(n: Int) {
  case n <= 1 {
    True -> 0
    False ->
      case n % 2 == 0 {
        True -> 1 + clog(n / 2)
        False -> 1 + log(n)
      }
  }
}

// n ^ k
pub fn pow(n, k) {
  case k == 0 {
    True -> 1
    False -> n * pow(n, k - 1)
  }
}

pub fn gamma(n: Int) -> List(Bit) {
  let k = log(n + 1)
  list.append(unary(k), binary(k, n - pow(2, k) + 1))
}

pub fn delta(n: Int) -> List(Bit) {
  let k = log(n + 1)
  list.append(gamma(k), binary(k, n - pow(2, k) + 1))
}

pub fn main() -> Nil {
  let same = Code(fn(b: Bit) { [flip(b)] })
  echo [Zero, One, Zero] |> encode(same) |> show()
  Nil
}
