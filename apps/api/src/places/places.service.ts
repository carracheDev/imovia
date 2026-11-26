import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';

export interface PlaceSuggestion {
  placeId: string;
  text: string;
}

export interface PlaceDetails extends PlaceSuggestion {
  latitude: number;
  longitude: number;
}

@Injectable()
export class PlacesService {
  private readonly logger = new Logger(PlacesService.name);

  async autocomplete(
    input: string,
    sessionToken: string,
  ): Promise<PlaceSuggestion[]> {
    const response = await this.request(
      'https://places.googleapis.com/v1/places:autocomplete',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-FieldMask':
            'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
        },
        body: JSON.stringify({
          input,
          includedRegionCodes: ['BJ'],
          languageCode: 'fr',
          sessionToken,
        }),
      },
    );
    const body = (await response.json()) as {
      suggestions?: {
        placePrediction?: { placeId?: string; text?: { text?: string } };
      }[];
    };

    return (body.suggestions ?? [])
      .map((suggestion) => suggestion.placePrediction)
      .filter(
        (place): place is { placeId: string; text: { text: string } } =>
          typeof place?.placeId === 'string' &&
          typeof place.text?.text === 'string',
      )
      .slice(0, 5)
      .map((place) => ({ placeId: place.placeId, text: place.text.text }));
  }

  async getDetails(
    placeId: string,
    sessionToken?: string,
  ): Promise<PlaceDetails> {
    if (!/^[A-Za-z0-9_-]{1,255}$/.test(placeId)) {
      throw new BadRequestException('Invalid Google place ID');
    }

    const url = new URL(
      `https://places.googleapis.com/v1/places/${encodeURIComponent(placeId)}`,
    );
    if (sessionToken !== undefined) {
      if (!/^[A-Za-z0-9_-]{16,128}$/.test(sessionToken)) {
        throw new BadRequestException('Invalid Google Places session token');
      }
      url.searchParams.set('sessionToken', sessionToken);
    }

    const response = await this.request(url.toString(), {
      headers: {
        'X-Goog-FieldMask':
          'id,displayName,formattedAddress,location,addressComponents',
      },
    });
    const body = (await response.json()) as {
      id?: string;
      displayName?: { text?: string };
      formattedAddress?: string;
      location?: { latitude?: number; longitude?: number };
      addressComponents?: { types?: string[]; shortText?: string }[];
    };
    const isInBenin = body.addressComponents?.some(
      (component) =>
        component.types?.includes('country') && component.shortText === 'BJ',
    );
    if (!isInBenin) {
      throw new BadRequestException('Choose a place in Benin');
    }
    if (
      typeof body.id !== 'string' ||
      typeof body.location?.latitude !== 'number' ||
      typeof body.location.longitude !== 'number'
    ) {
      throw new BadGatewayException('Google returned incomplete place details');
    }

    return {
      placeId: body.id,
      text: body.formattedAddress ?? body.displayName?.text ?? body.id,
      latitude: body.location.latitude,
      longitude: body.location.longitude,
    };
  }

  private async request(url: string, init: RequestInit): Promise<Response> {
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    if (!apiKey) {
      throw new ServiceUnavailableException(
        'Google Places is not configured on the server',
      );
    }

    let response: Response;
    try {
      response = await fetch(url, {
        ...init,
        headers: { ...init.headers, 'X-Goog-Api-Key': apiKey },
        signal: AbortSignal.timeout(8000),
      });
    } catch (error) {
      this.logger.error(
        'Google Places request failed',
        error instanceof Error ? error.stack : undefined,
      );
      throw new ServiceUnavailableException(
        'Google Places is temporarily unavailable',
      );
    }
    if (!response.ok) {
      this.logger.error(`Google Places returned HTTP ${response.status}`);
      if (response.status === 400) {
        throw new BadRequestException('Google Places rejected the request');
      }
      if (response.status === 404) {
        throw new BadRequestException('Google place was not found');
      }
      throw new ServiceUnavailableException(
        'Google Places is temporarily unavailable',
      );
    }
    return response;
  }
}
