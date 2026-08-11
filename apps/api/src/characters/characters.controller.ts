import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { CreateCharacterDto } from './characters.dto';
import { CharactersService } from './characters.service';

@ApiTags('characters')
@Controller('characters')
export class CharactersController {
  constructor(private readonly characters: CharactersService) {}
  @Get() list() { return this.characters.list(); }
  @Post() create(@Body() input: CreateCharacterDto) { return this.characters.create(input); }
  @Post(':id/current') setCurrent(@Param('id') id: string) { return this.characters.setCurrent(id); }
}

