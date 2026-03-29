# zhenyi-site

Zhenyi 对外官网（静态页）：首页突出 **Zhenyi 主项目**；**zhenyi-base** 的安装、示例与压测见二级页 [`base.html`](base.html)。少堆内部术语，细节链到仓库文档。

**Go 版本（与各自仓库 `go.mod` 对齐）**：**Zhenyi** 要求 **Go 1.25+**；**zhenyi-base** 要求 **Go 1.24+**。

**线上地址**：<https://zhenyi-site.pages.dev/>

## 内容大致有这些

- **首页**：Zhenyi 主项目叙事与三层分工
- **zhenyi-base 专页** [`base.html`](base.html)：安装、示例代码、压测图
- **图书**：官网在线阅读 <https://zhenyi-site.pages.dev/book/>；源码书稿 [Go Actor 模型与实时应用](https://github.com/aiyang-zh/zhenyi/blob/main/docs/books/go-actor-realtime/README.md)（导航与页脚「图书」→ `/book/`）
- **信创**：指向 zhenyi 仓库 [docs/XINCHUANG.md](https://github.com/aiyang-zh/zhenyi/blob/main/docs/XINCHUANG.md)
- **合作与安全**：贡献、商务、安全披露入口
- **渠道推广底稿**：[`docs/promo/`](docs/promo/README.md)（掘金 / 知乎 / 微信等 Markdown，与 **zhenyi + zhenyi-base** 同一生态）

## 本地预览

先 `cd` 到本目录（和 `index.html` 同级），再启服务：

```bash
cd /path/to/zhenyi-site
python3 -m http.server 8080
# 浏览器打开 http://localhost:8080/
```

## 构建图书（HonKit）

书稿在 **zhenyi** 仓库 `docs/books/go-actor-realtime`。

```bash
npm ci
npm run build          # 推荐：无本地 zhenyi 时会浅克隆 GitHub 上的 zhenyi
# 已有 ../zhenyi 时直接用本地书稿，不克隆
# 显式指定：BOOK_SRC=/path/to/go-actor-realtime npm run build:book
```

`npm run build` 实际执行 `scripts/build-book.sh`：优先 **`BOOK_SRC`**，其次 **`../zhenyi/docs/books/go-actor-realtime`**，否则克隆到 **`.zhenyi-book-src/`**（已 `.gitignore`）。产物在 **`book/`**（已忽略，由 CI/构建机生成）。

**请把 `package-lock.json` 提交进仓库**，以便 `npm ci` 可复现依赖。

## 部署（自动含 `/book/`）

任选其一，**不要**对同一仓库同时开两套自动部署，否则会重复发布。

### A. Cloudflare Pages 连接 GitHub（推荐，无需在 GitHub 存 CF 密钥）

在 Pages 项目里：

- **框架预设**：无 / 静态
- **构建命令**：`npm ci && npm run build`
- **根目录**：仓库根（与 `package.json` 同级）
- **构建输出目录**：`/`（站点根，含 `index.html` 与构建出的 `book/`）
- **环境**：Node **20**（与 `.nvmrc` 一致；控制台可选「环境变量」或绑定 `.nvmrc`）

构建机会执行 `npm run build`，无 sibling 仓库时脚本会 **git clone** `zhenyi`，再生成 `book/`。

### B. GitHub Actions → Cloudflare Pages

仓库已含 [`.github/workflows/deploy-cloudflare-pages.yml`](.github/workflows/deploy-cloudflare-pages.yml)：推送 **`main`** 时检出 **zhenyi** 与本站，用 **`BOOK_SRC`** 跑 `npm run build:book`，再用 **cloudflare/pages-action** 上传。

在 GitHub **Settings → Secrets** 添加：

- **`CLOUDFLARE_API_TOKEN`**：Pages 编辑权限（Cloudflare 控制台 → API Token）
- **`CLOUDFLARE_ACCOUNT_ID`**：账户摘要页可见

若仍把同一仓库接到 Cloudflare「自动构建」，请关掉其中一侧的构建，避免重复部署。

## 相关

- [zhenyi-base](https://github.com/aiyang-zh/zhenyi-base) — MIT 基础库
- [zhenyi](https://github.com/aiyang-zh/zhenyi) — AGPL 主项目
