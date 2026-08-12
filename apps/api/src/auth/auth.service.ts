import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as argon2 from 'argon2';

@Injectable()
export class AuthService {
  private demoHash?: string;
  private readonly revoked = new Set<string>();

  constructor(private readonly jwt: JwtService, private readonly config: ConfigService) {}

  async login(username: string, password: string) {
    const configuredUsername = this.config.getOrThrow<string>('DEMO_USERNAME');
    const configuredPassword = this.config.getOrThrow<string>('DEMO_PASSWORD');
    this.demoHash ??= await argon2.hash(configuredPassword, { type: argon2.argon2id });
    if (username !== configuredUsername || !(await argon2.verify(this.demoHash, password))) {
      throw new UnauthorizedException('账号或密码不正确');
    }
    return this.issue(username);
  }

  async refresh(refreshToken: string) {
    if (this.revoked.has(refreshToken)) throw new UnauthorizedException('刷新令牌已失效');
    try {
      const payload = await this.jwt.verifyAsync<{ sub: string; username: string; type: string }>(refreshToken);
      if (payload.type !== 'refresh') throw new Error('wrong token type');
      this.revoked.add(refreshToken);
      return this.issue(payload.username);
    } catch {
      throw new UnauthorizedException('刷新令牌已失效');
    }
  }

  logout(refreshToken?: string) {
    if (refreshToken) this.revoked.add(refreshToken);
    return { success: true };
  }

  private async issue(username: string) {
    const payload = { sub: this.config.get<string>('DEMO_USER_ID', 'user-demo'), username };
    return {
      accessToken: await this.jwt.signAsync(payload, { expiresIn: 15 * 60 }),
      refreshToken: await this.jwt.signAsync({ ...payload, type: 'refresh' }, { expiresIn: 30 * 24 * 60 * 60 }),
      user: { id: payload.sub, username, nickname: this.config.get<string>('DEMO_NICKNAME', '内测玩家') },
    };
  }
}
