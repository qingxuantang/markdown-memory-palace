# Memory Palace for Claude Code

> 💡 **Inspired by [milla-jovovich/mempalace](https://github.com/milla-jovovich/mempalace)** — this project reimplements the wings/rooms/halls/drawers mental model on top of plain markdown files, designed natively for Claude Code.
>
> 💡 **灵感来自 [milla-jovovich/mempalace](https://github.com/milla-jovovich/mempalace)** —— 本项目用纯 Markdown 文件重新实现了"侧厅/房间/大厅/抽屉"的心智模型，为 Claude Code 原生设计。

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

---

<a id="english"></a>

## English

A **markdown-native long-term memory system** for Claude Code, inspired by [MemPalace](https://github.com/milla-jovovich/mempalace) but built entirely on plain files — no databases, no MCP servers, no external runtimes.

### Why

Claude Code forgets everything between sessions except what's in `~/.claude/projects/<slug>/memory/`. By default that's just four flat files (`user.md`, `project.md`, `reference.md`, `feedback.md`). For anything bigger than a hobby project, you need **structure** — a way to organize months of facts, decisions, debugging discoveries, and advice without dumping it all into one growing README.

Memory Palace gives you that structure without locking you in. Everything is plain markdown + YAML frontmatter that any AI tool, any text editor, and any human can read forever.

### Key features

- 🏛 **Hierarchical**: `wings → rooms → halls → drawers` — five layers, scales from 10 entries to 10,000
- 📝 **Markdown-only**: every entry is a `.md` file. No SQLite, no embeddings, no vector index
- 🔌 **Zero lock-in**: leave any time. `cp -r` is a complete migration
- 🤖 **Claude Code native**: lives at `~/.claude/projects/<slug>/memory/` so the L1 layer auto-loads at session start
- 🌐 **Multi-client friendly**: any other AI tool that can read files (Cursor, Aider, etc.) can also read your palace
- 🔀 **Git-friendly**: history, diffs, blame, merge — all standard
- 🗣 **Natural-language triggers**: never type a slash command. Just say "记一下" / "remember this" / "回忆一下" / "recall ..." and the skill routes automatically
- 🌏 **Bilingual**: English + Chinese trigger phrases out of the box
- 🔍 **LLM-driven routing**: a separate prompt decides wing/room/hall — no manual filing
- 🚨 **Contradiction detection**: weekly audit finds factual / scope / implicit contradictions across the whole palace
- 🕒 **Time-aware**: every entry has `valid_from` / `valid_until` / `superseded_by` — stale knowledge is marked, not deleted

### Architecture

```
PALACE_ROOT/
├── user.md                 # L1 - facts about you (auto-loaded)
├── project.md              # L1 - active projects index
├── reference.md            # L1 - tools/servers/manuals index
├── feedback.md             # L1 - corrections and open questions
├── timeline.md             # global event log, newest first
├── .palace-config.yaml
│
├── wings/
│   └── <wing>/             # top-level life domain (personal, projects, infrastructure...)
│       ├── _closet.md      # 300-800 word summary of the wing
│       └── <room>/         # specific topic within a wing
│           ├── _closet.md
│           ├── facts.md         # the 5 halls
│           ├── events.md
│           ├── discoveries.md
│           ├── preferences.md
│           ├── advice.md
│           └── drawers/         # long-form entries
│               └── YYYY-MM-DD-<slug>.md
│
└── audits/
    └── YYYY-MM-DD-<scope>.md    # contradiction reports
```

### The 13 subcommands

| Command | Purpose | Example trigger |
|---|---|---|
| `init` | Create palace skeleton | "initialize memory palace" / "建一下记忆宫殿" |
| `remember` | Store a new memory | "remember this" / "记一下" / "存一下" |
| `recall` | Search the palace | "recall the deploy steps" / "回忆一下部署流程" |
| `timeline` | Chronological view | "show the timeline" / "时间线" |
| `wake-up` | Reload L1 mid-session | "wake up" / "唤醒记忆" |
| `new-drawer` | Manually create a drawer | "new drawer for ..." / "新建抽屉" |
| `list-wings` | Show all wings | "list wings" / "有哪些侧厅" |
| `status` | Palace stats | "palace status" / "宫殿多大了" |
| `migrate-from` | Bulk import existing docs | "import from <path>" / "把文档导进来" |
| `check` | Contradiction audit | "check for contradictions" / "审一下记忆" |
| `closet` | Regenerate summaries | "refresh closets" / "刷新摘要" |
| `tunnel` | Cross-link two rooms | "link these rooms" / "建一个通道" |
| `export` | Disaster-recovery dump | "export the palace" / "导出记忆宫殿" |

Each command has 5–15 natural-language trigger phrases in both English and Chinese. **You never type `/mp xxx` literally** — the skill listens for keywords in normal conversation.

### The five halls

Every room has the same five files:

| Hall | What goes here |
|---|---|
| `facts.md` | Durable factual claims ("Production DB is Postgres 16") |
| `events.md` | Things that happened on a date ("2026-04-07 deployed v2") |
| `discoveries.md` | Insights, debugging breakthroughs, "I would have bet wrong" findings |
| `preferences.md` | Tastes, habits, opinions ("prefers terse error messages") |
| `advice.md` | Recommendations and warnings for future-self |

The split forces you to think about *what kind* of knowledge you're storing, which makes recall vastly more accurate.

### Installation

```bash
# Option 1: clone into your global skills dir
git clone https://github.com/<your-user>/memory-palace ~/tmp/mp
cp -r ~/tmp/mp/skills/memory-palace ~/.claude/skills/

# Option 2: project-local
cd your-project
mkdir -p .claude/skills
cp -r ~/tmp/mp/skills/memory-palace .claude/skills/
```

Then in any Claude Code session, just say:

> 建一下记忆宫殿

or

> initialize the memory palace

and start storing memories.

### Quick start

```
You: 建一下记忆宫殿
Claude: ✓ Initialized palace at ~/.claude/projects/<slug>/memory/

You: 记一下，我们的生产数据库是 Postgres 16，跑在 AWS RDS 上
Claude: ✓ Stored in infrastructure/database/facts.md

You: 我们之前是不是说过数据库版本？
Claude: Yes — Production DB is Postgres 16 on AWS RDS
        Source: infrastructure/database/facts.md
```

No commands. Just talk.

### Design decisions

- **No embeddings**: Grep + hierarchical navigation is faster, free, and good enough for ≤ 10K entries
- **No SQLite**: zero format lock-in. Markdown lasts forever
- **5 halls, not freeform tags**: forces categorization, makes recall predictable
- **Drawer threshold = 800 chars**: short stuff stays inline (faster reads), long stuff gets its own file (cleaner diffs)
- **Confirmation gate only for new wings**: bullets, sections, and new rooms are silent — minimum friction
- **Time-aware via frontmatter, not deletion**: history is preserved, supersession is explicit
- **Natural language > slash commands**: humans don't think in CLI

For the full rationale, see [`skills/memory-palace/references/architecture.md`](skills/memory-palace/references/architecture.md).

### Comparison to MemPalace

| | MemPalace | Memory Palace (this) |
|---|---|---|
| Storage | SQLite + AAAK compressed text | Plain markdown + YAML frontmatter |
| Runtime | MCP server (Python) | None — just files |
| Lock-in | Need MemPalace to read your data | Any text editor / `cat` / `grep` |
| AI client compat | MemPalace-aware tools only | Any tool that can read files |
| Concurrency | Single-writer (server) | Git-mediated |
| Search | SQL + AAAK queries | Grep + hierarchical |
| Setup cost | Install Python + run server | Copy a folder |
| Best for | Single-tool deep integration | Multi-tool, long-term, portable |

Memory Palace makes the opposite trade-off: lighter, more portable, and built around Claude Code's existing memory conventions instead of replacing them.

### Status

**v0.1** — usable, in active personal validation. APIs (file structure, frontmatter schema, prompt interfaces) may shift before v1.0. Expect rough edges in:

- `closet` and `check` are PR2 features and have not yet been battle-tested
- `migrate-from` works but routing accuracy depends on the LLM call
- Performance unknown beyond ~500 entries (untested at scale)

If you use this, file issues with what works and what doesn't.

### License

MIT. See [LICENSE](LICENSE).

### Credits

- Conceptual inspiration: [MemPalace](https://github.com/milla-jovovich/mempalace)
- Built for use with [Claude Code](https://claude.com/claude-code)

---

<a id="中文"></a>

## 中文

为 Claude Code 设计的**纯 Markdown 长期记忆系统**。灵感来自 [MemPalace](https://github.com/milla-jovovich/mempalace)，但完全用普通文件实现——没有数据库、没有 MCP 服务器、没有外部运行时。

### 为什么需要它

Claude Code 在 session 之间会**忘掉一切**，除了 `~/.claude/projects/<slug>/memory/` 里的内容。默认只有 4 个扁平文件（user/project/reference/feedback）。任何比玩具项目更复杂的场景，你都需要**结构**——一种把几个月的事实、决策、调试发现、建议组织起来的方式，而不是全堆进一个越长越大的 README。

Memory Palace 给你这个结构，但**不锁定你**。所有内容都是普通 markdown + YAML frontmatter，任何 AI 工具、任何文本编辑器、任何人都能永远读懂。

### 核心特性

- 🏛 **分层结构**：`侧厅 → 房间 → 大厅 → 抽屉` —— 五层嵌套，从 10 条到 1 万条都能扛
- 📝 **纯 Markdown**：每条记忆都是 `.md` 文件。没有 SQLite、没有 embedding、没有向量索引
- 🔌 **零锁定**：随时离开。`cp -r` 就是完整迁移
- 🤖 **Claude Code 原生**：放在 `~/.claude/projects/<slug>/memory/`，session 启动时 L1 层自动加载
- 🌐 **多客户端友好**：任何能读文件的 AI 工具（Cursor、Aider 等）都能读你的宫殿
- 🔀 **Git 友好**：历史、diff、blame、merge 全部标准支持
- 🗣 **自然语言触发**：永远不用敲斜杠命令。只需要说"记一下"/"回忆一下"/"remember this"/"recall ..." 即可
- 🌏 **中英双语**：英文 + 中文触发短语开箱即用
- 🔍 **LLM 驱动的路由**：单独的 prompt 决定侧厅/房间/大厅，不用手动归档
- 🚨 **矛盾检测**：每周审计，扫出全宫殿的事实/范围/隐含矛盾
- 🕒 **时间感知**：每条记忆都有 `valid_from` / `valid_until` / `superseded_by`，过期知识被**标记**而不是删除

### 13 个子命令

| 命令 | 用途 | 中文触发示例 |
|---|---|---|
| `init` | 初始化宫殿骨架 | "建一下记忆宫殿" |
| `remember` | 存入新记忆 | "记一下" / "存一下" / "归档一下" |
| `recall` | 检索宫殿 | "回忆一下" / "之前是怎么说的" |
| `timeline` | 时间线视图 | "时间线" / "最近做了什么" |
| `wake-up` | session 中重新加载 L1 | "唤醒记忆" |
| `new-drawer` | 手动建抽屉 | "开一个抽屉" |
| `list-wings` | 列出所有侧厅 | "有哪些侧厅" |
| `status` | 宫殿统计 | "宫殿多大了" |
| `migrate-from` | 批量导入现有文档 | "把文档导进来" |
| `check` | 矛盾审计 | "审一下记忆" |
| `closet` | 重新生成摘要 | "刷新摘要" |
| `tunnel` | 跨房间双向链接 | "建一个通道" |
| `export` | 灾难恢复导出 | "导出记忆宫殿" |

每个命令都有 5–15 个中英双语触发短语。**你永远不需要敲 `/mp xxx`**——skill 监听日常对话里的关键词。

### 五个大厅

每个房间都有相同的五个文件：

| 大厅 | 存什么 |
|---|---|
| `facts.md` | 持久的事实陈述（"生产数据库是 Postgres 16"） |
| `events.md` | 在某天发生的事（"2026-04-07 部署 v2"） |
| `discoveries.md` | 洞察、调试突破、"原本以为会失败但居然..." 的发现 |
| `preferences.md` | 口味、习惯、观点（"偏好简洁的错误信息"） |
| `advice.md` | 给未来自己的建议和警告 |

强制分类反而让你更清楚自己在存**哪种**知识，检索时准确率高得多。

### 安装

```bash
# 方式一：克隆到全局 skills 目录
git clone https://github.com/<your-user>/memory-palace ~/tmp/mp
cp -r ~/tmp/mp/skills/memory-palace ~/.claude/skills/

# 方式二：项目级
cd your-project
mkdir -p .claude/skills
cp -r ~/tmp/mp/skills/memory-palace .claude/skills/
```

然后在任何 Claude Code session 里说一句：

> 建一下记忆宫殿

就开始用了。

### Quick Start

```
你：建一下记忆宫殿
Claude：✓ 已在 ~/.claude/projects/<slug>/memory/ 初始化宫殿

你：记一下，我们的生产数据库是 Postgres 16，跑在 AWS RDS 上
Claude：✓ 已存到 infrastructure/database/facts.md

你：我们之前是不是说过数据库版本？
Claude：是的——生产数据库是 Postgres 16 on AWS RDS
        来源：infrastructure/database/facts.md
```

不用敲任何命令，就这么自然。

### 设计取舍

- **不用 embedding**：Grep + 分层导航更快、免费，且对 ≤ 1 万条够用
- **不用 SQLite**：零格式锁定。Markdown 永远可读
- **5 个大厅而不是自由 tag**：强制分类，检索可预测
- **抽屉阈值 = 800 字符**：短的留 inline（读得快），长的独立成文件（diff 干净）
- **只有新建侧厅才需确认**：bullet、section、新房间都静默处理——最小摩擦
- **时间感知用 frontmatter 不用删除**：历史保留，supersession 显式
- **自然语言 > 斜杠命令**：人类不应该用 CLI 思维和 AI 对话

完整理由见 [`skills/memory-palace/references/architecture.md`](skills/memory-palace/references/architecture.md)。

### 与 MemPalace 对比

| | MemPalace | Memory Palace（本项目） |
|---|---|---|
| 存储 | SQLite + AAAK 压缩文本 | 纯 Markdown + YAML frontmatter |
| 运行时 | MCP server (Python) | 无 —— 只有文件 |
| 锁定 | 需要 MemPalace 才能读 | 任何文本编辑器 / `cat` / `grep` |
| 多客户端 | 仅支持 MemPalace-aware 工具 | 任何能读文件的工具 |
| 并发 | 单写者（服务器） | Git 协调 |
| 搜索 | SQL + AAAK 查询 | Grep + 分层 |
| 安装成本 | 装 Python + 跑服务器 | 复制一个目录 |
| 最适合 | 单工具深度集成 | 多工具、长期、可移植 |

Memory Palace 做的是相反的取舍：更轻量、更可移植、围绕 Claude Code 现有的记忆约定**扩展**而不是替换。

### 当前状态

**v0.1** —— 可用，正在个人项目里实战验证。在 v1.0 之前，API（文件结构、frontmatter schema、prompt 接口）可能调整。已知粗糙之处：

- `closet` 和 `check` 是 PR2 功能，未充分实战
- `migrate-from` 能用，但路由准确度取决于 LLM 的判断
- 超过 500 条以后的性能表现未知

用过的话欢迎 issue 反馈。

### License

MIT。详见 [LICENSE](LICENSE)。

### 致谢

- 概念灵感：[MemPalace](https://github.com/milla-jovovich/mempalace)
- 为 [Claude Code](https://claude.com/claude-code) 设计
