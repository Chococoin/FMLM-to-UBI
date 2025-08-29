use axum::{extract::State, routing::{get, post}, Json, Router};
use mongodb::{bson::{doc, DateTime}, options::ClientOptions, Client};
use serde::Deserialize;
use std::net::SocketAddr;
use telemetry::init_tracing;

#[derive(Clone)]
struct AppState { client: Client }

#[derive(Deserialize)]
struct LeadInput { email: String, #[serde(default)] source: Option<String> }

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    init_tracing();
    dotenvy::dotenv().ok();
    let uri = std::env::var("MONGODB_URI").unwrap_or_else(|_| "mongodb://localhost:27017".into());
    let opts = ClientOptions::parse(uri).await?;
    let client = Client::with_options(opts)?;
    let state = AppState { client };

    let app = Router::new()
        .route("/status", get(|| async { "Leads OK" }))
        .route("/leads", post(create_lead))
        .with_state(state);

    let addr = SocketAddr::from(([0,0,0,0], 8090));
    tracing::info!("Leads listening on http://{addr}");
    axum::Server::bind(&addr).serve(app.into_make_service()).await?;
    Ok(())
}

async fn create_lead(
    State(state): State<AppState>,
    Json(payload): Json<LeadInput>,
) -> Result<Json<serde_json::Value>, (axum::http::StatusCode, String)> {
    if !payload.email.contains('@') {
        return Err((axum::http::StatusCode::BAD_REQUEST, "invalid email".into()));
    }
    let db = state.client.database(&std::env::var("MONGODB_DB").unwrap_or_else(|_| "fmlm".into()));
    let coll = db.collection::<mongodb::bson::Document>("leads");
    let doc = doc! { "email": &payload.email, "source": payload.source.unwrap_or("landing".into()), "created_at": DateTime::now() };
    coll.insert_one(doc, None).await
        .map_err(|e| (axum::http::StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(serde_json::json!({ "ok": true })))
}
