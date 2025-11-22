import compass.{
  Code, One, Zero, binary, bits_to_string, clog, delta, encode_string, gamma,
  log, pow, unary,
}
import gleam/list
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn first_test() {
  let first =
    Code(fn(chr: String) {
      case chr {
        "a" -> [Zero]
        "b" -> [One, One]
        "c" -> [Zero, One, Zero]
        "d" -> [One, Zero, One]
        _ -> []
      }
    })

  assert encode_string("adc", first) |> bits_to_string == "0101010"
  assert encode_string("cda", first) |> bits_to_string == "0101010"
  assert encode_string("adc", first) == encode_string("cda", first)
}

pub fn binary_test() {
  assert binary(4, 6) == [Zero, One, One, Zero]
  assert binary(2, 2) == [One, Zero]
  assert binary(8, 127) == [Zero, One, One, One, One, One, One, One]
}

pub fn unary_test() {
  assert unary(6) == [One, One, One, One, One, One, Zero]
  assert unary(1) == [One, Zero]
  assert unary(0) == [Zero]
  assert unary(12)
    == [One, One, One, One, One, One, One, One, One, One, One, One, Zero]
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
  assert gamma(6) |> bits_to_string == "11011"
  assert gamma(100) |> bits_to_string == "1111110100101"
  assert gamma(400) |> bits_to_string == "11111111010010001"
  assert gamma(400) |> list.length == 2 * log(401) + 1
}

pub fn delta_test() {
  assert delta(6) |> bits_to_string == "10111"
  assert delta(100) |> bits_to_string == "11011100101"
  assert delta(400) |> bits_to_string == "111000110010001"
  assert delta(400) |> list.length == clog(402) + 2 * log(clog(402))
}
