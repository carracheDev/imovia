CREATE TYPE "AccountStatus" AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE TYPE "ReportCategory" AS ENUM ('FALSE_LISTING', 'MISLEADING_PRICE', 'UNAVAILABLE', 'IDENTITY_IMPERSONATION', 'UNAUTHORIZED_MEDIA', 'ABUSIVE_BEHAVIOR', 'UNDISCLOSED_FEES', 'OTHER');
CREATE TYPE "ReportStatus" AS ENUM ('OPEN', 'IN_REVIEW', 'RESOLVED', 'DISMISSED');
CREATE TYPE "NotificationType" AS ENUM ('LISTING_SUBMITTED', 'LISTING_APPROVED', 'LISTING_REJECTED', 'LISTING_NEEDS_CHANGES', 'LISTING_SUSPENDED', 'LISTING_RESTORED', 'REPORT_UPDATED');

ALTER TABLE "User" ADD COLUMN "accountStatus" "AccountStatus" NOT NULL DEFAULT 'ACTIVE';
ALTER TABLE "Property" ADD COLUMN "ownerUserId" TEXT, ADD COLUMN "ownerDisplayName" VARCHAR(160), ADD COLUMN "details" JSONB, ADD COLUMN "contactPhone" VARCHAR(32), ADD COLUMN "contactWhatsApp" VARCHAR(32), ADD COLUMN "allowPhoneContact" BOOLEAN NOT NULL DEFAULT false, ADD COLUMN "allowWhatsAppContact" BOOLEAN NOT NULL DEFAULT false, ADD COLUMN "visitInstructions" VARCHAR(1000);
ALTER TABLE "PropertyMedia" ADD COLUMN "approvedById" TEXT, ADD COLUMN "approvedAt" TIMESTAMP(3);

UPDATE "Property" property
SET "ownerUserId" = property."advertiserUserId"
FROM "User" advertiser
WHERE advertiser."id" = property."advertiserUserId"
  AND 'OWNER'::"UserRole" = ANY(advertiser."roles");

CREATE TABLE "PropertyAssignment" ("id" TEXT NOT NULL, "propertyId" TEXT NOT NULL, "agentUserId" TEXT NOT NULL, "assignedById" TEXT NOT NULL, "authorization" VARCHAR(1000) NOT NULL, "termsVersion" VARCHAR(32) NOT NULL, "grantedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "revokedAt" TIMESTAMP(3), CONSTRAINT "PropertyAssignment_pkey" PRIMARY KEY ("id"));
CREATE TABLE "Favorite" ("id" TEXT NOT NULL, "userId" TEXT NOT NULL, "propertyId" TEXT NOT NULL, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Favorite_pkey" PRIMARY KEY ("id"));
CREATE TABLE "Report" ("id" TEXT NOT NULL, "reporterUserId" TEXT, "reporterEmail" VARCHAR(254), "reporterIpHash" VARCHAR(64), "propertyId" TEXT, "targetUserId" TEXT, "assignedToId" TEXT, "category" "ReportCategory" NOT NULL, "description" VARCHAR(2000) NOT NULL, "status" "ReportStatus" NOT NULL DEFAULT 'OPEN', "resolutionReason" VARCHAR(1000), "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL, "resolvedAt" TIMESTAMP(3), CONSTRAINT "Report_pkey" PRIMARY KEY ("id"));
CREATE TABLE "Notification" ("id" TEXT NOT NULL, "userId" TEXT NOT NULL, "type" "NotificationType" NOT NULL, "title" VARCHAR(160) NOT NULL, "message" VARCHAR(500) NOT NULL, "propertyId" TEXT, "reportId" TEXT, "readAt" TIMESTAMP(3), "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Notification_pkey" PRIMARY KEY ("id"));
CREATE TABLE "AuditLog" ("id" TEXT NOT NULL, "actorUserId" TEXT, "action" VARCHAR(80) NOT NULL, "objectType" VARCHAR(80) NOT NULL, "objectId" VARCHAR(64) NOT NULL, "reason" VARCHAR(1000), "before" JSONB, "after" JSONB, "ipHash" VARCHAR(64), "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "propertyId" TEXT, "reportId" TEXT, CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id"));

CREATE UNIQUE INDEX "PropertyAssignment_propertyId_agentUserId_key" ON "PropertyAssignment"("propertyId", "agentUserId");
CREATE INDEX "PropertyAssignment_agentUserId_revokedAt_grantedAt_idx" ON "PropertyAssignment"("agentUserId", "revokedAt", "grantedAt");
CREATE INDEX "PropertyAssignment_propertyId_revokedAt_idx" ON "PropertyAssignment"("propertyId", "revokedAt");
CREATE UNIQUE INDEX "Favorite_userId_propertyId_key" ON "Favorite"("userId", "propertyId");
CREATE INDEX "Favorite_userId_createdAt_idx" ON "Favorite"("userId", "createdAt");
CREATE INDEX "Property_ownerUserId_publicationStatus_updatedAt_idx" ON "Property"("ownerUserId", "publicationStatus", "updatedAt");
CREATE INDEX "Report_status_createdAt_idx" ON "Report"("status", "createdAt");
CREATE INDEX "Report_propertyId_status_idx" ON "Report"("propertyId", "status");
CREATE INDEX "Report_targetUserId_status_idx" ON "Report"("targetUserId", "status");
CREATE INDEX "Report_reporterIpHash_createdAt_idx" ON "Report"("reporterIpHash", "createdAt");
CREATE INDEX "Report_reporterUserId_createdAt_idx" ON "Report"("reporterUserId", "createdAt");
CREATE INDEX "Report_reporterEmail_createdAt_idx" ON "Report"("reporterEmail", "createdAt");
CREATE INDEX "Notification_userId_readAt_createdAt_idx" ON "Notification"("userId", "readAt", "createdAt");
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");
CREATE INDEX "AuditLog_actorUserId_createdAt_idx" ON "AuditLog"("actorUserId", "createdAt");
CREATE INDEX "AuditLog_objectType_objectId_createdAt_idx" ON "AuditLog"("objectType", "objectId", "createdAt");
CREATE INDEX "AuditLog_propertyId_createdAt_idx" ON "AuditLog"("propertyId", "createdAt");
CREATE INDEX "AuditLog_reportId_createdAt_idx" ON "AuditLog"("reportId", "createdAt");

ALTER TABLE "Property" ADD CONSTRAINT "Property_ownerUserId_fkey" FOREIGN KEY ("ownerUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "PropertyMedia" ADD CONSTRAINT "PropertyMedia_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "PropertyAssignment" ADD CONSTRAINT "PropertyAssignment_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PropertyAssignment" ADD CONSTRAINT "PropertyAssignment_agentUserId_fkey" FOREIGN KEY ("agentUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PropertyAssignment" ADD CONSTRAINT "PropertyAssignment_assignedById_fkey" FOREIGN KEY ("assignedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Favorite" ADD CONSTRAINT "Favorite_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Favorite" ADD CONSTRAINT "Favorite_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_reporterUserId_fkey" FOREIGN KEY ("reporterUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Report" ADD CONSTRAINT "Report_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE SET NULL ON UPDATE CASCADE;
