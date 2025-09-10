import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('health')
  health() {
    return {
      status: 'ok',
      service: 'auth-service',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('metrics')
  metrics() {
    // Ejemplo simple, reemplazar por integración real con Prometheus
    return 'nestjs_example_metric{service="auth-service"} 1\n';
  }
}
