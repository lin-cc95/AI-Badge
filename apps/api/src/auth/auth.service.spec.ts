import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

import { AuthService } from './auth.service';

describe('AuthService', () => {
  const service = new AuthService(
    new JwtService({ secret: 'test-secret-at-least-32-characters-long' }),
    new ConfigService({
      DEMO_USERNAME: 'demo',
      DEMO_PASSWORD: 'Badge123!test',
      DEMO_USER_ID: 'user-demo',
    }),
  );

  it('issues access and refresh tokens for the seeded tester', async () => {
    const session = await service.login('demo', 'Badge123!test');
    expect(session.user.id).toBe('user-demo');
    expect(session.accessToken).toBeTruthy();
    expect(session.refreshToken).toBeTruthy();
  });

  it('rejects an invalid password', async () => {
    await expect(service.login('demo', 'wrong')).rejects.toThrow('账号或密码不正确');
  });
});
