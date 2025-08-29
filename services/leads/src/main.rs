use axum::{extract::State, routing::{get, post}, Json, Router};
use mongodb::{bson::{doc, DateTime}, options::ClientOptions, Client};
use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use tokio::net::TcpListener;
use telemetry::init_tracing;
use chrono::{Utc, Duration};

#[derive(Clone)]
struct AppState { client: Client }

#[derive(Deserialize)]
struct LeadInput { email: String, #[serde(default)] source: Option<String> }

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct RegisterInput {
    first_name: String,
    last_name: String,
    email: String,
    phone_e164: String,
    country: String,
    accept_terms: bool,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct RegisterResponse {
    verification_id: String,
    sms_expires_at: String,
    sms_resend_after_seconds: i32,
    email_resend_cooldown_seconds: i32,
    email_max_resends: i32,
}

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
        .route("/v1/register", post(register_user))
        .with_state(state);

    let addr = SocketAddr::from(([0,0,0,0], 8090));
    let listener = TcpListener::bind(addr).await?;
    tracing::info!("Leads listening on http://{}", listener.local_addr()?);
    axum::serve(listener, app).await?;
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

async fn register_user(
    State(state): State<AppState>,
    Json(payload): Json<RegisterInput>,
) -> Result<Json<RegisterResponse>, (axum::http::StatusCode, String)> {
    // Validaciones mínimas
    if !payload.accept_terms {
        return Err((axum::http::StatusCode::BAD_REQUEST, "terms_not_accepted".into()));
    }
    if !payload.email.contains('@') {
        return Err((axum::http::StatusCode::BAD_REQUEST, "invalid_email".into()));
    }
    if !payload.phone_e164.starts_with('+') {
        return Err((axum::http::StatusCode::BAD_REQUEST, "invalid_phone".into()));
    }

    let db = state
        .client
        .database(&std::env::var("MONGODB_DB").unwrap_or_else(|_| "fmlm".into()));

    let users = db.collection::<mongodb::bson::Document>("users");

    // Generamos un id de verificación (usamos ObjectId como string hex)
    let verification_id = ObjectId::new().to_hex();

    let doc = doc! {
        "firstName": payload.first_name,
        "lastName": payload.last_name,
        "email": payload.email,
        "phoneE164": payload.phone_e164,
        "country": payload.country,
        "acceptTerms": true,
        "verificationId": &verification_id,
        "status": "sms_pending",
        "created_at": DateTime::now(),
    };

    users
        .insert_one(doc, None)
        .await
        .map_err(|e| (axum::http::StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let sms_expires_at = (Utc::now() + Duration::minutes(10)).to_rfc3339();

    let resp = RegisterResponse {
        verification_id: verification_id,
        sms_expires_at,
        sms_resend_after_seconds: 30,
        email_resend_cooldown_seconds: 120,
        email_max_resends: 3,
    };

    Ok(Json(resp))
}
