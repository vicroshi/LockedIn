use rustler::NifMap;
use ndarray::{Array2};
use std::collections::HashMap;
use std::fs::File;
use std::io::{self, Write};
#[derive(NifMap)]
struct User {
    id: i64,
}
#[derive(NifMap)]
struct Job {
    id: i64,
}
#[derive(NifMap)]
struct MatchingSkills {
    user_id: i64,
    job_id: i64,
    count: i64,
}


fn print_ratings_to_file(rating: &Array2<f64>, user_ids: &Vec<User>, post_ids: &Vec<Job>) -> io::Result<()>{
    let mut file = File::create("ratings.txt")?;

    // Write the post IDs as the header row
    write!(file, "{:>8} ", " ")?; // Empty space for user ID column
    for post_id in post_ids {
        write!(file, "{:>6} ", post_id.id)?;
    }
    writeln!(file)?; // New line after the header

    // Write a separator line for better readability
    write!(file, "{:>8} ", " ")?; // Matching empty space under user ID column
    for _ in post_ids {
        write!(file, "{:>6} ", "------")?; // Separator for each post ID column
    }
    writeln!(file)?; // New line after separator

    // Write each row with the user ID at the start
    for (user_idx, row) in rating.rows().into_iter().enumerate() {
        // Write user ID before the row data
        write!(file, "{:>8} ", user_ids[user_idx].id)?;
        // Write the row values (ratings)
        for value in row.iter() {
            write!(file, "{:>6.2} ", value)?; // Format for better alignment
        }
        writeln!(file)?; // New line after each row
    }
    Ok(())

}

fn print_ratings(rating: &Array2<f64>, user_ids: &Vec<User>, post_ids: &Vec<Job>) {
    // Print the post IDs as the header row
    print!("{:>8} ", " "); // Empty space for user ID column
    for post_id in post_ids {
        print!("{:>6} ", post_id.id);
    }
    println!(); // New line after the header

    // Print a separator line for better readability
    print!("{:>8} ", " "); // Matching empty space under user ID column
    for _ in post_ids {
        print!("{:>6} ", "------"); // Separator for each post ID column
    }
    println!(); // New line after separator

    // Print each row with the user ID at the start
    for (user_idx, row) in rating.rows().into_iter().enumerate() {
        // Print user ID before the row data
        print!("{:>8} ", user_ids[user_idx].id);
        // Print the row values (ratings)
        for value in row.iter() {
            print!("{:>6.2} ", value); // Format for better alignment
        }
        println!(); // New line after each row
    }
}


#[rustler::nif]
// fn main( user: Vec<User>) -> i32{
fn construct_job_matrix( users: Vec<User>, jobs: Vec<Job>, job_views: Vec<(i64,i64)>, job_applications: Vec<(i64,i64)>, matching_skills: Vec<MatchingSkills>) ->    i64{
    // jobs.unwrap_or(vec![]).len() as i64
    // users[0].id
    let mut users_m = HashMap::new();
    let mut jobs_m = HashMap::new();
    for i in 0..users.len() {
        users_m.insert(users[i].id, i as i64);
    }
    for i in 0..jobs.len() {
        jobs_m.insert(jobs[i].id, i as i64);
    }
    let mut ratings = Array2::<f64>::from_elem((users_m.len(), jobs_m.len()), -1.0);
    print_ratings_to_file(&ratings, &users, &jobs);
    // print_ratings(&ratings, &users, &jobs);
    1
}

rustler::init!("Elixir.LockedIn.Recommender");
