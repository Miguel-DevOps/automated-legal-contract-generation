import { NextResponse } from 'next/server';

export async function GET() {
  // Ejemplo simple, reemplazar por integración real con Prometheus si se requiere
  return new Response('nextjs_example_metric{service="web-frontend"} 1\n', {
    status: 200,
    headers: { 'Content-Type': 'text/plain' },
  });
}
