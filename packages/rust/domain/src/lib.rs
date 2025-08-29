use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Lead {
    pub email: String,
    pub source: Option<String>,
}
