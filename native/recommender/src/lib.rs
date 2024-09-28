use rustler::NifMap;
use ndarray::{Array2};
use std::collections::HashMap;
use std::fs::File;
use ndarray_rand::RandomExt;
use rand::distributions::Uniform;
//hyperparameters
const K: usize = 10;
const LEARNING_RATE: f64 = 0.05;
const REGULARIZATION_PARAM: f64 = 0.01;
const NUM_EPOCHS: usize = 5000;
use std::io::{self, Write};
#[derive(NifMap)]
struct User {
    id: i64,
}
#[derive(NifMap)]
struct Job {
    id: i64,
    user_id: i64,
    count: i64,
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

 fn matrix_factorization(r: &Array2<f64>,) -> Array2<f64> {
    let (rows, cols) = r.dim(); // Get the dimensions
    // Define a uniform distribution between 0.1 and 1.0 and initialize matrixes p,q with it
    let dist = Uniform::new(0.1, 1.0);
    let mut p = Array2::<f64>::random((rows, K), dist);
    let mut q = Array2::<f64>::random((K,cols), dist);
    
    // gradient descent algorithm
    for _ in 0..NUM_EPOCHS{
        for user in 0..rows {
            for item in 0..cols{
                if r[[user,item]] > -1.0 { //user has either interracted with it or skipped it.
                    let prediction = p.row(user).dot(&q.column(item)); //get the dot product
                    // println!("dot: {}",prediction);
                    let original_value = r[[user, item]] as f64; //compare it to same data type
                    let error=  original_value - prediction;
                    //update vectors p and q using the error
                        for j in 0..K {
                        // Update p[user, j]
                        p[[user, j]] += LEARNING_RATE * (error * q[[j, item]] - REGULARIZATION_PARAM * p[[user, j]]);
                        // Update q[j, item]
                        q[[j, item]] += LEARNING_RATE * (error * p[[user, j]] - REGULARIZATION_PARAM * q[[j, item]]);
                    }
                }
            }
        }
    }
    // make the new r' matrix with recommendations
    p.dot(&q) //this is returned
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
    for i in 0..matching_skills.len() {
        let user_id = matching_skills[i].user_id;
        let job_id = matching_skills[i].job_id;
        let count = matching_skills[i].count;
        let user_idx = users_m.get(&user_id).unwrap();
        let job_idx = jobs_m.get(&job_id).unwrap();
        let match_perc = count as f64 /jobs[*job_idx as usize].count as f64;
        if jobs[*job_idx as usize].count == 0 {
            ratings[[*user_idx as usize, *job_idx as usize]] = 1.0;
        } else {
            ratings[[*user_idx as usize, *job_idx as usize]] = match_perc*6.0;
        }
        // ratings[[*user_idx as usize, *job_idx as usize]] = 
    }
    for i in 0..job_views.len() {
        let user_id = job_views[i].0;
        let job_id = job_views[i].1;
        let user_idx = users_m.get(&user_id).unwrap();
        let job_idx = jobs_m.get(&job_id).unwrap();
        if ratings[[*user_idx as usize, *job_idx as usize]] == -1.0 {
            ratings[[*user_idx as usize, *job_idx as usize]] = 0.0;
        }
        ratings[[*user_idx as usize, *job_idx as usize]] += 1.0;
    }
    for i in 0..job_applications.len() {
        let user_id = job_applications[i].0;
        let job_id = job_applications[i].1;
        let user_idx = users_m.get(&user_id).unwrap();
        let job_idx = jobs_m.get(&job_id).unwrap();
        if ratings[[*user_idx as usize, *job_idx as usize]] == -1.0 {
            ratings[[*user_idx as usize, *job_idx as usize]] = 0.0;
        }
        ratings[[*user_idx as usize, *job_idx as usize]] += 3.0;
    }
    // for u in 0..users.len() {
        // if  
    // }
    ratings = matrix_factorization(&ratings);

    print_ratings_to_file(&ratings, &users, &jobs);

    // print_ratings(&ratings, &users, &jobs);
    1
}

rustler::init!("Elixir.LockedIn.Recommender");
