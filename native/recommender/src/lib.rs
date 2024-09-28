use rustler::NifMap;
use ndarray::{Array2};
use std::collections::HashMap;
#[derive(NifMap)]
struct User {
    id: i64,
}
#[derive(NifMap)]
struct Job {
    id: i64,
}
#[rustler::nif]
// fn main( user: Vec<User>) -> i32{
fn main( users: Vec<User>, jobs: Vec<Job>) -> i64{
    // jobs.unwrap_or(vec![]).len() as i64
    // users[0].id
    let users_m: HashMap<_, _> = users.into_iter()
    .enumerate()
    .map(|(i, user)| (user.id, i as i64))
    .collect();
    let jobs_m: HashMap<_, _> = jobs.into_iter().enumerate().map(|(i, job)| (job.id, i as i64)).collect();
    let mut ratings = Array2::<f64>::from_elem((users_m.len(), jobs_m.len()), -1.0);
    1
}

rustler::init!("Elixir.LockedIn.Recommender");
