"""End-to-end API tests through the FastAPI app (§16.2)."""
KNOWN = "5G mobile networks cause or spread the coronavirus."


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_root(client):
    assert client.get("/").json()["name"] == "ORACLE API"


def test_global_stats(client):
    body = client.get("/api/stats/global").json()
    assert body["countries_covered"] > 0
    assert set(body) == {"chains_broken_today", "chains_broken_total", "countries_covered"}


def test_analyze_known_claim(client):
    response = client.post("/api/analyze", data={"type": "text", "content": KNOWN})
    assert response.status_code == 200
    body = response.json()
    assert body["verdict"] == "false"
    assert body["origin"]["country"] == "BE"
    assert body["truth_card_ready"] is True


def test_analyze_missing_content_is_422(client):
    response = client.post("/api/analyze", data={"type": "text"})
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "invalid_request"


def test_analyze_invalid_type_is_422(client):
    response = client.post("/api/analyze", data={"type": "video", "content": "hi"})
    assert response.status_code == 422


def test_analyze_unverified(client):
    body = client.post("/api/analyze", data={"type": "text", "content": "lol ok"}).json()
    assert body["verdict"] == "unverified"
    assert body["truth_card_ready"] is False


def test_truthcard_generation(client):
    analysis = client.post("/api/analyze", data={"type": "text", "content": KNOWN}).json()
    response = client.post("/api/truthcard", json={"analysis_id": analysis["id"]})
    assert response.status_code == 200
    assert response.json()["image_url"].endswith(".png")


def test_truthcard_not_found_is_404(client):
    response = client.post("/api/truthcard", json={"analysis_id": "nope"})
    assert response.status_code == 404
    assert response.json()["error"]["code"] == "not_found"


def test_legacy_requires_auth(client):
    response = client.post(
        "/api/legacy", json={"analysis_id": "x", "truth_card_url": "http://y"}
    )
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "unauthorized"


def test_legacy_flow_and_duplicate(client, auth_headers):
    analysis = client.post("/api/analyze", data={"type": "text", "content": KNOWN}).json()
    card = client.post("/api/truthcard", json={"analysis_id": analysis["id"]}).json()
    payload = {"analysis_id": analysis["id"], "truth_card_url": card["image_url"]}

    first = client.post("/api/legacy", json=payload, headers=auth_headers)
    assert first.status_code == 200
    assert first.json()["legacy_count"] == 1

    duplicate = client.post("/api/legacy", json=payload, headers=auth_headers)
    assert duplicate.status_code == 409


def test_legacy_rejects_non_catch(client, auth_headers):
    analysis = client.post("/api/analyze", data={"type": "text", "content": "lol ok"}).json()
    response = client.post(
        "/api/legacy",
        json={"analysis_id": analysis["id"], "truth_card_url": "http://x"},
        headers=auth_headers,
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "not_a_catch"


def test_leaderboard(client):
    body = client.get("/api/leaderboard?scope=global&limit=10").json()
    assert body["scope"] == "global"
    assert isinstance(body["entries"], list)


def test_leaderboard_invalid_scope_is_422(client):
    assert client.get("/api/leaderboard?scope=galaxy").status_code == 422
