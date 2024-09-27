use std::error::Error;
mod foo;
// mod factorize;
// mod struct_functions;
#[rustler::nif]
fn add(_a: i64, _b: i64) -> i64 {
    foo::foo()
}

rustler::init!("Elixir.Recommender");
