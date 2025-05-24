# Roact Starter Template

Шаблон для быстрого старта разработки UI на Roact для Roblox с использованием Rojo и Wally.

## Структура проекта

- `src/` — исходный код (Roact-компоненты и скрипты)
- `Packages/` — зависимости Wally (автоматически генерируется)
- `default.project.json` — конфиг Rojo

## Быстрый старт

1. **Установите [Wally](https://github.com/UpliftGames/wally) и [Rojo](https://github.com/rojo-rbx/rojo).**
2. В терминале выполните:
   ```sh
   wally install
   ```
3. Откройте Roblox Studio, запустите Rojo:
   ```sh
   rojo serve
   ```
4. В Roblox Studio подключитесь к серверу Rojo (`localhost:34872`).
5. После запуска игры вы увидите кнопку "Hello, Roact!" на экране.

## Зависимости

- [Roact](https://github.com/Roblox/roact) (подключается через Wally)

## Пример компонента

В `src/App/SimpleButton.lua` реализован простой компонент-кнопка на Roact.

---

**Удачной разработки!**
