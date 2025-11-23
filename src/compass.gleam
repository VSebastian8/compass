import gleam/list
import gleam/result
import gleam/string

pub type Bit {
  Zero
  One
}

pub type Code(alfa) {
  Code(
    encode: fn(alfa) -> List(Bit),
    decode: fn(List(Bit)) -> #(alfa, List(Bit)),
  )
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

pub fn to_bit(b: Bool) -> Bit {
  case b {
    False -> Zero
    True -> One
  }
}

pub fn to_string(bits: List(Bit)) -> String {
  case bits {
    [] -> ""
    [b, ..rest] ->
      {
        case b {
          Zero -> "0"
          One -> "1"
        }
      }
      <> to_string(rest)
  }
}

pub fn to_bits(bits: String) -> List(Bit) {
  case bits {
    "" -> []
    "0" <> rest -> [Zero, ..to_bits(rest)]
    "1" <> rest -> [One, ..to_bits(rest)]
    _ -> panic as "Bit String contains unexpected chars"
  }
}

pub fn encode(message: List(a), code: Code(a)) -> List(Bit) {
  message |> list.flat_map(code.encode)
}

pub fn encode_string(s: String, code: Code(String)) -> List(Bit) {
  string.split(s, "") |> list.flat_map(code.encode)
}

pub fn decode(message: List(Bit), code: Code(a)) -> List(a) {
  case message {
    [] -> []
    msg -> {
      let #(x, rest) = code.decode(msg)
      [x, ..decode(rest, code)]
    }
  }
}

fn unary_enc(n) {
  case n > 0 {
    True -> [One, ..unary_enc(n - 1)]
    False -> [Zero]
  }
}

fn unary_dec(bits) {
  case bits {
    [] -> panic as "Unary does not end in Zero"
    [first, ..rest] ->
      case first {
        Zero -> #(0, rest)
        One -> {
          let #(x, bs) = unary_dec(rest)
          #(x + 1, bs)
        }
      }
  }
}

pub fn unary() -> Code(Int) {
  Code(encode: unary_enc, decode: unary_dec)
}

fn binary_enc(k: Int, n: Int) -> List(Bit) {
  case k > 0 {
    True -> list.append(binary_enc(k - 1, n / 2), [to_bit(n % 2 != 0)])
    False -> []
  }
}

fn binary_dec(k: Int, bits) {
  case k {
    0 -> #(0, bits)
    _ ->
      case bits {
        [] -> panic as "Not enough bits provided for binary decoder"
        [b, ..rest] -> {
          let #(x, bs) = binary_dec(k - 1, rest)
          case b {
            Zero -> #(x, bs)
            One -> #(pow(2, k - 1) + x, bs)
          }
        }
      }
  }
}

pub fn binary(k: Int) -> Code(Int) {
  Code(encode: fn(num) { binary_enc(k, num) }, decode: fn(bits) {
    binary_dec(k, bits)
  })
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

pub fn gamma() -> Code(Int) {
  Code(
    encode: fn(n) {
      let k = log(n + 1)
      list.append(unary().encode(k), binary(k).encode(n - pow(2, k) + 1))
    },
    decode: fn(bs) {
      let #(k, rest1) = unary().decode(bs)
      let #(x, rest2) = binary(k).decode(rest1)
      #(x - 1 + pow(2, k), rest2)
    },
  )
}

pub fn delta() -> Code(Int) {
  Code(
    encode: fn(n) {
      let k = log(n + 1)
      list.append(gamma().encode(k), binary(k).encode(n - pow(2, k) + 1))
    },
    decode: fn(bs) {
      let #(k, rest1) = gamma().decode(bs)
      let #(x, rest2) = binary(k).decode(rest1)
      #(x - 1 + pow(2, k), rest2)
    },
  )
}

pub fn main() -> Nil {
  let same =
    Code(fn(b: Bit) { [flip(b)] }, decode: fn(bits) {
      #(flip(result.unwrap(list.first(bits), One)), list.drop(bits, 1))
    })
  echo [Zero, One, Zero] |> encode(same) |> show()
  Nil
}
