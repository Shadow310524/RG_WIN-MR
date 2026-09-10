import uuid
from datetime import datetime, timezone, timedelta
from typing import Any, Dict, Optional
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, VerificationError, InvalidHashError
from jose import jwt, JWTError

from app.core.config import settings
from app.core.exceptions import UnauthorizedException

# Configure Argon2id password hasher with secure-by-default parameters
# Recommended: 64MB memory, 3 iterations, 4 parallelism lanes
_ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,
    parallelism=4,
    hash_len=32,
    salt_len=16,
)


def hash_password(plain_password: str) -> str:
    """Hashes a plaintext password using Argon2id."""
    return _ph.hash(plain_password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plaintext password against an Argon2id hash."""
    try:
        return _ph.verify(hashed_password, plain_password)
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def needs_rehash(hashed_password: str) -> bool:
    """Checks if a hash needs to be upgraded to match current security parameters."""
    return _ph.check_needs_rehash(hashed_password)


def create_token(
    subject: str,
    token_type: str,
    expires_delta: timedelta,
    additional_claims: Optional[Dict[str, Any]] = None,
) -> tuple[str, str, datetime]:
    """
    Creates a signed JWT with a unique jti identifier for revocation tracking.
    Returns (token_string, jti, expires_at_utc).
    """
    now = datetime.now(timezone.utc)
    expires_at = now + expires_delta
    jti = str(uuid.uuid4())

    payload: Dict[str, Any] = {
        "sub": subject,
        "type": token_type,
        "jti": jti,
        "iat": int(now.timestamp()),
        "exp": int(expires_at.timestamp()),
    }

    if additional_claims:
        payload.update(additional_claims)

    token_str = jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return token_str, jti, expires_at


def create_access_token(
    user_id: uuid.UUID,
    email: str,
    role: str,
    refresh_jti: Optional[str] = None,
) -> tuple[str, str, datetime]:
    """Creates a short-lived access token (default 15 minutes)."""
    delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    claims: Dict[str, Any] = {"email": email, "role": role}
    if refresh_jti:
        claims["refresh_jti"] = refresh_jti
    return create_token(
        subject=str(user_id),
        token_type="access",
        expires_delta=delta,
        additional_claims=claims,
    )


def create_refresh_token(
    user_id: uuid.UUID,
    email: str,
    role: str,
) -> tuple[str, str, datetime]:
    """Creates a secure long-lived refresh token (default 7 days)."""
    delta = timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    return create_token(
        subject=str(user_id),
        token_type="refresh",
        expires_delta=delta,
        additional_claims={"email": email, "role": role},
    )


def decode_token(token: str, verify_exp: bool = True) -> Dict[str, Any]:
    """
    Decodes and verifies a JWT token signature and claims.
    If verify_exp is True (default), raises UnauthorizedException on expired tokens.
    If verify_exp is False, verifies cryptographic signature but allows expired tokens
    (strictly for safe revocation and logout).
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
            options={"verify_exp": verify_exp},
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise UnauthorizedException("Token has expired", code="TOKEN_EXPIRED")
    except JWTError:
        raise UnauthorizedException("Invalid or malformed authentication token", code="INVALID_TOKEN")
