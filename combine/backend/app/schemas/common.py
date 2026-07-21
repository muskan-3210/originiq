"""Shared schema types."""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel

Verdict = Literal["false", "misleading", "true", "unverified"]


class ErrorBody(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    error: ErrorBody
