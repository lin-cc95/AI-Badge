import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import type { Request, Response } from 'express';

@Catch()
export class ApiErrorFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const response = context.getResponse<Response>();
    const request = context.getRequest<Request & { requestId?: string }>();
    const status = exception instanceof HttpException ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;
    const raw = exception instanceof HttpException ? exception.getResponse() : undefined;
    const message = typeof raw === 'string'
      ? raw
      : typeof raw === 'object' && raw && 'message' in raw
        ? Array.isArray(raw.message) ? raw.message.join('；') : String(raw.message)
        : '服务暂时不可用，请稍后重试';
    response.status(status).json({
      code: this.codeFor(status),
      message,
      retryable: status >= 500 || status === 429,
      requestId: request.requestId ?? 'unknown',
    });
  }

  private codeFor(status: number): string {
    if (status === 401) return 'AUTH-401';
    if (status === 404) return 'RESOURCE-404';
    if (status === 409) return 'RESOURCE-409';
    if (status === 429) return 'RATE-429';
    return status >= 500 ? 'SYSTEM-500' : 'REQUEST-400';
  }
}

