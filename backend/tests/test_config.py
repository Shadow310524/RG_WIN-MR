import pytest
from app.core.config import settings
from app.core.security import hash_password, verify_password, needs_rehash


def test_settings_defaults():
    """Verifies that configuration defaults comply with security and architecture rules."""
    assert settings.PROJECT_NAME == "RG WIN - Healix Field Sales & Doctor CRM"
    assert settings.VERSION == "1.0.0"
    assert settings.API_V1_STR == "/api/v1"
    assert settings.ACCESS_TOKEN_EXPIRE_MINUTES == 15
    assert settings.REFRESH_TOKEN_EXPIRE_DAYS == 7
    assert len(settings.SECRET_KEY) >= 32
    assert "https://healix-rgwin.onrender.com/api/v1" in settings.HEALIX_API_BASE_URL


def test_argon2id_password_hashing():
    """Verifies Argon2id password hashing and verification functionality."""
    password = "SecurePassword123!"
    hashed = hash_password(password)

    # Hash must not match plaintext
    assert hashed != password
    assert hashed.startswith("$argon2id$")

    # Verification must succeed for correct password
    assert verify_password(password, hashed) is True

    # Verification must fail for incorrect password
    assert verify_password("WrongPassword!", hashed) is False

    # Should not need rehash immediately with same parameters
    assert needs_rehash(hashed) is False
