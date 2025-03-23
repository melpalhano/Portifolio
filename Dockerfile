# Estágio de build
FROM node:20-alpine AS builder

# Definindo diretório de trabalho
WORKDIR /app

# Instalando pnpm globalmente
RUN npm install -g pnpm

# Copiando arquivos de dependências
COPY package.json pnpm-lock.yaml ./

# Instalando dependências
RUN pnpm install --frozen-lockfile

# Copiando arquivos do projeto
COPY . .

# Gerando build da aplicação
RUN pnpm build

# Estágio de produção
FROM node:20-alpine AS runner

WORKDIR /app

# Instalando pnpm globalmente
RUN npm install -g pnpm

# Copiando arquivos necessários do estágio de build
COPY --from=builder /app/package.json .
COPY --from=builder /app/pnpm-lock.yaml .
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts .

# Instalando apenas dependências de produção
RUN pnpm install --prod --frozen-lockfile

# Expondo a porta 3000
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["pnpm", "start"] 