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
      service: 'contracts-service',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('metrics')
  metrics() {
    return 'nestjs_example_metric{service="contracts-service"} 1\n';
  }
}
