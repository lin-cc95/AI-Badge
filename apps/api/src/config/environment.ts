const required = ['JWT_SECRET', 'DEMO_USERNAME', 'DEMO_PASSWORD'] as const;

function text(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

export function validateEnvironment(input: Record<string, unknown>): Record<string, unknown> {
  const environment = { ...input };
  for (const name of required) {
    if (!text(environment[name])) {
      throw new Error(`${name} is required. Copy apps/api/.env.example to apps/api/.env and replace all placeholders.`);
    }
  }

  if (text(environment.JWT_SECRET).length < 32) {
    throw new Error('JWT_SECRET must contain at least 32 characters.');
  }
  if (text(environment.DEMO_PASSWORD).length < 12) {
    throw new Error('DEMO_PASSWORD must contain at least 12 characters.');
  }
  for (const name of ['JWT_SECRET', 'DEMO_PASSWORD'] as const) {
    if (/^(replace|change)-/i.test(text(environment[name]))) {
      throw new Error(`${name} still contains an example placeholder.`);
    }
  }

  const exposeMetrics = text(environment.EXPOSE_METRICS).toLowerCase() === 'true';
  if (exposeMetrics && text(environment.METRICS_TOKEN).length < 32) {
    throw new Error('METRICS_TOKEN must contain at least 32 characters when EXPOSE_METRICS=true.');
  }

  const origins = text(environment.CORS_ORIGINS);
  if (origins.split(',').map((origin) => origin.trim()).includes('*')) {
    throw new Error('CORS_ORIGINS must list explicit origins; wildcard origins are not allowed.');
  }

  return environment;
}
