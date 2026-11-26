-- CreateEnum
CREATE TYPE "MediaUploadStatus" AS ENUM ('PENDING', 'READY');

-- AlterTable
ALTER TABLE "PropertyMedia" ADD COLUMN     "sizeBytes" INTEGER,
ADD COLUMN     "uploadStatus" "MediaUploadStatus" NOT NULL DEFAULT 'PENDING';
