import pytest
from app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_greeting_default(client):
    """Test the default response without a query parameter."""
    response = client.get('/api/greeting')
    assert response.status_code == 200
    assert response.json == {"message": "Hello! This is Junyan Zhang's final project. Student id is 8903870"}

def test_greeting_with_name(client):
    """Test the response when a name is provided as a query parameter."""
    response = client.get('/api/greeting?name=John')
    assert response.status_code == 200
    assert response.json == {"message": "Hello, John!"}

def test_greeting_with_name_2(client):
    """Test the response when a name is provided as a query parameter."""
    response = client.get('/api/greeting?name=Alice')
    assert response.status_code == 200
    assert response.json == {"message": "Hello, Alice!"}

def test_greeting_invalid_method(client):
    """Test that the endpoint rejects non-GET methods."""
    response = client.post('/api/greeting')
    assert response.status_code == 405  # Method Not Allowed

def test_greeting_invalid_endpoint(client):
    """Test accessing a non-existent endpoint."""
    response = client.get('/api/unknown')
    assert response.status_code == 404  # Not Found
