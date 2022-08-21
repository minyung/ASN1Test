use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Eq, PartialEq)]
struct TestStruct {
    number: u8,
    vec: String,
    tuple: (usize, usize),
}

fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    use picky_asn1_der::{Asn1DerError, from_bytes};
    use crate::TestStruct;

    #[test]
    fn asn1_decode_normal() {
        // given
        let test_binary: &[u8] = b"\x30\x82\x00\x16\x02\x01\x07\x0c\x09\x54\x65\x73\x74\x6f\x6c\x6f\x70\x65\x30\x06\x02\x01\x04\x02\x01\x03";

        // when
        let result: TestStruct = from_bytes(test_binary).unwrap();

        // then
        assert_eq!(7, result.number);
        assert_eq!("Testolope", result.vec);
        assert_eq!((4, 3), result.tuple);
    }

    #[test]
    fn asn1_decode_undefined_length() {
        // given
        let test_binary: &[u8] = b"\x30\x80\x02\x01\x07\x0c\x09\x54\x65\x73\x74\x6f\x6c\x6f\x70\x65\x30\x06\x02\x01\x04\x02\x01\x03\x00\x00";

        // when
        let result: Result<TestStruct, Asn1DerError> = from_bytes(test_binary);

        // then
        if let Err(Asn1DerError::Message(msg)) = result {
            assert_eq!("invalid length 0, expected struct TestStruct with 3 elements", msg);
        } else {
            assert!(false)
        }
    }
}