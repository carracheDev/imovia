CREATE TYPE "PropertyCategory" AS ENUM ('ROOM', 'ROOM_AND_LIVING', 'STUDIO', 'APARTMENT', 'HOUSE', 'VILLA', 'LAND', 'SHOP', 'COMMERCIAL_SPACE', 'OFFICE', 'WAREHOUSE', 'OTHER');

CREATE TYPE "OperationType" AS ENUM ('RENT', 'SALE');

CREATE TYPE "PropertyAvailability" AS ENUM ('AVAILABLE', 'RESERVED', 'UNAVAILABLE', 'RENTED', 'SOLD');

CREATE TYPE "PropertyPublicationStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'IN_REVIEW', 'NEEDS_CHANGES', 'PUBLISHED', 'REJECTED', 'SUSPENDED', 'EXPIRED');

CREATE TYPE "LocationLevel" AS ENUM ('DEPARTMENT', 'COMMUNE', 'ARRONDISSEMENT', 'NEIGHBORHOOD');

DROP INDEX "OtpChallenge_phone_consumedAt_expiresAt_idx";

ALTER TABLE "OtpChallenge" ADD COLUMN "email" TEXT,
ALTER COLUMN "phone" DROP NOT NULL;

ALTER TABLE "User" ADD COLUMN "email" TEXT,
ADD COLUMN "emailVerifiedAt" TIMESTAMP(3),
ALTER COLUMN "phone" DROP NOT NULL;

CREATE TABLE "Location" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "level" "LocationLevel" NOT NULL,
    "parentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Location_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Property" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "advertiserUserId" TEXT NOT NULL,
    "locationId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" "PropertyCategory" NOT NULL,
    "operationType" "OperationType" NOT NULL,
    "price" DECIMAL(14,2),
    "currency" VARCHAR(3) NOT NULL DEFAULT 'XOF',
    "availability" "PropertyAvailability" NOT NULL DEFAULT 'AVAILABLE',
    "publicationStatus" "PropertyPublicationStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "publishedAt" TIMESTAMP(3),
    CONSTRAINT "Property_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "PropertyStatusHistory" (
    "id" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "status" "PropertyPublicationStatus" NOT NULL,
    "reason" TEXT,
    "changedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PropertyStatusHistory_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "Location_parentId_level_name_idx" ON "Location"("parentId", "level", "name");
CREATE UNIQUE INDEX "Location_parentId_slug_key" ON "Location"("parentId", "slug");
CREATE UNIQUE INDEX "Property_slug_key" ON "Property"("slug");
CREATE INDEX "Property_publicationStatus_availability_createdAt_idx" ON "Property"("publicationStatus", "availability", "createdAt");
CREATE INDEX "Property_advertiserUserId_publicationStatus_updatedAt_idx" ON "Property"("advertiserUserId", "publicationStatus", "updatedAt");
CREATE INDEX "Property_locationId_publicationStatus_availability_idx" ON "Property"("locationId", "publicationStatus", "availability");
CREATE INDEX "Property_category_operationType_price_idx" ON "Property"("category", "operationType", "price");
CREATE INDEX "PropertyStatusHistory_propertyId_createdAt_idx" ON "PropertyStatusHistory"("propertyId", "createdAt");
CREATE INDEX "OtpChallenge_email_createdAt_idx" ON "OtpChallenge"("email", "createdAt");
CREATE INDEX "OtpChallenge_email_consumedAt_expiresAt_idx" ON "OtpChallenge"("email", "consumedAt", "expiresAt");
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

ALTER TABLE "Location" ADD CONSTRAINT "Location_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Property" ADD CONSTRAINT "Property_advertiserUserId_fkey" FOREIGN KEY ("advertiserUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Property" ADD CONSTRAINT "Property_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "PropertyStatusHistory" ADD CONSTRAINT "PropertyStatusHistory_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "PropertyStatusHistory" ADD CONSTRAINT "PropertyStatusHistory_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
