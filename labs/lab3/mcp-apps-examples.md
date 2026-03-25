# MCP Apps — реальні кейси використання

## DevOps / SRE

### Автоматичний Post-Mortem
Після інциденту підтягує таймлайн з PagerDuty, Slack-треди та Calendar-блоки під час аутажу — генерує структурований драфт. SRE заповнює прогалини замість того, щоб писати з нуля.

**MCP сервери:** Slack, PagerDuty, Google Calendar

---

### On-Call Handoff
Збирає відкриті алерти, незакриті інциденти та нотатки з попередньої зміни — формує чіткий handoff документ для наступної команди.

**MCP сервери:** PagerDuty, Slack, Jira

---

### Runbook Executor
Отримує алерт → знаходить релевантний runbook у Confluence → постить покрокові інструкції в Slack-канал інциденту. Скорочує MTTR без ручного пошуку документації.

**MCP сервери:** Confluence (Atlassian), Slack

---

### Deploy Risk Assessor
Перед деплоєм аналізує відкриті Jira-тікети, незакриті PR та Calendar (чи не п'ятниця, чи не перед святами) — видає оцінку ризику. Зменшує кількість "Friday deploys".

**MCP сервери:** Jira, GitHub/GitLab, Google Calendar

---

### PR Review Companion
Підсумовує відкриті PR, флагує застарілі, генерує review-коментарі на основі diff-контексту. Корисно для async команд у різних часових поясах.

**MCP сервери:** GitHub/GitLab, Slack

---

### Cross-team Dependency Radar
Сканує Jira та Slack на згадки сервісів вашої команди іншими squads. Виявляє залежності та блокери до того, як вони стають інцидентами.

**MCP сервери:** Jira, Slack

---

## Product / Engineering

### Sprint Kickoff Brief
Читає Jira-тікети наступного спринту, групує по темах, генерує бриф з пріоритетами та залежностями. Ідеально для розподілених команд.

**MCP сервери:** Jira, Google Calendar

---

### Release Notes Generator
Бере merged PR або закриті Jira-тікети → генерує customer-facing release notes в потрібному тоні. Прибирає PM-to-eng back-and-forth по документації.

**MCP сервери:** GitHub/GitLab, Jira

---

### Meeting Prep Packet
Перед будь-якою зустріччю автоматично підтягує релевантні листи, документи та Slack-треди по темі або учасниках. Заходиш підготовленим без 20 хвилин пошуку контексту.

**MCP сервери:** Google Calendar, Gmail, Slack

---

## Бізнес-операції

### Тижневий Executive Briefing
Агрегує активність з Calendar, ключові email-треди та оновлення проєктів — генерує короткий звіт для керівництва. Замінює ручний "status update" email.

**MCP сервери:** Google Calendar, Gmail, Jira

---

### Vendor SLA Tracker
Сканує Gmail на SLA-зобов'язання від вендорів, відстежує дедлайни та флагує ризики. Корисно для procurement команд з великою кількістю контрактів.

**MCP сервери:** Gmail, Google Calendar

---

### Recruitment Pipeline
Підтягує листування з кандидатами з Gmail, парсить їхній статус та будує структурований pipeline. Рекрутер бачить живу картину без окремих таблиць.

**MCP сервери:** Gmail, Google Calendar

---

### Budget Burn Report
Збирає інвойси та PO-підтвердження з email → генерує звіт про витрати відносно квартального бюджету. Engineering leads в курсі без очікування фінансових звітів.

**MCP сервери:** Gmail, Google Drive

---

### Customer Health Dashboard
Підтягує з Salesforce відкриті тікети, останній контакт та дату renewal — все в одному вікні без перемикання між інструментами.

**MCP сервери:** Salesforce, Gmail

---

## Compliance / Security

### SOC 2 / ISO Audit Trail
Сканує Gmail та Calendar на підтвердження обов'язкових touchpoints — quarterly reviews, security trainings, vendor check-ins — флагує прогалини перед аудитом.

**MCP сервери:** Gmail, Google Calendar

---

### Access Review Automation
Збирає дані про активність користувачів та доступи → генерує звіт для quarterly access review. Скорочує ручну роботу compliance-команди.

**MCP сервери:** Okta, Slack, Jira

---

## HR / People Ops

### Onboarding Tracker
Відстежує онбординг-задачі новачка через Calendar-інвайти та email-підтвердження — показує що зроблено, що pending. HR та менеджери синхронізовані без зайвих зустрічей.

**MCP сервери:** Google Calendar, Gmail

---

### Performance Review Prep
Збирає з Calendar зустрічі 1:1, з Gmail — feedback-треди, з Jira — виконані задачі за квартал. Формує структурований драфт для performance review.

**MCP сервери:** Google Calendar, Gmail, Jira

