from fastapi import Depends, HTTPException
from app.modules.users.models import User, UserRole
from app.modules.auth.deps import get_current_user

class RoleChecker:
    def __init__(self, allowed_roles: list[UserRole]):
        self.allowed_roles = allowed_roles

    def __call__(self, user: User = Depends(get_current_user)):
        if user.role not in self.allowed_roles:
            raise HTTPException(status_code=403, detail="Operation not permitted")
        return user

allow_buyer = RoleChecker([UserRole.BUYER])
allow_developer = RoleChecker([UserRole.DEVELOPER])
allow_admin = RoleChecker([UserRole.ADMIN])
allow_buyer_or_admin = RoleChecker([UserRole.BUYER, UserRole.ADMIN])
