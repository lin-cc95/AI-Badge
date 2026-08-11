import { JwtService } from '@nestjs/jwt';

import { AuthService } from './auth.service';

describe('AuthService', () => {
  const service = new AuthService(new JwtService({ secret: 'test-secret-at-least-32-characters-long' }));

  it('issues access and refresh tokens for the seeded tester', async () => {
    const session = await service.login('demo', 'Badge123!');
    expect(session.user.id).toBe('user-demo');
    expect(session.accessToken).toBeTruthy();
    expect(session.refreshToken).toBeTruthy();
  });

  it('rejects an invalid password', async () => {
    await expect(service.login('demo', 'wrong')).rejects.toThrow('账号或密码不正确');
  });
});

