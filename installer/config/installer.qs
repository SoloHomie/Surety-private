// Surety Installer Control Script
// 自动创建桌面快捷方式、注册卸载信息

function Component() {}

Component.prototype.createOperations = function() {
    component.createOperations();

    if (systemInfo.productType === "windows") {
        // 桌面快捷方式
        component.addOperation("CreateShortcut",
            "@TargetDir@/Surety.exe",
            "@DesktopDir@/Surety.lnk",
            "workingDirectory=@TargetDir@");

        // 开始菜单
        component.addOperation("CreateShortcut",
            "@TargetDir@/Surety.exe",
            "@StartMenuDir@/Surety.lnk",
            "workingDirectory=@TargetDir@");
    }
}
