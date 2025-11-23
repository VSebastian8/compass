import gleam/float
import gleam/list
import gleam/result
import gleam/string
import gleamy/pairing_heap
import gleamy/priority_queue

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

fn hamming_while(
  pq: pairing_heap.Heap(#(List(#(a, List(Bit))), Float)),
) -> List(#(a, List(Bit))) {
  case priority_queue.count(pq) {
    1 -> {
      case priority_queue.peek(pq) {
        Ok(l) -> l.0
        Error(_) -> panic
      }
    }
    _ -> {
      let #(el0, pq1) = case priority_queue.pop(pq) {
        Ok(x) -> x
        Error(_) -> panic
      }
      let #(el1, pq2) = case priority_queue.pop(pq1) {
        Ok(x) -> x
        Error(_) -> panic
      }
      let l0 = el0.0 |> list.map(fn(code) { #(code.0, [Zero, ..code.1]) })
      let l1 = el1.0 |> list.map(fn(code) { #(code.0, [One, ..code.1]) })
      let pq3 = priority_queue.push(pq2, #(list.append(l0, l1), el0.1 +. el1.1))
      hamming_while(pq3)
    }
  }
}

fn hamming_enc(symbols: List(#(a, List(Bit)))) -> fn(a) -> List(Bit) {
  fn(sym) {
    case list.find(symbols, fn(p) { p.0 == sym }) {
      Error(_) -> panic as "Symbol not found in code dictionary"
      Ok(x) -> x.1
    }
  }
}

fn hamming_dec(
  symbols: List(#(a, List(Bit))),
  prefix: List(Bit),
) -> fn(List(Bit)) -> #(a, List(Bit)) {
  fn(msg) {
    case msg {
      [] -> panic as "Message should not be empty at this point"
      [b, ..rest] -> {
        let try_code = list.append(prefix, [b])
        case list.find(symbols, fn(p) { p.1 == try_code }) {
          Ok(x) -> #(x.0, rest)
          Error(_) -> hamming_dec(symbols, try_code)(rest)
        }
      }
    }
  }
}

pub fn hamming_code(prob: List(#(a, Float))) -> Code(a) {
  let pq =
    priority_queue.from_list(
      prob |> list.map(fn(p) { #([#(p.0, [])], p.1) }),
      fn(p1, p2) { float.compare(p1.1, p2.1) },
    )
  let symbols = hamming_while(pq)
  Code(encode: hamming_enc(symbols), decode: hamming_dec(symbols, []))
}

pub fn main() -> Nil {
  let same =
    Code(fn(b: Bit) { [flip(b)] }, decode: fn(bits) {
      #(flip(result.unwrap(list.first(bits), One)), list.drop(bits, 1))
    })
  echo [Zero, One, Zero] |> encode(same) |> show()

  Nil
}
