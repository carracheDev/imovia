-- AlterTable
ALTER TABLE "PropertyStatusHistory" ADD COLUMN     "reviewerId" TEXT;

-- CreateTable
CREATE TABLE "PropertyAuthorization" (
    "id" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "advertiserUserId" TEXT NOT NULL,
    "declaration" TEXT NOT NULL,
    "termsVersion" TEXT NOT NULL,
    "acceptedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PropertyAuthorization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PropertyMedia" (
    "id" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "mediaType" VARCHAR(16) NOT NULL,
    "storageKey" TEXT NOT NULL,
    "contentType" VARCHAR(100) NOT NULL,
    "position" INTEGER NOT NULL DEFAULT 0,
    "isCover" BOOLEAN NOT NULL DEFAULT false,
    "isApproved" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PropertyMedia_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "PropertyAuthorization_propertyId_acceptedAt_idx" ON "PropertyAuthorization"("propertyId", "acceptedAt");

-- CreateIndex
CREATE UNIQUE INDEX "PropertyMedia_storageKey_key" ON "PropertyMedia"("storageKey");

-- CreateIndex
CREATE INDEX "PropertyMedia_propertyId_mediaType_isApproved_idx" ON "PropertyMedia"("propertyId", "mediaType", "isApproved");

-- AddForeignKey
ALTER TABLE "PropertyStatusHistory" ADD CONSTRAINT "PropertyStatusHistory_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PropertyAuthorization" ADD CONSTRAINT "PropertyAuthorization_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PropertyMedia" ADD CONSTRAINT "PropertyMedia_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
