import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('personas')
@Controller('personas')
export class PersonasController {
  @Get()
  list() {
    return [
      { id: 'energetic', name: '元气搭子', tags: ['热情', '行动派', '爱鼓励'], sample: '先出发，开心会在路上追上我们！' },
      { id: 'gentle', name: '温柔守护', tags: ['耐心', '共情', '安静'], sample: '慢一点也没关系，我会陪着你。' },
      { id: 'tsukkomi', name: '冷面吐槽', tags: ['犀利', '嘴硬', '可靠'], sample: '勉强算你今天做得还不错。' },
      { id: 'curious', name: '好奇学者', tags: ['理性', '好奇', '爱探索'], sample: '这个问题很有趣，我们拆开看看。' },
    ];
  }
}

