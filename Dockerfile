# =============================================================================
# DOCKERFILE ÚNICO Y DINÁMICO PARA TODOS LOS SERVICIOS
# =============================================================================
# Uso:
#   docker build --build-arg SERVICE_NAME=auth-service .
#   docker build --build-arg SERVICE_NAME=api-gateway .
#   docker build --build-arg SERVICE_NAME=web .
# =============================================================================

# Argumento que define qué servicio construir
ARG SERVICE_NAME
ARG SERVICE_TYPE="nestjs"  # nestjs | nextjs

# =============================================================================
# STAGE 1: BASE - Configuración común
# =============================================================================
FROM node:18-alpine AS base

# Instalar pnpm
RUN npm install -g pnpm

# Establecer directorio de trabajo
WORKDIR /usr/src/app

# Copiar archivos de configuración del monorepo
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# =============================================================================
# STAGE 2: DEPS - Instalar dependencias
# =============================================================================
FROM base AS deps

# Copiar toda la estructura de packages para que pnpm pueda resolver las dependencias
COPY apps/ ./apps/
COPY packages/ ./packages/

# Instalar todas las dependencias
RUN pnpm install --frozen-lockfile

# =============================================================================
# STAGE 3: BUILDER - Construcción específica por servicio
# =============================================================================
FROM deps AS builder

# Re-declarar ARG para usar en esta etapa
ARG SERVICE_NAME
ARG SERVICE_TYPE

# El código ya está copiado de la etapa anterior, solo construir
RUN if [ "$SERVICE_TYPE" = "nestjs" ]; then \
        cd apps/${SERVICE_NAME} && \
        pnpm build; \
    elif [ "$SERVICE_TYPE" = "nextjs" ]; then \
        cd apps/${SERVICE_NAME} && \
        pnpm build; \
    fi

# =============================================================================
# STAGE 4: RUNNER - Imagen de producción
# =============================================================================
FROM node:18-alpine AS runner

# Re-declarar ARGs
ARG SERVICE_NAME
ARG SERVICE_TYPE
ARG SERVICE_PORT=3000

WORKDIR /usr/src/app

# Instalar pnpm globalmente
RUN npm install -g pnpm

# Crear usuario no-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copiar node_modules (manteniendo estructura del monorepo)
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copiar archivos según el tipo de servicio
RUN if [ "$SERVICE_TYPE" = "nestjs" ]; then \
        mkdir -p ./apps/${SERVICE_NAME}; \
    elif [ "$SERVICE_TYPE" = "nextjs" ]; then \
        mkdir -p ./apps/${SERVICE_NAME}; \
    fi

COPY --from=builder /usr/src/app/apps/${SERVICE_NAME}/ ./apps/${SERVICE_NAME}/

# Cambiar propietario de archivos
RUN chown -R appuser:appgroup /usr/src/app

# Cambiar a usuario no-root
USER appuser

# Exponer puerto
EXPOSE ${SERVICE_PORT}

# Cambiar al directorio del servicio
WORKDIR /usr/src/app/apps/${SERVICE_NAME}

# Comando de inicio según el tipo de servicio
CMD if [ "$SERVICE_TYPE" = "nextjs" ]; then \
        pnpm start; \
    else \
        node dist/main.js; \
    fi
