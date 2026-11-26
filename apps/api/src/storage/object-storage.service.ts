import {
  CreateBucketCommand,
  CopyObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand,
  HeadBucketCommand,
  HeadObjectCommand,
  PutBucketCorsCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { createPresignedPost } from '@aws-sdk/s3-presigned-post';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';

export const MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024;
const MIME_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);

@Injectable()
export class ObjectStorageService implements OnModuleInit, OnModuleDestroy {
  private readonly bucket: string;
  private readonly client: S3Client;
  private readonly isProduction: boolean;

  constructor() {
    this.isProduction = process.env.NODE_ENV === 'production';
    const endpoint =
      process.env.OBJECT_STORAGE_ENDPOINT ??
      (this.isProduction ? undefined : 'http://localhost:18333');
    const accessKeyId =
      process.env.OBJECT_STORAGE_ACCESS_KEY ??
      (this.isProduction ? undefined : 'caranova');
    const secretAccessKey =
      process.env.OBJECT_STORAGE_SECRET_KEY ??
      (this.isProduction ? undefined : 'caranova_local_storage');
    this.bucket = process.env.OBJECT_STORAGE_BUCKET ?? 'caranova-media';

    if (!endpoint || !accessKeyId || !secretAccessKey) {
      throw new Error(
        'Object storage credentials and endpoint must be configured',
      );
    }

    this.client = new S3Client({
      endpoint,
      region: process.env.OBJECT_STORAGE_REGION ?? 'us-east-1',
      forcePathStyle: true,
      credentials: { accessKeyId, secretAccessKey },
    });
  }

  async onModuleInit() {
    if (this.isProduction) return;

    try {
      await this.client.send(new HeadBucketCommand({ Bucket: this.bucket }));
    } catch (error) {
      if (!this.isNotFound(error)) throw error;
      await this.client.send(new CreateBucketCommand({ Bucket: this.bucket }));
    }
    await this.client.send(
      new PutBucketCorsCommand({
        Bucket: this.bucket,
        CORSConfiguration: {
          CORSRules: [
            {
              AllowedOrigins: ['*'],
              AllowedMethods: ['GET', 'POST', 'PUT', 'HEAD'],
              AllowedHeaders: ['*'],
              ExposeHeaders: ['ETag'],
              MaxAgeSeconds: 3000,
            },
          ],
        },
      }),
    );
  }

  onModuleDestroy() {
    this.client.destroy();
  }

  async createImageUpload(storageKey: string, contentType: string) {
    if (!MIME_TYPES.has(contentType)) {
      throw new Error(`Unsupported image content type: ${contentType}`);
    }

    return createPresignedPost(this.client, {
      Bucket: this.bucket,
      Key: storageKey,
      Expires: 300,
      Fields: { 'Content-Type': contentType },
      Conditions: [
        ['content-length-range', 1, MAX_IMAGE_SIZE_BYTES],
        ['eq', '$Content-Type', contentType],
        ['eq', '$key', storageKey],
      ],
    });
  }

  async inspectImage(storageKey: string) {
    const object = await this.client.send(
      new HeadObjectCommand({ Bucket: this.bucket, Key: storageKey }),
    );
    return {
      sizeBytes: object.ContentLength,
      contentType: object.ContentType,
    };
  }

  async copyImage(sourceKey: string, destinationKey: string) {
    const encodedSourceKey = sourceKey
      .split('/')
      .map(encodeURIComponent)
      .join('/');
    await this.client.send(
      new CopyObjectCommand({
        Bucket: this.bucket,
        Key: destinationKey,
        CopySource: `${this.bucket}/${encodedSourceKey}`,
        MetadataDirective: 'COPY',
      }),
    );
  }

  async deleteImage(storageKey: string) {
    await this.client.send(
      new DeleteObjectCommand({ Bucket: this.bucket, Key: storageKey }),
    );
  }

  async hasExpectedImageSignature(
    storageKey: string,
    contentType: string,
  ): Promise<boolean> {
    const response = await this.client.send(
      new GetObjectCommand({
        Bucket: this.bucket,
        Key: storageKey,
        Range: 'bytes=0-15',
      }),
    );
    if (!response.Body) return false;
    const bytes = Buffer.from(await response.Body.transformToByteArray());

    if (contentType === 'image/jpeg') {
      return (
        bytes.length >= 3 &&
        bytes[0] === 0xff &&
        bytes[1] === 0xd8 &&
        bytes[2] === 0xff
      );
    }
    if (contentType === 'image/png') {
      return bytes
        .subarray(0, 8)
        .equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
    }
    return (
      contentType === 'image/webp' &&
      bytes.length >= 12 &&
      bytes.toString('ascii', 0, 4) === 'RIFF' &&
      bytes.toString('ascii', 8, 12) === 'WEBP'
    );
  }

  async createDownloadUrl(storageKey: string) {
    return getSignedUrl(
      this.client,
      new GetObjectCommand({ Bucket: this.bucket, Key: storageKey }),
      { expiresIn: 300 },
    );
  }

  private isNotFound(error: unknown): boolean {
    return (
      typeof error === 'object' &&
      error !== null &&
      '$metadata' in error &&
      typeof error.$metadata === 'object' &&
      error.$metadata !== null &&
      'httpStatusCode' in error.$metadata &&
      error.$metadata.httpStatusCode === 404
    );
  }
}
