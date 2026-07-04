<div align="center">
  <img src="https://raw.githubusercontent.com/SoloHomie/Surety/main/qml/images/surety-icon.svg" width="96" height="96" alt="Surety" />
  <h1>Surety</h1>
  <p><strong>下一代数字资产管理与交易平台</strong></p>

  [![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)]()
  [![Platform](https://img.shields.io/badge/platform-Windows%2010%2B-0078D6?style=flat-square)]()
  [![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
</div>

---

## ✨ 功能特性

<table>
  <tr>
    <td width="50%">
      <h4>🔐 OAuth 第三方登录</h4>
      <p>支持 GitHub / Discord OAuth 2.0 一键登录，本地 TCP 回调服务器安全可靠，无需额外注册。</p>
    </td>
    <td width="50%">
      <h4>📦 资产管理</h4>
      <p>创建、编辑、删除数字资产，支持分类标签、版本管理、自定义属性 JSON。</p>
    </td>
  </tr>
  <tr>
    <td>
      <h4>🏪 市场浏览</h4>
      <p>全文搜索、热榜排行、类型过滤、分页浏览。上架/下架一键操作，实时同步。</p>
    </td>
    <td>
      <h4>💳 订阅与定价</h4>
      <p>一次性买断 + 按天订阅双模型，Surety 虚拟货币结算，交易记录可追溯。</p>
    </td>
  </tr>
  <tr>
    <td>
      <h4>🎁 新人福利</h4>
      <p>注册即领 200 Surety，福利系统可扩展，运营活动灵活配置。</p>
    </td>
    <td>
      <h4>🔄 自动更新</h4>
      <p>启动时静默检查版本，一键下载安装。强制更新保障安全修复及时触达。</p>
    </td>
  </tr>
  <tr>
    <td>
      <h4>🌗 深色主题</h4>
      <p>精心打磨的暗色 UI，匹配 Windows 11 设计语言，长时间使用不疲劳。</p>
    </td>
    <td>
      <h4>⚡ 本地加密</h4>
      <p>Windows DPAPI 硬件绑定加密，Token 与资产文件即使被拷贝也无法解密。</p>
    </td>
  </tr>
</table>

---

## 🚀 快速开始

| 方式 | 链接 |
|------|------|
| **服务器下载**（国内推荐） | [api.solohomie.top/api/download](https://api.solohomie.top/api/download) |
| **GitHub Release** | [Releases](https://github.com/SoloHomie/Surety/releases) |

- 支持 Windows 10 1809+ / Windows 11
- 首次启动自动创建数据目录，无需管理员权限

---

## 🛠 技术栈

| 层 | 技术 |
|------|------|
| 客户端 | Qt 6 / QML / C++20 / OpenSSL |
| 服务端 | C++20 / MySQL / Redis / libcurl |
| 安全 | PBKDF2-SHA256 (60 万轮) / DPAPI / TLS 1.3 |
| 部署 | Caddy / Systemd / Inno Setup |

---

## 📦 安装

下载安装包运行，或使用包管理器（即将支持）：

```powershell
winget install SoloHomie.Surety  # 即将上线
```

---

<div align="center">
  <sub>Built with ❤️ by Homie</sub>
</div>
