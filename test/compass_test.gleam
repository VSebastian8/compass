import compass.{Code, One, Zero, binary, bits_to_string, encode_string, unary}
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
