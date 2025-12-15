# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.2.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# 1. Робоча папка
WORKDIR /rails

# 2. Встановлюємо системні пакети + Node.js v20 (потрібен для Playwright)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client build-essential libpq-dev git pkg-config gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 3. Налаштування середовища
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    PLAYWRIGHT_BROWSERS_PATH="/ms-playwright"

# --- ЕТАП BUILD (Збірка гемів) ---
FROM base AS build

# Копіюємо Gemfile і встановлюємо геми
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Копіюємо код програми
COPY . .

# Прекомпіляція ассетів (якщо у вас є CSS/JS)
# RUN bundle exec rails assets:precompile

# --- ЕТАП FINAL (Фінальний образ) ---
FROM base

# 1. Копіюємо встановлені геми з етапу build
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# 2. Встановлюємо Playwright браузери (КРИТИЧНИЙ МОМЕНТ)
# Ми робимо це у фінальному образі, щоб браузери були доступні під час роботи
# Використовуємо bundle exec, щоб версії збігалися
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 2. Встановлюємо Playwright через NPM і качаємо браузери
# npm init -y створює пустий package.json, щоб npm не сварився
RUN npm init -y && \
    npm install playwright && \
    mkdir -p $PLAYWRIGHT_BROWSERS_PATH && \
    npx playwright install chromium --with-deps && \
    chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# 3. Створюємо користувача (безпека)
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

# 4. Запуск
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]