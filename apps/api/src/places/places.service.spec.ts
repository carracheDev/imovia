import { BadRequestException } from '@nestjs/common';
import { PlacesService } from './places.service.js';

describe('PlacesService', () => {
  const service = new PlacesService();
  let originalApiKey: string | undefined;

  beforeEach(() => {
    originalApiKey = process.env.GOOGLE_MAPS_API_KEY;
    process.env.GOOGLE_MAPS_API_KEY = 'test-api-key';
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    if (originalApiKey === undefined) {
      delete process.env.GOOGLE_MAPS_API_KEY;
    } else {
      process.env.GOOGLE_MAPS_API_KEY = originalApiKey;
    }
  });

  it('limits autocomplete to Benin and maps Google suggestions', async () => {
    const fetchMock = vi.fn().mockResolvedValue(
      new Response(
        JSON.stringify({
          suggestions: [
            {
              placePrediction: {
                placeId: 'cotonou-place-id',
                text: { text: 'Cotonou, Bénin' },
              },
            },
          ],
        }),
        { status: 200 },
      ),
    );
    vi.stubGlobal('fetch', fetchMock);

    await expect(
      service.autocomplete('Cot', '0123456789abcdef'),
    ).resolves.toEqual([
      { placeId: 'cotonou-place-id', text: 'Cotonou, Bénin' },
    ]);

    const [url, options] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://places.googleapis.com/v1/places:autocomplete');
    expect(options.headers).toMatchObject({
      'X-Goog-Api-Key': 'test-api-key',
      'X-Goog-FieldMask':
        'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
    });
    expect(JSON.parse(options.body as string)).toMatchObject({
      input: 'Cot',
      includedRegionCodes: ['BJ'],
      languageCode: 'fr',
      sessionToken: '0123456789abcdef',
    });
  });

  it('returns selected place coordinates only for Benin places', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        new Response(
          JSON.stringify({
            id: 'cotonou-place-id',
            formattedAddress: 'Cotonou, Bénin',
            location: { latitude: 6.3654, longitude: 2.4183 },
            addressComponents: [{ types: ['country'], shortText: 'BJ' }],
          }),
          { status: 200 },
        ),
      ),
    );

    await expect(service.getDetails('cotonou-place-id')).resolves.toEqual({
      placeId: 'cotonou-place-id',
      text: 'Cotonou, Bénin',
      latitude: 6.3654,
      longitude: 2.4183,
    });
  });

  it('rejects a selected place outside Benin', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        new Response(
          JSON.stringify({
            id: 'outside-place-id',
            location: { latitude: 48.8566, longitude: 2.3522 },
            addressComponents: [{ types: ['country'], shortText: 'FR' }],
          }),
          { status: 200 },
        ),
      ),
    );

    await expect(service.getDetails('outside-place-id')).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });
});
