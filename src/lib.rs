pub fn hello() -> &'static str {
    "hello"
}

#[cfg(test)]
mod tests {
    #[test]
    fn hello() {
        assert_eq!(super::hello(), "hello");
    }
}
