import type { UserRole } from '../generated/prisma/client.js';

export interface AuthenticatedUser {
  id: string;
  email: string | null;
  firstName: string | null;
  lastName: string | null;
  roles: UserRole[];
  accountStatus: 'ACTIVE' | 'SUSPENDED';
  sessionId: string;
}
