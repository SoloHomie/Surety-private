import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

//=============================================================================
// 时间线列表 — 单侧线性活动流
//
// 用法:
//   TimelineList {
//       model: myListModel       // 外部模型 (ListModel / C++ QAbstractListModel)
//       Layout.fillWidth: true
//       Layout.fillHeight: true
//   }
//
// 模型角色 (ListModel 示例):
//   ListElement {
//       color:    "#238636"          // 节点颜色
//       title:    "审核通过"          // 标题
//       time:     "2 hours ago"      // 时间
//       message:  "..."              // 展开详情
//       expanded: false              // 是否展开
//   }
//=============================================================================
ListView {
    id: timelineView
    clip: true
    spacing: 0
    cacheBuffer: 600

    // 布局占位 — 由外部 RowLayout 分配空间
    Layout.fillHeight: true
    Layout.fillWidth:  true
    Layout.preferredWidth: 7
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    // ---- 默认示例模型 (外部 setting model 即可覆盖) --------------
    model: ListModel {
        ListElement { color: "#238636"; title: "项目构建成功";          time: "2 hours ago";  message: "SuretyForge 主线分支构建完成，所有测试通过 (128/128)。产物已上传至制品库。";                                                expanded: true }
        ListElement { color: "#1f6feb"; title: "新增用户认证模块";      time: "4 hours ago";  message: "实现了基于 JWT 的 Token 认证流程，支持自动刷新与多设备会话管理。新增登录/注册/找回密码页面。";                        expanded: true }
        ListElement { color: "#da3633"; title: "修复内存泄漏问题";      time: "6 hours ago";  message: "渲染循环中存在悬空指针，在纹理销毁后未及时释放资源。已添加 RAII 守卫类统一管理 GPU 资源生命周期。";                       expanded: false }
        ListElement { color: "#8957e5"; title: "更新 API 接口版本";     time: "8 hours ago";  message: "将 REST 端点迁移至 v3 版本，更新错误处理中间件以支持新版错误码格式。兼容 v2 客户端过渡期 30 天。";                       expanded: false }
        ListElement { color: "#238636"; title: "重构 UI 布局引擎";      time: "10 hours ago"; message: "使用自定义 Flow 布局替换 GridLayout，列表滚动性能提升 40%，内存占用降低 25%。";                                           expanded: false }
        ListElement { color: "#1f6feb"; title: "补充单元测试覆盖";      time: "12 hours ago"; message: "核心模块代码覆盖率达到 85%。为网络层添加 Mock Server，支持离线集成测试。新增边界条件与异常路径测试用例 47 个。";                   expanded: false }
        ListElement { color: "#da3633"; title: "合并 Feature 分支";     time: "14 hours ago"; message: "feature/agent-lab 分支已合并至 main。解决 3 处冲突，涉及配置加载模块与登录流程的接口变更。";                                expanded: false }
        ListElement { color: "#8957e5"; title: "升级依赖库版本";        time: "16 hours ago"; message: "Qt 升级至 6.8.2，OpenSSL 升级至 3.4.1，修复了 2 个安全漏洞 (CVE-2025-1234, CVE-2025-5678)。";                                expanded: false }
        ListElement { color: "#da3633"; title: "紧急修复启动崩溃";      time: "18 hours ago"; message: "配置文件路径为空时导致空指针崩溃。已添加路径校验逻辑与默认配置回退机制。已通过热修复通道推送至生产环境。";                             expanded: false }
        ListElement { color: "#238636"; title: "发布 v1.2.0 版本";       time: "20 hours ago"; message: "生产环境部署完成。Docker 镜像已构建并推送至容器仓库。包含 12 项新功能与 23 项问题修复。";                                      expanded: false }
        ListElement { color: "#1f6feb"; title: "代码审查反馈处理";      time: "22 hours ago"; message: "根据 PR #43 审查意见完成修改：简化条件逻辑嵌套、补充关键路径注释、提取重复工具函数至公共模块。";                                  expanded: false }
        ListElement { color: "#8957e5"; title: "优化数据库查询性能";    time: "1 day ago";     message: "为高频查询添加复合索引，订单列表查询耗时从 2.3s 降至 45ms。优化连接池配置以支持峰值并发。";                                      expanded: false }
    }

    // ---- 委托 ----------------------------------------------------
    delegate: ActiveItem {
        id: itemDelegate
        width: timelineView.width
        itemWidth: timelineView.width
        showUpperLine: index !== 0
        showLowerLine: index !== timelineView.count - 1
        color: modelData.color !== undefined ? modelData.color : (model ? model.color : "#8b949e")
        title: modelData.title !== undefined ? modelData.title : (model ? model.title : "")
        time: modelData.time !== undefined ? modelData.time : (model ? model.time : "")
        message: modelData.message !== undefined ? modelData.message : (model ? model.message : "")
        expanded: index === 0 ? true : itemDelegate._localExpanded
        onToggleExpanded: { _localExpanded = !_localExpanded }

        property bool _localExpanded: false
    }

    // ---- 滚动条 --------------------------------------------------
    ScrollBar.vertical: SuretyScrollBar { }

    // ---- 移除动画 ------------------------------------------------
    remove: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; to: 0; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { property: "y";       to: -20; duration: 220; easing.type: Easing.InCubic }
        }
    }

    // ---- 剩余项平滑位移 ------------------------------------------
    displaced: Transition {
        NumberAnimation { property: "y"; duration: 250; easing.type: Easing.OutCubic }
    }
}
