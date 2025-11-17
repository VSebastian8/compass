import compass.{Code, One, Zero, bits_to_string, encode_string}
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

  echo encode_string("adc", first) |> bits_to_string
  echo encode_string("cda", first) |> bits_to_string
  assert encode_string("adc", first) == encode_string("cda", first)
}
