<div align="center">

<img src="Telegram/Telegram-iOS/DefaultAppIcon.xcassets/AppIconLLC.appiconset/Garantgram.png" width="140" height="140" style="border-radius: 28px;" alt="Garantgram Logo" />

# ⚡ Garantgram for iOS

**Ультимативный клиент Telegram для iPhone и iPad**  
*Приватность без компромиссов: полный Ghost-режим, чистый интерфейс без рекламы и фирменный стиль.*

<br/>

[![Latest Release](https://img.shields.io/github/v/release/Garantka4/Garantgram?color=34C759&label=Latest%20Release&logo=apple&style=for-the-badge)](https://github.com/Garantka4/Garantgram/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-000000?style=for-the-badge&logo=apple)](https://github.com/Garantka4/Garantgram)
[![License](https://img.shields.io/badge/License-GPL--2.0-blue?style=for-the-badge)](LICENSE)
[![Ghost Mode](https://img.shields.io/badge/Ghost%20Mode-100%25%20Active-34C759?style=for-the-badge&logo=ghost)](https://github.com/Garantka4/Garantgram)
[![Ad Free](https://img.shields.io/badge/Ads-100%25%20Blocked-red?style=for-the-badge)](https://github.com/Garantka4/Garantgram)

<br/>

<a href="https://github.com/Garantka4/Garantgram/releases/latest/download/Garantgram.ipa">
  <img src="https://img.shields.io/badge/⬇️_СКАЧАТЬ_GARANTGRAM.IPA-34C759?style=for-the-badge&labelColor=1a1a1a&color=34C759" height="42" />
</a>

<br/><br/>

</div>

---

## ✨ Что такое Garantgram?

**Garantgram** — это независимая модификация официального клиента Telegram для iOS, спроектированная для максимальной анонимности, чистоты и удобства. Всё лишнее убрано, все ограничения сняты, а конфиденциальность возведена в абсолют.

---

## 🔥 Ключевые возможности

### 👻 Полный Ghost Mode (Режим «Призрак»)
* 👁 **Скрытое чтение сообщений**: собеседники не знают, что вы открыли диалог (сообщения остаются непрочитанными с одной галочкой).
* ⌨️ **Скрытый статус активности**: отключена отправка статусов «Печатает...», «Записывает голосовое...» и «Отправка фото/видео».
* 🎭 **Анонимный просмотр Stories**: вы не появляетесь в списке просмотревших ни у пользователей, ни у каналов.

### 🚫 100% блокировка рекламы
* Все спонсорские и рекламные сообщения Telegram заблокированы на уровне сетевого движка (`TelegramCore`).
* Никаких рекламных постов в каналах и навязчивых промо-блоков.

### 🎨 Фирменный зелёный дизайн и эргономика
* **Зелёный акцент по умолчанию**: гармоничный интерфейс в едином стиле Garantgram прямо из коробки.
* **17 бесплатных иконок приложения**: все альтернативные иконки (`Default`, `Day`, `Black`, `Night`, `Sky`, `Neon`, `Gold` и др.) разблокированы и доступны без подписок.
* **Чистый таб-бар**: убраны лишние вкладки с главного экрана — только **Чаты** и **Настройки**.
* **Кастомный Dynamic Island**: стильный бейдж `⚡ GARANTGRAM` в вырезе экрана.

### 🔒 Безопасность оригинала
* Все данные и ключи передаются исключительно напрямую на официальные сервера MTProto Telegram.
* Никаких сторонних серверов, перехватчиков и аналитики.

---

## 📲 Как установить Garantgram на iPhone / iPad

Готовый файл **`Garantgram.ipa`** всегда доступен в разделе **[Releases](../../releases/latest)**.

| Способ | Нужен ПК? | Срок работы | Сложность |
| :--- | :---: | :---: | :---: |
| **Sideloadly** | 💻 Да | 7 дней (автообновление) | 🟢 Простая |
| **AltStore / SideStore** | 💻 Один раз | 7 дней | 🟡 Средняя |
| **Scarlet / ESign** | 📱 Нет | До отзыва сертификата | 🟢 Очень простая |

<details>
<summary><b>📦 Инструкция 1: Установка через Sideloadly (Самый надёжный способ)</b></summary>

1. Скачайте бесплатную программу [Sideloadly](https://sideloadly.io/) на компьютер (Windows / macOS).
2. Подключите iPhone проводом к компьютеру и запустите Sideloadly.
3. Скачайте свежий [Garantgram.ipa](../../releases/latest/download/Garantgram.ipa).
4. Перетащите файл `Garantgram.ipa` в окно Sideloadly.
5. Укажите свой Apple ID и нажмите кнопку **Start**.
6. После установки откройте на iPhone: *Настройки → Основные → VPN и управление устройством*, выберите свой Apple ID и нажмите **«Доверять»**.
</details>

<details>
<summary><b>📱 Инструкция 2: Установка без ПК через Scarlet / ESign</b></summary>

1. Откройте в Safari сайт установщика (например, [usescarlet.com](https://usescarlet.com/)).
2. Установите Scarlet по прямому бесплатному сертификату.
3. Скачайте [Garantgram.ipa](../../releases/latest/download/Garantgram.ipa) на iPhone.
4. Откройте Scarlet, нажмите кнопку импорта в правом верхнем углу и выберите скачанный `.ipa`.
5. Дождитесь завершения установки приложения на домашний экран.
</details>

---

## 🛠 Сборка из исходников

Проект автоматически собирается с помощью сборочной системы **Bazel** в облаке GitHub Actions:

```bash
# Клонирование репозитория
git clone https://github.com/Garantka4/Garantgram.git
cd Garantgram

# Запуск ручной сборки в Actions через GitHub CLI:
gh workflow run build.yml -R Garantka4/Garantgram
```

---

## ⚖️ Лицензия и отказ от ответственности

Garantgram является независимой модификацией на базе открытого исходного кода официального клиента Telegram для iOS. Проект не связан с компанией Telegram FZ-LLC. Все права на оригинальный код Telegram принадлежат их владельцам. Распространяется под лицензией [GNU General Public License v2.0](LICENSE).
