use rustler::NifStruct;
#[derive(Debug,NifStruct)]
#[module = "LockedIn.User"]
struct User {
    pub id: i32,
}
#[rustler::nif]
fn main( user: User) -> i32{
    user.id
}

rustler::init!("Elixir.LockedIn.Recommender",[main]);
