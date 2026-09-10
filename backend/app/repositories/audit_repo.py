import uuid
from typing import Any, Optional, Dict
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit_log import AuditLog
from app.repositories.base import BaseRepository
from app.core.logging import logger


class AuditLogRepository(BaseRepository[AuditLog]):
    """Data access repository for audit trail records."""

    def __init__(self, db: AsyncSession):
        super().__init__(AuditLog, db)

    async def log_event(
        self,
        action: str,
        entity_type: str,
        actor_id: Optional[uuid.UUID] = None,
        entity_id: Optional[str] = None,
        metadata_json: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
    ) -> AuditLog:
        """
        Creates an immutable audit log record.
        CRITICAL OWASP RULE: Never include passwords, access tokens, or raw secrets in metadata.
        """
        # Defensive sanitize of metadata
        sanitized_meta = dict(metadata_json) if metadata_json else {}
        for sensitive_key in ["password", "token", "access_token", "refresh_token", "secret"]:
            sanitized_meta.pop(sensitive_key, None)

        audit_entry = AuditLog(
            actor_id=actor_id,
            action=action,
            entity_type=entity_type,
            entity_id=str(entity_id) if entity_id else None,
            metadata_json=sanitized_meta,
            ip_address=ip_address,
        )

        logger.info(
            f"Audit: [{action}] by actor={actor_id} on {entity_type} {entity_id}",
            extra={"extra": {"action": action, "actor_id": str(actor_id) if actor_id else None}},
        )

        return await self.create(audit_entry)
