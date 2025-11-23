import compass.{
  Code, One, Zero, binary, clog, decode, delta, encode, encode_string, gamma,
  log, pow, to_bits, to_string, unary,
}
import gleam/list
import gleam/pair
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn first_test() {
  let first =
    Code(
      encode: fn(chr: String) {
        case chr {
          "a" -> [Zero]
          "b" -> [One, One]
          "c" -> [Zero, One, Zero]
          "d" -> [One, Zero, One]
          _ -> []
        }
      },
      decode: fn(_) { panic as "Not uniquely decodable" },
    )

  assert "adc" |> encode_string(first) |> to_string == "0101010"
  assert encode_string("cda", first) |> to_string == "0101010"
  assert encode_string("adc", first) == encode_string("cda", first)
}

pub fn unary_test() {
  assert unary().encode(6) == [One, One, One, One, One, One, Zero]
  assert unary().encode(1) == [One, Zero]
  assert unary().encode(0) == [Zero]
  assert unary().encode(12)
    == [One, One, One, One, One, One, One, One, One, One, One, One, Zero]
  assert [0, 1, 3, 5] |> encode(unary()) |> to_string == "0101110111110"

  assert unary().decode([One, One, One, Zero]) |> pair.first == 3
  assert unary().decode([Zero, One, One, Zero]) |> pair.first == 0
  assert unary().decode([Zero, One, One, Zero]) |> pair.second
    == [One, One, Zero]
  assert "0101110111110" |> to_bits |> decode(unary()) == [0, 1, 3, 5]
}

pub fn binary_test() {
  assert binary(4).encode(6) == [Zero, One, One, Zero]
  assert binary(2).encode(2) == [One, Zero]
  assert binary(8).encode(127) == [Zero, One, One, One, One, One, One, One]
  assert [0, 1, 2, 3] |> encode(binary(2)) |> to_string == "00011011"

  assert binary(4).decode([Zero, One, One, Zero]) |> pair.first == 6
  assert binary(2).decode([Zero, One, One, Zero]) |> pair.first == 1
  assert "00011011" |> to_bits |> decode(binary(2)) == [0, 1, 2, 3]
}

pub fn log_test() {
  assert log(3) == 1
  assert log(6) == 2
  assert log(8) == 3
  assert clog(3) == 2
  assert clog(6) == 3
  assert clog(8) == 3
}

pub fn pow_test() {
  assert pow(2, 0) == 1
  assert pow(2, 1) == 2
  assert pow(2, 3) == 8
}

pub fn gamma_test() {
  assert gamma().encode(6) |> to_string == "11011"
  assert gamma().encode(100) |> to_string == "1111110100101"
  assert gamma().encode(400) |> to_string == "11111111010010001"
  assert gamma().encode(400) |> list.length == 2 * log(401) + 1

  assert "11011" |> to_bits |> gamma().decode |> pair.first == 6
  assert "11111101001011111111101001000111011" |> to_bits |> decode(gamma())
    == [100, 400, 6]
}

pub fn delta_test() {
  assert delta().encode(6) |> to_string == "10111"
  assert delta().encode(100) |> to_string == "11011100101"
  assert delta().encode(400) |> to_string == "111000110010001"
  assert delta().encode(400) |> list.length == clog(402) + 2 * log(clog(402))

  assert "10111" |> to_bits |> delta().decode |> pair.first == 6
  assert "1101110010111100011001000110111" |> to_bits |> decode(delta())
    == [100, 400, 6]
}
