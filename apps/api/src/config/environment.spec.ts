import { validateEnvironment } from './environment';

const valid = {
  JWT_SECRET: 'valid-secret-at-least-32-characters-long',
  DEMO_USERNAME: 'demo',
  DEMO_PASSWORD: 'valid-demo-password',
};

describe('validateEnvironment', () => {
  it('accepts explicit local development credentials', () => {
    expect(validateEnvironment(valid)).toMatchObject(valid);
  });

  it('rejects example placeholders', () => {
    expect(() => validateEnvironment({ ...valid, JWT_SECRET: 'replace-with-at-least-32-random-characters' }))
      .toThrow('JWT_SECRET still contains an example placeholder');
  });

  it('rejects wildcard CORS origins', () => {
    expect(() => validateEnvironment({ ...valid, CORS_ORIGINS: '*' }))
      .toThrow('wildcard origins are not allowed');
  });

  it('requires a token before metrics can be exposed', () => {
    expect(() => validateEnvironment({ ...valid, EXPOSE_METRICS: 'true' }))
      .toThrow('METRICS_TOKEN must contain at least 32 characters');
  });
});
