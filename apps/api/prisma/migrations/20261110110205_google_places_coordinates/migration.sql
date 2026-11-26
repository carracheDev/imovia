ALTER TABLE "Property"
ADD COLUMN "googlePlaceId" TEXT,
ADD COLUMN "latitude" DOUBLE PRECISION,
ADD COLUMN "longitude" DOUBLE PRECISION,
ADD COLUMN "googleCoordinatesFetchedAt" TIMESTAMP(3);

CREATE INDEX "Property_googlePlaceId_googleCoordinatesFetchedAt_idx"
ON "Property"("googlePlaceId", "googleCoordinatesFetchedAt");

CREATE INDEX "Property_latitude_longitude_googleCoordinatesFetchedAt_idx"
ON "Property"("latitude", "longitude", "googleCoordinatesFetchedAt");
