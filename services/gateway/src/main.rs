use axum::{routing::get, Router};
use std::net::SocketAddr;
use telemetry::init_tracing;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    init_tracing();
    let app = Router::new().route("/status", get(|| async { "FMLM Gateway OK" }));
    let port: u16 = std::env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8080);
    let addr = SocketAddr::from(([0,0,0,0], port));
    tracing::info!("Gateway listening on http://{addr}");
    axum::Server::bind(&addr).serve(app.into_make_service()).await?;
    Ok(())
}
