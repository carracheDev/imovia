import {
  BadRequestException,
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { AutocompleteDto } from './dto/autocomplete.dto.js';
import { PlacesService } from './places.service.js';

@ApiTags('Places')
@Controller('places')
export class PlacesController {
  constructor(private readonly places: PlacesService) {}

  @Get('autocomplete')
  autocomplete(@Query() query: AutocompleteDto) {
    return this.places.autocomplete(query.input.trim(), query.sessionToken);
  }

  @Get(':placeId')
  getDetails(
    @Param('placeId') placeId: string,
    @Query('sessionToken') sessionToken?: string,
  ) {
    if (!sessionToken) {
      throw new BadRequestException(
        'A Google Places session token is required',
      );
    }
    return this.places.getDetails(placeId, sessionToken);
  }
}
