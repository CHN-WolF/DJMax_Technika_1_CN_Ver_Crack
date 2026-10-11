# DJMax Technika 1 中国版 · 破解总结

> 目标:`client.exe`(2010-12-31 构建,8,982,528 字节),保护 = Themida/WinLicense 2.x(2010 年末)+ GrandDog 加密狗。
> 与国际版的关系:两版数据格式完全一致(TPK/PTFF/资源布局均同),国际版破解档案在国际版目录
> `crack_work/README.md`。所有工具与源码在 `crack_work/` 下,文件清单见第 9 章。

## 0. 总览

| 目标 | 状态 | 一句话 |
|---|---|---|
| **插狗**(官方 SDK + 真狗) | ✅ 完成 | 第一层补丁照常 + 本地层纯转发官方件 + 官方 SDK 走真狗会话,最稳(§3) |
| **免狗**(GrandDog 三层验证) | ✅ 完成 | 第一层 4 个运行时补丁 + 本地层转发 + API 层回放,拔狗完整运行(§4) |
| **破壳**(Themida 脱壳) | ✅ 完成 | OEP 快照重建的 client_unpacked.exe 可启动游玩(§5) |
| **解包**(TPK/PTFF/资源) | ✅ 完成 | TPK 全解(AES+LZO)、PTFF 谱面全解(MT19937+XTEA 变体)、谱面识别到歌曲+难度(§6) |

**能玩的方式:**
1. **插狗**:`run_free.bat`(根目录为官方原版 RCGrandDogW32.dll + 插真狗,见 §1A)。
2. **免狗(推荐)**:`run_free.bat`(根目录换成回放件 RCGrandDogW32.dll,拔狗即玩,见 §1B)。
3. **脱壳版**:`run_free.bat -u`(= `run_unpacked.exe <服务器>`,研究/二开用,见 §1C)。
4. **分发包**:根目录 `DJMax Technika 1 China Version Crack.zip`(免狗+脱壳+modewatch 全套),
   覆盖到任意机器的游戏目录即可玩,**不需要目标机装过 GrandDog 驱动**。

中国版第一层补丁后狗不参与校验,插不插都能跑。两条线路各一个自含包
(运行文件+源码都收在包内,与现役线路区分开):
- `crack_work/插狗+免狗运行补丁/`:回放件 RCGrandDogW32.dll + RC_GrandLocal.dll,
  插不插狗都能玩;
- `crack_work/插狗运行补丁/`:官方原版 RCGrandDogW32.dll + RC_GrandLocal.dll,
  必须插真狗。本地层会按盘上的 SDK 自动适配(见 §4.2)。

## 1. 怎么玩

## 1A. 插狗运行(操作手册)——官方 SDK + 真狗,最稳

### 1A.1 一句话现状
**插着真狗,双击 `run_free.bat`,原版 client.exe 游玩。**第一层硬件直查被 4 个运行时补丁
跳过(§4.1),本地层把狗会话纯转发给官方实现,API 层由官方 RCGrandDogW32.dll 走真狗会话
(§3)——整条链路与原生只差"补丁+转发"。

### 1A.2 前提与安装
1. 已装 GrandDog 官方驱动(设备管理器能看到 GrandDog USB Device,USB ID VID_08E2&PID_0006)。
2. 插入真加密狗。
3. `crack_work/插狗运行补丁/` 保持目录结构覆盖到游戏根目录(或手动:根目录放官方原版
   `RCGrandDogW32.dll` + 构建产物 `crack_work/tools/RC_GrandLocal.dll`)。

### 1A.3 启动与预期
与免狗共用同一个 `run_free.bat`(bat 不关心狗,盘上哪套 SDK 决定路线):
```
run_free.bat                → client.exe IP:端口(bat 内置默认私服)
run_free.bat <IP:端口>      → 指定服务器
```
- 中国版第一层是固定地址补丁,无 VM 抽签,启动是确定性的,秒进。
- 任务更新:连上活私服几秒完成;离线(127.0.0.1)干等约 3 分钟(见 §1E)。
- 自检:根目录 `dogpatch_local.log` 出现 "ordinals 32/32" 纯转发即正常。

### 1A.4 与免狗的互换
根目录 `RCGrandDogW32.dll` 换成回放件(`crack_work/tools/` 构建产物,或"插狗+免狗运行补丁"
包内那份)→ 免狗模式;换回官方原版 → 插狗模式。本地层按盘上 SDK 自动适配(§4.2),
`RC_GrandLocal.dll` 与 `modewatch.exe` 两条路线通用,不用动。

### 1A.5 故障对照
见 §1F(共用)。

---

## 1B. 免狗运行(操作手册)——**不插狗,推荐**

### 1B.1 一句话现状
**不插狗,双击 `run_free.bat`,原版 client.exe 直接游玩。**第一层硬件直查被 3 个运行时补丁
跳过(§4.1),本地层由 RC_GrandLocal.dll 转发官方件(§4.2),API 层由 RCGrandDogW32.dll 回放
(§4.2)——三层全过,实测完整进局游玩。

### 1B.2 安装
分发包 zip 覆盖到游戏目录即可;手动等价物 = 根目录放 `RCGrandDogW32.dll` + `RC_GrandLocal.dll`
(= `crack_work/tools/RCGrandDogW32.dll` 与 `crack_work/tools/RC_GrandLocal.dll` 的部署副本,
两者都是 build_all.sh 的输出,文件名即部署名)。
注意:根目录当前部署的是**官方原版 RCGrandDogW32.dll**(插真狗模式);免狗玩 = 把回放件
拷到根目录覆盖,本地层会按盘上 SDK 自动适配(§4.2),换回官方件即恢复插狗模式。

### 1B.3 启动与预期
```
run_free.bat                → client.exe IP:端口(bat 内置默认私服)
run_free.bat <IP:端口>      → 指定服务器
```
- 中国版第一层是固定地址补丁,**无 VM 抽签**,启动是确定性的,秒进。
- 任务更新:连上活私服几秒完成;离线(127.0.0.1)干等约 3 分钟(见 §1E)。

### 1B.4 故障对照
见 §1F(共用)。

---

## 1C. 脱壳版(client_unpacked.exe)——研究/二开用

### 1C.1 一句话现状
**`run_free.bat -u`,脱壳版完整进游戏。** 也可直接 `run_unpacked.exe <服务器>`。

### 1C.2 依赖文件
根目录:`client_unpacked.exe`(本体)+ `run_unpacked.exe`(启动器:CREATE_SUSPENDED 拉起 +
远程线程注入)+ `selfredir.dll`(壳自读重定向)+ **原版 `client.exe` 必须保留**(壳校验要读它)
+ 免狗双 DLL 照常(VA 布局一致,补丁与钩子照常生效)。
运行时不依赖 crack_work/(它只是源码与档案)。

### 1C.3 原理一句话
脱壳版启动后壳会全量自读 exe 文件校验 → 读到的是重建字节 ≠ 原版 → 报错 10;
selfredir.dll 钩 ntdll!NtCreateFile 把"读自己"重定向到原版 client.exe → 校验通过。详见 §5.2。

---

## 1D. debugInfo.ini 参数与显示行为

键有效性实测(A/B 对照,全部实锤):

| 键 | 节 | 生效? | 备注 |
|---|---|---|---|
| keyboard_test | debug_info | ✓ | 无触屏机器靠它玩 |
| enable_log | debug_info | ✓ | false 时 flush 目录零日志 |
| auto_test | debug_info | ✓ | true 时自动投币进局循环 |
| use_watcher | debug_info | ✗ | true 也不启动 Watcher1/2.exe |
| enable_pack | debug_info | ✓ | false 时启动后干净退出 |
| fullscreen / show_cursor | setting | ✗ 原生 | 由 RC_GrandLocal.dll 代为执行;fullscreen=true = 托管无边框全屏(见 §7.5) |
| fixed_frame | setting | ✗ 原生 | 由 RC_GrandLocal.dll 代为执行(Present 限流 60fps) |
| popup_style / dev_mode / vsync | setting | ✗ | 翻转后日志/流程逐字节一致 |
| screen_width/height | setting | ✗ | 恒 1280x768 |
| using_console_window / using_network / resource_preload | setting | ✗ | 硬编码 |
| sfx_volume / bgm_volume | setting | ✗ | 软件混音,全程不调 SetVolume |
| multipleSample / fullscene_glow / light_* | graphics | ✗ | 渲染路径硬编码 |

规律:[debug_info] 节大体有效(use_watcher 除外);[setting]/[graphics] 里涉及显示/网络的键全是死的。

**fullscreen=true 可直接开(RC_GrandLocal.dll 接管)**:
- 驱动支持 1280x768x32:启动早期(D3D 初始化前)把桌面切到 1280x768,**刷新率沿用当前值**
  (高刷屏不掉 60Hz 黑屏重同步;实测 1080p@240 → 768p@240),无边框窗口正好铺满;
  退出/崩溃后由 `crack_work/tools/modewatch.exe` 看门狗还原原分辨率+刷新率。
- 驱动不支持:桌面不动,无边框 1280x768 窗口居中(黑边,1:1 输入精准;不做拉伸,
  避免触摸/鼠标坐标错位)。
- 设备全程窗口化,独占全屏特有的 GetBackBuffer 空指针崩溃(游戏自身毛病,国际版同址同崩)
  整体消失;游戏的 ChangeDisplaySettings* 两种模式下都被 noop。
- 技术内情见 §7.5。调试开关:游戏根目录放 `ifh_no768.on` 空文件 = 假装显示器没有
  1280x768 模式(在有模式的机器上验证回退路径用)。

## 1E. 启动与服务器语义

服务器参数语义:`client.exe <IP:端口>` = 用指定服务器;**不带参数 = 用游戏内置服务器地址**
(官方,已死)。**跳过任务更新等待的唯一办法 = 连上一个活着的服务器**(实测连私服启动后
几秒收完任务列表进标题,还顺带下载真实任务数据);离线模式(127.0.0.1:4723)需等约 3 分钟
重试结束才继续。

## 1F. 故障对照(共用)

- "No Correct Hardware Dog Found" 弹窗 = 免狗双 DLL 没就位/序号表错位(对照 §1B.2)。
- **启动即弹 "Microsoft Visual C++ Runtime Library / This application has requested the
  Runtime to terminate it in an unusual way" = 多网卡 bug**,已由 RC_GrandLocal.dll 修复(§7.1);
  还出现说明 RC_GrandLocal.dll 不是含该修复的版本。
- 脱壳版弹 "Error loading program" = 壳自读校验失败:selfredir.dll 没注入,或原版
  client.exe 不在位(§5.2)。
- 游戏窗口出来但鼠标看不见/速度不对 = debugInfo.ini 被改,对照 §1D。
- 全屏后桌面没还原 = modewatch.exe 没就位(须在 crack_work\tools\ 下)。

## 2. 保护体系全图

`client.exe` = Themida/WinLicense 2.x(2010 年末,高档选项)+ GrandDog 加密狗。
官方启动链 `launcher.exe → Watcher1/2.exe → client.exe`;直跑 client.exe 只过游戏本体关卡。

**狗的三层验证,缺一不可:**

| # | 关卡 | 本体 | 破解 |
|---|---|---|---|
| ① | **第一层硬件直查** | 原生变异码,加载任何狗 DLL 之前直查 GrandDog USB,无狗 silent exit | 运行时 3 补丁(0xFD7FC63/0xFD8011D/0xFD80191,该区段 RWX 加载时已解密可写)+ 第 4 补丁(0xFD7FB90 周期复查线程即返,见 §7.2) |
| ② | **第二层本地层 RC_GrandLocal.dll** | 狗会话协议厂商实现(DIOC 会话、种子应答等),纯软件加解密 | 直接转发官方件(拔插对照实验逐字节一致 → 与实体狗无关,密钥自含官方 DLL) |
| ③ | **第三层 API 层 RCGrandDogW32.dll** | rc_* 6 个调用,关键在缓冲区应答 | 回放件复刻返回值+缓冲区(§4.1 表) |

- 壳自身另有**运行期自读 exe 校验**(脱壳版对策见 §5.2)与**反调试探针**(调试器秒退
  exit 0x4000001f;Themida 直接 syscall 绕过导出断点,观察要在干净环境)。
- launcher.exe/Watcher1/2 的机器绑定/Sentinel 检查与直跑 client.exe 无关,不处理。

## 3. 插狗 ✅(官方 SDK + 真狗)

最稳路线:不伪造任何数据,狗会话全部走官方件。
- **第一层**:本地层照常打 4 个运行时补丁(§4.1),硬件直查即返——这层本来就不需要狗参与;
- **第二层**:`RC_GrandLocal.dll` 检出盘上 `RCGrandDogW32.dll` 为官方原版(不含回放件
  标记串)→ 32 个序号**纯转发零拦截**,转发给嵌入资源释放出的官方本地层实现(§4.2);
- **第三层**:官方 `RCGrandDogW32.dll` 与真狗正常会话(需官方驱动,设备管理器可见
  GrandDog USB Device,USB ID VID_08E2&PID_0006)。

判别为什么只能按"盘上文件是否含标记串":文件大小不可靠(回放件比官方件还大),
已加载模块不可行(第二层先于第三层加载,彼时还看不到)。详见 §4.2。
交付包 = `crack_work/插狗运行补丁/`(用法 §1A)。

## 4. 免狗 ✅

### 4.1 原理:三层验证的细节

**第一层:硬件直查(加载任何狗 DLL 之前)**
游戏在加载狗 DLL 之前就有一段直接查硬件的代码,不插狗就 silent exit。必须运行时补丁
client.exe 三处(该区段是 RWX,加载时已解密,可写):

| 地址 | 补丁字节 | 作用 |
|---|---|---|
| `0xFD7FC63` | `e9 a3 00 00 00 90` | jmp +0xA3 跳过硬件直查块 |
| `0xFD8011D` | 6×`90` | NOP 掉一个 6 字节间接调用 |
| `0xFD80191` | 2×`90` | NOP 掉条件跳转 |

**第二层:本地层 `RC_GrandLocal.dll`(纯软件,与实体狗无关)**
游戏按**序号(ordinal)**调用其导出 ord5/ord23/ord21/ord28:
- ord5 = 种子应答(游戏发 32 字节随机种子,回 16 字节)
- ord23 = 16 字节自描述槽
- ord21/28 = 混淆的校验/应答

拔插对照实验逐字节一致 → 这是纯软件加解密,密钥自含在官方 DLL 里。**对策:直接转发给
官方 DLL,不需要模拟。**

**第三层:API 层 `RCGrandDogW32.dll`(需要回放)**
真狗的全部交互只有 6 个调用,关键在**缓冲区应答**而不只是返回值:

| 调用 | 返回值 | 必须复刻的缓冲区写入 |
|---|---|---|
| rc_OpenDog(1, "GrandDog", a3) | 0 | `*(DWORD*)a3 = 0x11`(游戏据此拼句柄 0x11000000) |
| rc_VerifyPassword(h, 1, "dlstodgksqkd", a4) | 0 | `*(BYTE*)a4 = 0xFF`(缺了就是 "No Correct Hardware Dog Found") |
| rc_GetDogInfo(h, a2, a3) | 0 | a2 写 a3[0] 个字节(0x0D):`aa3e0000 db1a0200 01554752 41` |
| rc_GetProductCurrentNo(h, a2) | 0 | **不碰缓冲区**(乱写会破坏游戏栈数据) |
| rc_CheckDog / rc_CloseDog | 0 | 无 |

### 4.2 最终方案(根目录 2 个 DLL)

1. **`RCGrandDogW32.dll`** = `crack_work/tools/RCGrandDogW32.dll(构建输出即部署名)`
   API 层回放,按上表复刻返回值+缓冲区。源码 `tools/sources/rcreplay.c`,导出序号表
   `tools/sources/rclogger.def`;统一构建 `tools/build_all.sh`(w64devkit gcc -m32)。
2. **`RC_GrandLocal.dll`** = `crack_work/tools/RC_GrandLocal.dll(构建输出即部署名)`(含全部稳定性修复,
   见第 7 章)
   - 官方 `RC_GrandLocal.dll` **作为资源嵌入**(176KB,RT_RCDATA),运行时释放到 %TEMP% 加载;
     加载回退链:系统 SysWOW64 → 游戏目录 RC_GrandLocalReal.dll → 释放内嵌资源。
   - 32 个序号导出全部裸 jmp 转发(convention 透明,见 `tools/sources/rclocal_replay.asm` 的 THUNK 宏)。
   - DllMain 及每次导出调用时,向 client.exe 应用 3.1 节的 3 个运行时补丁 + 第 4 个补丁(见 §7.2)。
   - 源码 `tools/sources/rclocal_diag.c`(回放功能来自 `rclocal_replay.c`),asm 跳板
     `tools/sources/thunks_gas.S`,嵌资源官方件 `tools/sources/RC_GrandLocal_official.dll`;
     统一构建 `tools/build_all.sh`(w64devkit,-m32)。
   - 重建已验证:两个补丁包的 `源码/` 子目录自含可重建(`源码/build_all.sh` +
     `源码/sources/`;工具链按 $W64DEVKIT → ./toolchain → 上溯 crack_work/tools/toolchain
     → PATH 顺序查找)。同一输出路径下重建逐字节一致;跨目录 DLL 哈希会变——
     MinGW 自动镜像基址按输出路径取哈希,只动若干绝对地址字节,不影响运行
     (exe 基址固定,modewatch.exe 跨目录也逐字节一致)。回放件源码的 MSVC SEH
     已改为 VirtualQuery 检查,cl/gcc 通吃(原 MSVC 版 bat 已删——它引的是
     固定机器上的 BuildTools 路径)。
   - **按盘上 RCGrandDogW32.dll 自适应**——检出回放件(含 `dogpatch_api.log` 标记串)
     时 ord5 钉死应答+ord28 强置 0(回放路线需要);检出官方原版 SDK 时**序号纯转发零拦截**
     (官方 SDK 会用 ord5 应答推会话密钥,钉死会密钥错位 → 游戏 ExitProcess;此时第一层
     补丁与全部体验修复照常,狗会话完全走官方件)。判别不能靠文件大小(中国版回放件比
     官方还大),也不能靠已加载模块(第二层先于第三层加载,看不到)。

### 4.3 复现:从零抓真狗数据(方法论)

有真狗时按此流程抓取应答数据(现成 DLL 里已含数据,无狗可跳过):

1. **API 层**:`tools/sources/rclogger.c` + `tools/sources/rclogger.def` 编译出 `RCGrandDogW32_logger.dll`。
   改名 `RCGrandDogW32.dll` 放根目录,被记录的原版改名 `RCGrandDogW32Real.dll`,插真狗跑一次,
   根目录 `rclog.txt` 得到真狗全部调用(512B 缓冲区前后对比)。成品存档
   `analysis/rclog_realdog_full.txt`。
2. **本地层**:`tools/sources/rclocal_logger.c` + `rclocal_thunks.asm`(裸 thunk 劫持返回地址,
   calling-convention 无关,前后 256B 转储),确认本地层与狗无关。
3. **链式调试台**(源码 `tools/sources/dogtest_wpmwatch.c`、`dogtest_imgsnap.c`、`localtest.c`,
   编译后按 t1 全链 / t2 基线 / t3 代理链 / t4 回放 搭建测试目录)逐段定位失败点。
4. 把抓到的应答填进 `tools/sources/rcreplay.c`,跑 `tools/build_all.sh` 重新构建回放 DLL。

### 4.4 踩坑(别再踩)

- **导出序号表必须与原 DLL 逐序号一致**(`rclogger.def` 照原版抄)。序号错位 → 游戏按序号
  取到错误函数 → 启动 2 秒即退。
- 中文注释的源文件必须存 **GBK** 再编译(cl 在 936 代码页下编 UTF-8 中文会炸)。
- vcvars 坏时:直设 INCLUDE/LIB 调 BuildTools 的 cl;ml 与 cl 的 .obj 同名会互相覆盖,用 -Fo 区分。
- 返回值对了不够,**缓冲区内容才是验证主体**(rc_VerifyPassword 的 0xFF 标志)。

## 5. 破壳 ✅(脱壳版完整进游戏)

### 5.1 保护布局(实测事实)

| 项 | 值 |
|---|---|
| 壳 | Themida/WinLicense 2.x(2010 年末),高档选项 |
| **OEP** | **VA 0xFA59700**(MSVC2005 CRT 启动;PE 头 EP 字段本来就是 0xf659700) |
| 入口机制 | **TLS 回调**先跑壳 stub,加载器调到 EP 时已是明文 |
| 原始 .text | RVA 0x1000,2.7MB,**永不解密的诱饵区** |
| 真代码 | 区段 0000007,VA 0xFA50000,5MB RWX(壳自建) |
| 导入 | 游戏 API 调用全走 Themida **虚拟化 wrapper**;壳自用 mini-IAT 在 VA 0xFA50000(6 槽,见 §8) |
| 巨型区段 | 0000003 虚拟 254MB,实际只有前 0x41000 非零(全镜像布局 258MB) |
| 错误串表 | VA 0xFA4C4FA 起,每条约 102 字节;"Error loading program" 在 0xFA4C8F6 |

实测依据:OEP 时 WL 段 97% 的 4K 块反汇编干净,与运行几分钟后快照 85% 一致——
**代码在 OEP 时已基本全明文且稳定**,旧结论"动态加密、静态 dump 必不能跑"不成立
(90% 块变动是 stub 阶段的观测,被误当成运行态)。所以 OEP 时刻全镜像 dump + 修 PE 可行。

### 5.2 最终方案(全部在根目录)

```
run_unpacked.exe        启动器:CREATE_SUSPENDED 拉起重建版 + 远程线程注入 selfredir.dll + 恢复主线程
selfredir.dll           自读重定向:钩 ntdll!NtCreateFile,文件名尾匹配到重建版自身 → 改打开原版 client.exe
client_unpacked.exe     OEP 重建版本体
+ 根目录保留原版 client.exe(壳要读它过校验)
+ 免狗双 DLL 照常(VA 布局一致,补丁与钩子照常生效)
```

**原理(破案链,全部实测)**:
1. 重建版启动 1.5 秒后弹壳的错误框 "Error loading program"(错误码 10)。错误码是全局变量驱动:
   报告器(0xFA5D3F5 一带)逻辑 = `ecx=[错误码全局]; 若 0 则置 1; esi = 串表 0xFA4C4FA + 码*102`。
2. 注入式三调试寄存器监视(unphook_dr3)+ 活块转储(unphook_livedump)抓到:写错误码的上游是一个
   **VM 解释器**(0xfb15f70),从流游标 `[0xfb0ffa4]` 读 8 字节记录(cmd16/param16/payload32)
   巨型 switch 分发。失败记录 = `cmd=0x2c47 payload=10`(装常量 10)→ `cmd=0x3adf payload=0xFB115AC`
   (写错误码全局)→ 报告器。
3. 解释器读的"运行时状态"大头是**壳自己 exe 的文件内容**:stub 期就用**直接 syscall
   NtCreateFile** 打开自身(kernel32 钩子看不见;外部注入 50ms 也太迟),之后约 4211 次 1KB
   块全文读取。重建版读到的是解密后的重建字节 ≠ 原版 → 校验失败 → 错误 10。
4. 对策:**自读重定向**。钩 ntdll!NtCreateFile(syscall stub 序言 B8 可安全补丁),文件名尾
   匹配到重建版自身 exe 名 → 换成打开**原版 client.exe** 返回。壳读到原版内容 → 校验通过 →
   完整进入游戏。

### 5.3 复现步骤(照做)

**第 1 步:拿 OEP 时刻的一致性快照(二选一)**

- A. 进程内快照器(推荐,不受调试器反调试影响):
  `inject.exe` 用 INJECT_SUSPENDED 模式在游戏主线程跑起来之前注入 `tools/oepdump.dll`。
  它原位补丁 ntdll 里 RtlUserThreadStart 后继路径上的**线程过程启动器**
  (`mov edx,edi / xor ecx,ecx / call esi`,RVA 0x682a8;备选 `call edi` 路 RVA 0xa4876):
  主线程调 EP 时 edi=EP,detour 匹配 0xFA59700 即在**游戏代码一条指令都没执行**的时刻
  冻结 + dump。产物 = `crack_work/oepdump_out/`(index.txt + 22 个堆区,现存;平坦镜像另由
  dump_full.py 产出,在 `analysis/img_oep.bin` 等)。
- B. 调试器 dump(需要 Python 环境且当前环境能过 stub):
  `python crack_work/research/dump_full.py`(minidbg 系:CreateProcess DEBUG_ONLY_THIS_PROCESS,
  补丁 PEB+2 / PEB+0x68 / 堆标志,系统断点时给 0xFA59700 下 0xCC)。
  产物 = `analysis/img_lo_oep.bin`(VA 0x401000–0x75D000)+ `img_hi_oep.bin`(VA 0xF9E2000–0xFF17000)
  + `analysis/modules_oep.json`。
  注意:枚举 WOW64 进程的 32 位模块必须用 Toolhelp32 + TH32CS_SNAPMODULE32;
  psapi EnumProcessModules(Ex) 只能看到 64 位侧。

**第 2 步:重建 PE**

`tools/build_unp.exe`(C 版,源码 `tools/sources/build_unp.c`;Python 版 `research/rebuild.py` 等价):
- 各区段 raw 内容 ← OEP 运行时内容(**原 raw 偏移不变,不重排文件**);
- EP 保持 0xf659700;清 TLS/reloc/debug 目录,置 RELOCS_STRIPPED;
- 在导入目录 RVA 0xf65004c 处自建明文导入表(3 个 DLL、6 个 API,FirstThunk 指到原槽位,
  装载时由 loader 重新解析):ADVAPI32!RegOpenKeyExA@0xf650000;
  KERNEL32!GetSystemDirectoryA/LoadLibraryA/GetModuleHandleA/GetProcAddress@0xf650008-14;
  USER32!MessageBoxA@0xf65001c。(槽位内容按模块基址+磁盘 DLL 导出表从 dump 反查。)
- 产物:重建版 exe,部署为根目录 `client_unpacked.exe`。

**第 3 步:部署运行**

`run_free.bat -u` 或 `run_unpacked.exe <服务器IP:端口>` 即可。启动器源码
`tools/sources/run_unpacked.c`,自读重定向源码 `tools/sources/selfredir.c`(均用 w64devkit -m32 构建)。

### 5.4 失败路线存档(别再试)

| 路线 | 死因(全部实测) |
|---|---|
| Olly + LCF-AT `ultra_unpacker_1.4.txt`(全自动环境备于 `olly110/`) | ①找 IAT 的特征码 `83 F9 00 0F 84` 在 WL 段不存在 → IAT_2 恒 0,SEH 死循环;②REAL_OEP_STOP 模型假设真代码落回 .text,本目标 OEP 在壳段内永不命中;③MJ hook 记录 0 个 API,ARImpRec 阶段到不了。**该脚本适配"经典布局"Themida,不适合代码驻留壳段+导入全虚拟化的目标。** |
| unlicense 0.4.0(`research/unlicense.exe`、`research/x86/`) | 版本签名认不出 2010 年的老 Themida;32 位版强制 v2 后 OEP 探测超时。 |
| 堆表嫁接(`tools/sources/ungraft.c`) | 把健康堆强覆到重建版同 VA → 死得更早。失败点是壳运行时初始化校验(=自读文件校验),不是缺堆表。 |
| 文件内容 CRC 假设 | 壳自读文件是**读取载荷做校验**,用影子重定向喂原版字节后错误 10 照旧(unphook_shadow)——这是中间结论,最终破案=自读重定向(§5.2)。 |
| 静态补丁壳运行时代码 | 报告器/检查代码是"块原地动态加密",文件里 0xFA5D4xx 的明文报告器是**诱饵副本,永不执行**(NOP 文件里的 MessageBoxA 调用点,弹框照旧)。 |
| **把 selfredir.dll 写进重建 exe 导入表(免启动器单独运行)** | 实测失败:加载器只处理前 3 个系统 DLL 描述符,新增的第 4 个描述符(含调到第 1 位)永远不被加载——毁坏第 1 个描述符的 DLL 名会立即 fatal,毁坏 selfredir 的无任何反应;进程内模块枚举确认 selfredir 从未加载。推论:mini-IAT 槽由壳/游戏运行时自解析,该 exe 的导入表对自定义 DLL 形同虚设。run_unpacked.exe 的 CREATE_SUSPENDED 注入是唯一可行路径。 |
| Scylla 式 IAT 全量重建 | 变异 wrapper 每个都不同,需逐条 trace,基本不可行。 |

### 5.5 踩坑(脱壳相关)

- **RVA/VA 别搞混**:0xF650000 是 RVA,VA 要 +0x400000 = 0xFA50000。用 dump 基址换算前先
  确认 dump 的 VA 起点。
- 该 exe **虚拟布局 258MB**(区段 3 VS=254MB),别按文件大小算 dump 范围。
- Themida stub 的 int3 **绝不能 skip eip+1**(那是壳 VEH 的控制流装置,skip 了就乒乓死循环);
  要 DBG_EXCEPTION_NOT_HANDLED 交给壳自己。
- 调试器秒退(exit 0x4000001f)= 反调试检出;Themida 会**直接 syscall** 绕过导出断点,
  观察 dump 运行要在干净环境。
- 变异(mutation)代码里一切"特征码搜索/指针扫描"都是均匀分布的假阳性,线性反汇编 10 行
  后必滑进垃圾。分析只能靠运行时断点,不能靠静态扫。
- 现代文件对话框(Select Script)对一切消息注入免疫,只有真实鼠标双击列表项有效
  (olly110/watcher2 的 UIA 方案)。

## 6. 解包 ✅

### 6.1 TPK 格式(p01/*.tpk、Song/Pattern/*.tpk,共 115 个)——完全破解

```
+0x00  u32 magic = 0x0014CEDE + u16 ver + u16 条目数 + u32 大小
+0x0C  body:AES-128-ECB,16 字节块对齐偏移 12 的网格
       密钥 = ASCII "Shit!DontTouchMe"(没错,这是明文密钥)
解密后 = 条目顺序拼接,每条:
  name[128](零填充 ASCII 路径)+ u32 hash + u32 blobSize + u32 field2 +
  u32 reserved + blob[blobSize]            (条目步进 = 144 + blobSize)
  blob = LZO1X 压缩流(ver 0101 包,p01/*)或直接是文件内容(ver 0100 包,
         Song/Pattern/*;WAV/OGG 等本身已压缩的媒体不二次压缩)
         LZO 实现 = 游戏内 Zipper::CLZOWrapper,解码器移植自 Linux lib/lzo。
```

**工具:`tools/tpkx.exe <file.tpk> [outdir]`** —— 纯离线,无需运行游戏。
最终校验(115 个 tpk → 25719 个文件):WAV 23858、PNG 1036、JPG 114、OGG 111、
VCE 251、XML/INI 273、TGA 6——**全部通过真实解码器打开测试**(System.Drawing
对 PNG/JPG 逐个打开:0 失败);XML/CSV/INI 文本完整(实测 font.xml 与游戏内存
逐字节一致)。条目 hash 字段的算法未解(不影响提取)。

**密钥怎么找到的(方法论,重要的通用路线)**:
1. 黑盒定形:零填充区密文恒等且 ≡12 (mod 16) → 16 字节块 ECB;
   c00 与 c00.dev 前 622K 逐字节相同 → 无 per-file IV。
2. 静态分析撞墙(解密函数在变异代码区)→ 运行时定位:`tools/tpkdump.dll`
   注入(钩 ntdll 层 NtCreateFile/NtReadFile——游戏的文件 IO 全走 Themida
   直 syscall,kernel32 钩子看不见),对密文缓冲上 **PAGE_GUARD**,谁在循环里读
   密文,guard 异常就落在解密函数身上(抓到 EIP=0x5ac208)。
3. 活体 dump 该函数(dumpva.exe)→ 干净的 AES T-table 解密例程(Td0-3 表、
   Nr=10、轮密钥在 `this+0x1f8`)→ 栈回溯 + 上下文 dump → 轮密钥区末尾躺着
   明文 ASCII 密钥 "Shit!DontTouchMe"(旁边还有 "Shit! Don't touch me" 彩蛋串)。
4. 零填充块验证:AES_enc(0¹⁶) == 填充密文块 → 密钥实锤。
注意:游戏内"AES"的 state 字节序是非标准的(FIPS-197 测试向量不过),
tpkx.c 里的实现与游戏逐字节一致,别拿标准 AES 库直接替换。

**提取产物**:`extracted/`(2.9GB,根目录)= tpkx 全量输出(115 个 tpk,按包名分目录,
真实文件名,全部可直接打开)。

### 6.2 PTFF 谱面(p02/,262 个哈希命名文件,magic "PTFF")——完全破解

**工具:`tools/ptffx.exe <file.ptff> <out>`** —— 纯离线,262 个全部解出
(产物在根目录 `extracted_pt/`,262 个 .pt,保留 PTFF 头可直接被编辑器读取)。
解开后的文件 = 谱面资源包:`u32 版本(1 或 0x10001)` + 歌名.wav + 字段区 + 若干
"xxx.wav" 条目(音符敲击音源数据,PCM/自定义二进制)。

**加密算法(全部由反汇编 CScore::Create 还原)**:
1. 头部 24 字节(6 个 dword)同时是密钥来源:v64 = { 24 字节和(lo), CRC32(hi) }。
2. 密钥流 = **MT19937**(`init_by_array`(头部前 6 个 dword)),每次取 2 个
   dword 组成 8 字节块(0x5d2750 每次调用产出 8 字节)。
3. 每个 8 字节块:`plain = cipher ^ fk ^ mtblock`。
4. fk 进化(CBC 式反馈):fk_0 = v64;fk_{j+1} = **XTEA 加密**(fk_j,
   轮密钥 = 本块明文复制两份)。XTEA 是变体:每轮 `sum += delta(0x9e3779b9)`
   一次,v0/v1 共用该 sum(与标准 XTEA 的 sum 位置不同)。
5. 解开后是明文资源:版本字段 + 歌名 + 音源条目。

**定位过程(方法论)**:
- 玩家联机进歌时 p02 文件被读取(NtCreateFile 钩子抓到缓冲 VA)——
  说明铺面是**本地缓存**,不是纯网络下发。
- 对密文缓冲上 PAGE_GUARD → memcpy 读取 → 栈回溯定位到 `CScore::Create`
  (0x5d6590 起,magic 校验 "PTFF" 字符串在 0x6cfcbc)。
- 顺调用链 dump:0x5d2780(加密上下文初始化,ctx+0xbd9e8)→
  0x5d7140/0x5d6ed0(**MT19937 初始化**,乘数 1812433253/1664525/1566083941,
  init_by_array 常数 19650218)→ 0x5d6f80(MT temper,标准常数)→
  0x5d2830(逐字节 XOR 解密循环,原位写回)→ 0x5d26c0 → 0x5d25f0(**XTEA**,
  delta 0x9e3779b9,32 轮)。
- 密钥流成分 = v64 字节 ⊕ MT 块字节;每 8 字节明文被 XTEA(以其自身为密钥)
  更新为下一块的 fk。
- 验证:首块解出 "....tuto" (tutorial),修正 XTEA 变体的 sum 次序后
  全文件明文(tutorial.wav / MR.wav / Kick09.wav / 0-bgm.wav …),262 全绿。
- 注意:hook 低区段代码会被 Themida 块交换**驱逐**(补丁被还原),
  别在交换区下断/打补丁;正确姿势是离线复现算法(ptffx),不要 hook。

**文件识别:数字文件名 → 歌曲 + 难度**

**产物:根目录 `extracted_pt_mapping.csv`(262 行:file,song,title,slot,mode,level,notes,mtime,tag)。**
生成管线:`ptmap.exe`(每文件乐器表/音符流哈希)→ `ptsim.exe`(组内全对音符重叠)
→ `research/map_pt.pl`(总连接)。识别依据链:
1. **歌曲**:pt 乐器表的 wav 名 ⊂ `extracted/<歌名>/` 的 wav 集(覆盖率 ≥0.5 即判归;
   255/262 自动命中,7 个无资源文件:tutorial×2、firstkiss_demo、future_demo、
   3 个已砍歌 lolipop/gee/vox)。
2. **曲表**:`extracted/d02/discstock.csv` = 歌曲数据库(no,内部名,显示名,
   10 个难度槽 level/speed);`ltstage/popstage/tecstage*.csv` 按 (no,槽) 引用,
   统计得槽语义:**槽0=LP、槽1=PP、槽2=TP、槽3=SP**,等级在 discstock。
3. **文件→槽**:p02 数字名是**按歌分块的顺序 id**(连号段=同一首歌;76% 的歌
   文件数恰好等于槽数);段内升序 = 槽升序。多出文件=旧修订版(音符重叠
   0.98~1.0,部分在相隔很远的 id 段,mtime 分两批:初版与在线更新批),在 tag 列标注。
- 注意:同一首歌各槽谱面**共享 90~99% 音符**(BG 音源轨占大头),不能靠音符数判难度;
  槽归属若有争议以运行时为准:游戏联机选歌时 hook 文件读取(chartcap 那套)抓到
  实际加载的 p02 id 即为真值。

### 6.3 .tai(movie/)
Bink 视频(BIKi),直接用 ffmpeg 转码,无需自写工具。

### 6.4 备选路线:运行时内存雕刻(memcarve;已被 tpkx 取代,仅留作手段参考)

1. `debugInfo.ini` 设 `auto_test = true`,跑 `client.exe` 几分钟;
2. `tools/dumpmem.exe <pid>` → `dumpmem_out/`;
3. `tools/memcarve.exe dumpmem_out carved` → 按类型分目录,去重 + carve_log.txt。
tpkx 是首选(离线、全量、原始路径名、内容与游戏内存一致)。

## 7. 兼容性与体验修复(已全部并入 RC_GrandLocal.dll)

### 7.1 多网卡机器启动即崩(CRT terminate)

- 症状:某些机器启动弹 "Microsoft Visual C++ Runtime Library / terminate it in an unusual way"。
- 根因:`std::out_of_range` 从 `std::string::at()` 抛出,死在指纹函数的 MAC 串处理。
  MAC getter(0x5A6E90)malloc 固定 **0x288=648 字节**调 GetAdaptersInfo,而 32 位下一个
  IP_ADAPTER_INFO 条目正好 648:**网卡 ≥2 块的机器必返回 ERROR_BUFFER_OVERFLOW → 空串 →
  at(0) 抛异常 → CRT terminate**。单网卡机器恰好放得下所以能跑。
- 修复:内联钩 `iphlpapi!GetAdaptersInfo`——16KB 静态大缓冲调真实 API,把第一个适配器
  条目(640B)拷回游戏的 648 小缓冲并返回 0。源码 `tools/sources/rclocal_diag.c`(my_GetAdaptersInfo)。
- 临时免改 DLL 的等效规避:禁用除一块外的所有网卡。

### 7.2 开局 1.5-2 分钟后野跳(c0000005)

- 根因:补丁 1(0xFD7FC63 jmp +0xA3)的落点在壳**重变异**后变成指令中间,而壳的周期复查
  线程(入口 0xFD7FB90)在开局后反复执行该变异块 → 野跳。
- 修复:第 4 个运行时补丁——`0xFD7FB90` 覆写 `33 c0 c2 04 00`(xor eax,eax; ret 4),
  周期复查线程一创建即返回。实测 11 局 MainGame / 5 分钟无崩溃(修复前 ~105 秒必崩)。

### 7.3 fullscreen / show_cursor 死键的外挂实现

- debugInfo.ini 的 `fullscreen`/`show_cursor` 有解析代码,但视频路径硬编码独占全屏、
  光标强制隐藏——**这两个键是死的**。
- 在外部实现:钩 `d3d9!Direct3DCreate9` 换掉返回对象 vtable 的 CreateDevice(槽 16),
  fullscreen=false 时强制 Windowed;钩 `user32!ShowCursor/SetCursor` 强制显示光标。
- 坑:包装 vtable 必须保存原 CreateDevice 指针再覆写(否则自递归爆栈);IDirect3D9 共
  25 个槽位,少于 25 的拷贝会踩空。

### 7.4 fixed_frame 死键的真·修复(Present 限流 60fps)

- 病症:240Hz 高刷屏上游戏 4 倍速(逻辑帧计数绑定刷新率)。
- 方案:钩 d3d9,把 Present 限流到 16.67ms(Sleep 粗睡 + QPC 自旋精对齐)。
- 三个坑(全部破案):
  1. **截断虚表拷贝 = 46ms 后必崩 _purecall**:d3d9 设备对象的虚表是堆上完整实现类表,
     内部还会调槽 162 等内部虚函数。**正确做法:原位改真表槽位**(VirtualProtect + 只写 4 字节)。
  2. **双解引用笔误**:`**(DWORD**)obj` 拿到的是 vtable[0] 而不是虚表指针,应为 `*(DWORD*)obj`。
  3. **d3d9 会重填堆虚表(wipe)**:设备创建后第 ~22 帧槽位补丁被抹掉。对策:给 d3d9 .text
     里的 Present/Reset 工作函数本体打 5 字节 jmp 补丁(.text 没人重填)+ watchdog 自愈。
- A/B 实测:fixed_frame=false 轻载 4.17ms/帧(240fps,4 倍速);true 时 ~15.6ms/帧(≈60fps)。
- 附:早期曾给 DirectSound 加虚表包装引发无声(主/从缓冲区是不同实现类,一套虚表配所有
  对象 → 类不匹配),已整体撤除 DS 钩子。教训:COM 虚表包装必须按"每个真实类一份拷贝"。

### 7.5 全屏接管(fullscreen=true)(与国际版 intfhook 同源)

- 旧行为:fullscreen=true = 独占全屏,桌面分辨率不是 1280x768 时必崩/闪退
  (独占模式 GetBackBuffer 失败 → 空指针;国际版同址同崩,游戏自身毛病);
  高刷屏切模式还会掉到 60Hz 黑屏重同步。
- 修复后行为(两种显示器都安全):
  1. **驱动提供 1280x768x32**:首个本地层调用时(早于任何 D3D 初始化)把桌面切到
     1280x768,**刷新率沿用当前值**(实测 1080p@240 → 768p@240),设备强制窗口化 +
     无边框窗口铺满;退出/崩溃后由 `crack_work/tools/modewatch.exe` 看门狗还原
     原分辨率+刷新率(游戏进程全灭 ~4s 后动手;CDS_FULLSCREEN 实测杀进程不自动还原)。
  2. **驱动不提供**:桌面不动,无边框 1280x768 窗口居中(黑边,1:1 输入精准;
     特意不做拉伸,避免触摸/鼠标坐标错位)。
- 游戏自己的 ChangeDisplaySettings* 在两种模式下都被 noop(切模式由 RC_GrandLocal.dll 独家管理)。
- 顺带根治(CreateDevice/Reset 的 hDeviceWindow=NULL):Reset 强制窗口化遇 NULL
  hDevWnd 必返 D3DERR_INVALIDCALL → 游戏即死;RC_GrandLocal.dll 在 pp_force_windowed 里兜底
  填入 CreateDevice 记录的窗口。

## 8. 关键数据速查

```
OEP                = 0xFA59700
WL 段              = VA 0xFA50000  大小 0x4C7000  RWX(RVA 0xf650000)
mini-IAT 槽位      = 0xFA50000..0xFA5001C(6 个)  描述符 0xFA5004C
错误串表           = 0xFA4C4FA 起  "Error loading program" 在 0xFA4C8F6
VM 解释器          = 0xFB15F70  流游标 [0xFB0FFA4]  错误码全局 0xFB115AC
硬件直查 3 补丁    = 0xFD7FC63 / 0xFD8011D / 0xFD80191(见 §4.1)
周期复查线程补丁   = 0xFD7FB90(见 §7.2)
TPK magic          = 0x0014CEDE  密钥 ASCII "Shit!DontTouchMe"  AES-128-ECB + LZO1X
PTFF 算法          = v64(24B 和/CRC32) + MT19937(init_by_array) + XTEA 变体反馈
```

## 9. 目录结构

### 9.1 游戏根目录

| 文件/目录 | 用途 |
|---|---|
| `client.exe` | 原版主程序(Themida + 狗)。**必须保留**:免狗直接跑它;脱壳版的壳自读校验要读它 |
| `RCGrandDogW32.dll` | 狗 SDK:**当前 = 官方原版(插真狗运行)**;免狗玩 = 换成回放件 `crack_work/tools/RCGrandDogW32.dll`(build_all.sh 构建输出即部署名),自动识别(§4.2) |
| `RC_GrandLocal.dll` | ★核心组件(本地层转发+补丁+全部体验修复),= `crack_work/tools/RC_GrandLocal.dll`(build_all.sh 构建输出即部署名) |
| `run_free.bat` | ★启动脚本:免狗原版入口;`-u` = 脱壳版(转发 run_unpacked.exe) |
| `run_unpacked.exe` | ★脱壳版启动器(源码 `crack_work/tools/sources/run_unpacked.c`;由 `run_free.bat -u` 拉起,也可直接跑) |
| `client_unpacked.exe` | ★脱壳本体(OEP 重建版,由 run_unpacked.exe 拉起;也可进 IDA) |
| `selfredir.dll` | ★脱壳组件:NtCreateFile 自读重定向(源码 `crack_work/tools/sources/selfredir.c`;运行时读宿主 exe 名做尾匹配,位置无关) |
| `crack_work/tools/modewatch.exe` | 全屏桌面还原看门狗(fullscreen=true 切模式时由 RC_GrandLocal.dll 自动拉起;游戏进程全灭后还原原分辨率+刷新率;源码 `tools/sources/modewatch.c`) |
| `debugInfo.ini` | 游戏配置(有效键见 §1D;fullscreen/show_cursor/fixed_frame 由 RC_GrandLocal.dll 执行) |
| `RCdiag.ini` | diag 版 RC_GrandLocal.dll 的配置(pcm_dump=false) |
| `checksums.sha256` | 破解相关文件的校验清单(改文件后可对照) |
| `ewfapi.dll` | 分发包组件(EWF API 垫片) |
| `hid.dll` / `multiDLL.dll` | 9-26 替换过的非原版 |
| `binkw32.dll` | Bink 视频解码 |
| `d3dx9_29.dll` / `D3DX9_39.dll` / `D3DX9_40.dll` / `D3dx9d_40.dll` | Direct3D 9 运行库 |
| `CRT_R1.dll` / `msvcm80.dll` / `msvcp80.dll` / `msvcr80.dll` / `Microsoft.VC80.CRT.manifest` | VC2005 CRT 运行库 |
| `client.dat` / `CLIENT_chk` / `launcher.dat` / `xALF.alf` / `zRLF.rlf` | 游戏数据/校验/授权文件 |
| `launcher.exe` / `launcher2.exe` | 官方启动器(免狗流程不用) |
| `Watcher1/2.exe` + `_chk` | 官方看门狗(use_watcher 是死键,不用) |
| `ErrorReport.exe` / `IOemu.exe` | 官方崩溃上报 / IO 板模拟器(配套,不用) |
| `ReadMe.txt` | 官方说明 |
| `ad/` `ae/` `movie/` `p01/` `p02/` `Song/` | 游戏资源(广告、影片、谱面、歌曲) |
| `extracted/` | ★资源提取产物:tpkx 全量输出(115 个 tpk → 2.9GB,按包名分目录,真实文件名) |
| `extracted_pt/` | ★谱面解密产物:ptffx 全量输出(p02/ 262 个 PTFF → 262 个带 PTFF 头的明文 .pt,编辑器可直接打开) |
| `extracted_pt_mapping.csv` | ★谱面识别表:每个 .pt → 歌曲/难度槽(LP/PP/TP/SP)/等级/音符数/日期/标记(见 §6.2) |
| `crack_work/插狗+免狗运行补丁/` | 双模式成品包:回放 RCGrandDogW32.dll + RC_GrandLocal.dll + ini/bat/modewatch + 包内自带源码(`源码/build_all.sh` + `源码/sources/`,自含可重建) |
| `crack_work/插狗运行补丁/` | 纯插狗成品包:官方 RCGrandDogW32.dll + RC_GrandLocal.dll + ini/bat/modewatch + 包内自带源码(`源码/build_all.sh` + `源码/sources/`,自含可重建;不含回放件) |
| `crack_work/` | 全部破解工作档案(见 §9.2) |

### 9.2 crack_work/

| 路径 | 用途 |
|---|---|
| `README.md` | 本文档 |
| `oepdump_out/` | 真 OEP 快照(oepdump 产物:index.txt + 22 个堆区,CWD 相对输出) |
| `analysis/img_lo_oep.bin` / `img_hi_oep.bin` / `img_oep.bin` | OEP 全镜像(dump_full.py 产物,重建输入) |
| `analysis/sec2/6/7.bin` / `sec7_oep.bin` / `text_oep.bin` / `warm_oep.bin` / `sec_warm_oep.bin` / `miniiat_oep.bin` / `func_652a00.bin` | 区段/运行中对照快照 |
| `analysis/modules_oep.json` / `modules_35692.json` | OEP 时 32 位模块清单(注意 Toolhelp32+SNAPMODULE32) |
| `analysis/exports_35692.json` / `rc_exports.json` / `iat_regions.json` / `sec7_apislots.json` | 导出地址↔名称映射(23697 条)/ 狗 DLL 导出 / IAT 区域 / API 槽位 |
| `analysis/rclog_realdog_full.txt` / `rclog2_realdog_full.txt` / `rclog_realdog.txt` | ★真狗全量交互记录(回放数据来源) |
| `analysis/license_files_hash.txt` / `pc1_hashes.txt` | 许可文件/内存块哈希对照 |
| `olly110/` | 路线 A 全自动 Olly 环境(已证不适配,留档):OLLYDBG.EXE + ODBGScript/ScyllaHide/ARImpRec 插件;`run_unpack.ps1` 一键启动;`make_auto.py` 把 `ultra_unpacker_orig.txt` 免交互化为 `ultra_auto.txt`;`watcher2/menurunner/copylog` GUI 自动化三件套;`scriptlog_dump*.txt` 脚本日志存档;`scylla_hide.ini` Themida profile;其余 *.cs/*.ps1 为自动化小工具 |
| `tools/sources/rcreplay.c` + `rclogger.def` → `tools/RCGrandDogW32.dll`(部署名) | ★免狗回放件源码/产物(build_all.sh 统一构建) |
| `tools/sources/rclocal_replay.c/.asm/.def/.rc` | 组件 2 基础版源码(官方 DLL 嵌资源 + 转发 + 3 补丁;留档,build_all.sh 跳过不建) |
| `tools/sources/rclocal_diag.c/.def` + `thunks_gas.S` + `rclocal_replay.rc` + `RC_GrandLocal_official.dll` → `tools/RC_GrandLocal.dll`(部署名) | ★组件 2 最终版(= 根目录部署版):回放 + 4 补丁 + GAI 垫片 + D3D/光标/Present 钩子 + 全屏接管 + 诊断钩子 |
| `tools/sources/rclogger.c` + `rclogger.def` | 真狗抓取:API 层日志器源码(512B 缓冲区前后对比;留档,build_all.sh 跳过不建) |
| `tools/sources/rclocal_logger.c/.def` + `rclocal_thunks.asm` | 真狗抓取:本地层日志器源码(裸 thunk,convention 无关;留档不建) |
| `research/RCGrandDogW32Real.dll` / `tools/sources/RC_GrandLocal_official.dll` | 原版参考副本(official 是嵌入资源的来源;Real 是抓狗时改名存档的官方 SDK) |
| `tools/sources/selfredir.c` → `tools/selfredir.dll` | ★脱壳组件:NtCreateFile 自读重定向 |
| `tools/sources/run_unpacked.c` → `tools/run_unpacked.exe` | ★脱壳组件:启动器(CREATE_SUSPENDED + 注入) |
| `tools/sources/build_unp.c` → `tools/build_unp.exe` | ★脱壳组件:C 版 PE 重建器(区段 raw←镜像、自建 3-DLL 导入表、清 TLS/reloc/debug) |
| `research/rebuild.py` / `build_unpacked.py` | Python 版重建脚本(等价,需 Python) |
| `tools/sources/oepdump.c` → `tools/oepdump.dll` | ★真 OEP 快照器(配 inject 的 INJECT_SUSPENDED;ntdll 线程启动器 detour) |
| `research/dump_full.py` / `dump_at_oep.py` | minidbg 系 OEP dump(需 Python) |
| `tools/sources/inject.c` → `tools/inject.exe` | 远程线程注入器(含 INJECT_SUSPENDED 模式) |
| `tools/sources/checkhook.c` → `tools/checkhook.exe` | 检查目标进程模块列表 + ntdll!NtCreateFile 钩子状态(验证注入是否生效;同启动周期内 32 位进程共享 ntdll 基址) |
| `tools/sources/unphook_errwatch` `unphook_apilog` `unphook_shadow` `unphook_dr3` `unphook_apidiff` `unphook_livedump` `unphook_ntredir`(.c)→ `tools/unphook_*.dll` | 注入式侦察系列:VEH 硬件写断点盯错误码全局 / API 调用监视 / 文件影子重定向 / 三调试寄存器组合监视 / API 差分追踪 / 活块转储 / NtCreateFile 层自读重定向 |
| `tools/sources/ungraft.c` → `tools/ungraft.dll` | 堆嫁接器(失败路线,留档) |
| `tools/sources/cdbx.c` → `tools/cdbx.exe` | C 版迷你调试器(PEB 反反调试/任意断点/栈回溯/全区域 dump)。注意 Themida int3 必须交壳 VEH |
| `tools/sources/`(dumpthread/dumpmem/dumpx/dumpreg/readmem/scanptr/findrva/dltest/listmods 等 .c)→ `tools/*.exe` | 免调试器外挂工具:全线程栈回溯 / 私有区抓取 / 全状态快照 / minidump 按 VA 提取 / 寄存器 dump / 读 DWORD / 指针扫描 / 导出名→RVA / DLL 装载测试 / 模块枚举 |
| `tools/sources/gai_test.c` `gai_hooktest.c` `test_abort.c` → tools/ 同名产物;`research/diagtest/` | 网卡修复的复现与管路测试 |
| `tools/sources/`(qpccheck/refreshrate/audio_peak/loopback_record.c)→ `tools/*.exe` | 小工具:QPC 核对 / 刷新率 / 音频峰值 / WASAPI 环回录音 |
| `tools/sources/tpkx.c` → `tools/tpkx.exe` | ★TPK 解包器(纯离线):AES-128-ECB + LZO1X 解压 + 条目解析,全量已验证(见 §6.1) |
| `tools/sources/ptffx.c` → `tools/ptffx.exe` | ★PTFF 谱面解密器(纯离线):MT19937(init_by_array)+ v64 + XTEA 反馈,262 个全解(见 §6.2) |
| `tools/sources/verify_ptopen.c` `ptstats.c` `ptcorr.c` → tools/ 同名 exe | PTFF 明文结构实测(对照 DJMax-Editor 解析层):262 文件零失步逐块校验 / 事件字节分布统计 / 0x77 标记相关性 |
| `tools/sources/ptmap.c` `ptsim.c` `ptlanes.c` `pttracks.c` `pttrackdiff.c` `ptsong.c` → tools/ 同名 exe;`research/map_pt.pl` | ★PTFF 识别管线:生成 `extracted_pt_mapping.csv`(乐器表转储/音符重叠/轨道分类统计/歌曲+难度连接,见 §6.2) |
| `tools/sources/mtptff.c` `hashmap*.c` `mtcheck` 等 | PTFF 破解过程工具(MT 推断/哈希对照/变体测试,留档) |
| `tools/sources/chartcap.c`(`ptffhook.c`)`mtlog.c` `attach.c` `pollva.c` → tools/ 同名产物;chartcap.dll 另存 `research/diagtest/` | 运行时侦察:PTFF 解密钩子/MT 流记录/附加注入/内存轮询(定位用) |
| `tools/sources/pngname.c` → `tools/pngname.exe` | 雕刻 PNG 与 tpk 条目按 IDAT 特征配对命名(过程工具;LZO 版 tpkx 后已非必需) |
| `tools/sources/`(pngdims/valcheck/entrydump/align/hdrls/lzdiff/lzinfer/lzsolve/lz4dec/lzotest/lzofile/hashname/ptffbrute/findstr/findbin 等 .c)→ tools/ 同名产物;`research/`(pngfix/pngidat/pngwalk/zprobe/opentest.ps1) | 格式分析与验证工具组(LZ 破解过程留档:条目头转储/双文件对齐/LZ 推断与求解/LZO 验证/批量打开测试等) |
| `tools/sources/tpkdump.c` `lzhunt.c` → `tools/tpkdump.dll` `lzhunt.dll` | 运行时侦察:ntdll 层文件/网络钩子 + PAGE_GUARD 定位解密函数 + 解密上下文 dump(AES 密钥就是这样挖出来的) |
| `tools/sources/dumpva.c` → `tools/dumpva.exe` | 读运行中进程任意 VA 区间到文件(活体取代码用) |
| `tools/sources/aestest.c` → `tools/aestest.exe` | AES-128 自实现 + 密钥候选验证(enc(0)=填充块实锤) |
| `tools/sources/memcarve.c` → `tools/memcarve.exe` | 内存 dump 雕刻 PNG/JPG/OGG/WAV/BMP(块级校验+去重),配合 dumpmem 使用(见 §6.4 备选路线) |
| `tools/sources/`(kscan/bxor/hist/k2test/magicforce/tryoff/scanpng/kvar/ttfsize/checkhook.c)→ tools/ 同名产物;`research/defltest.ps1` | 格式黑盒分析工具组(零填充扫描/双文件 XOR/直方图/TTF 尺寸/注入验证等,过程留档) |
| `tools/sources/fakeserver.c` → `tools/fakeserver.exe`;`research/fakeserver.py` | 4723 端口占位监听(注意:只收不发会卡握手,实测要用真私服) |
| `research/client_renamed.exe` | 改名副本(自读重定向测试用) |
| `research/`(minidbg.py、dbgrun/dbgtrace/dbgcrash/dbgattach.py、watchdbg/watchmb/watchfile/watchrun.py、dumpsec/dumpfunc/memmap/modules/stack/threads/scanall/scaniat/scanmem/findapi/readmem.py) | Python 旧调试器/观测系(早期留档;功能已由 C 版接替) |
| `research/ultra_unpacker_1.4.txt` | LCF-AT Themida 脱壳脚本原件(路线 A 用,不适配本目标) |
| `research/unlicense.exe` / `research/x86/unlicense.exe` | unlicense 0.4.0(对本目标不兼容,留档) |
| `research/pe-sieve32/64.exe` / `pesieve.zip` | 内存 dump 工具 |
| `research/odbg110.zip` / `odbgscript.zip` | olly110 环境的源包(复现路线 A 用) |
| `tools/toolchain/` | ★便携 MinGW 工具链(w64devkit,gcc -m32;`w64devkit_x/` 已解压)。所有 C 工具/DLL 用它构建 |
| `tools/sources/` | ★全部源码与构建输入(94 个 .c + asm/def/rc + 嵌资源官方 DLL);无独立 build 脚本,统一走 build_all.sh |
| `research/` | 逆向研究工具与留档:Python 调试/观测脚本、PS1 小工具、pe-sieve/unlicense/olly 源包、client_renamed.exe、RCGrandDogW32Real.dll、diagtest/、map_pt.pl、*.tsv |
| `tools/build_all.sh` | ★唯一构建脚本:交付件(RC_GrandLocal.dll / RCGrandDogW32.dll / modewatch.exe,输出即部署名)+ 扫描 sources/ 其余 .c 自动建 exe/dll;产物落 tools/,中间产物走临时目录;结果写 build_all.log;留档件(rclocal_replay/rclocal_logger/rclocal_nopatch/rclogger)跳过 |
| `tools/sources/dogtest_wpmwatch.c` `dogtest_imgsnap.c` `localtest.c` `restest.c` | 链式调试台源码(dogtest_wpmwatch=WriteProcessMemory 监视,dogtest_imgsnap=模块镜像快照对比;localtest=本地层 ord5/ord23 拔插对照) |

## 10. 给国际版读者的对照

两版数据格式完全一致(TPK/PTFF/资源布局均同);国际版破解档案在国际版目录
`crack_work/破解总结.md`。
中国版第一层是变异原生代码(固定地址 4 补丁,0xFD7FB90-0xFD80191,RC_GrandLocal.dll
运行期写入);国际版第一层在 Themida VM 里(块交换+嵌套 VM 帧),补丁不可移植——
国际版免狗走 dogfaker"伪造会话"。两版狗密码相同(`dlstodgksqkd`),但国际版 API 层
多卡 ProductCurrentNo==0x64。
破解件形态对照:中国版免狗合体在 `RC_GrandLocal.dll`(本地层转发+补丁+全部体验修复);
国际版拆成 `RCGrandDogW32.dll`(API 回放)+ `tools/firstlayer/dogfaker.dll`(VM 会话伪造)
+ `tools/intfhook.dll`(体验钩子)。**注意名字雷区**:国际版侧任何第三方 DLL 若叫
RC_GrandLocal.dll,会被第一层 VM 探针按模块基名当官方本地层顶包 → 狗检必炸
(同字节 A/B 实锤;国际版体验钩子因此叫 intfhook.dll)。
全屏接管修复两版同步:中国版在 RC_GrandLocal.dll,国际版在 intfhook.dll。
构建工具链(w64devkit gcc)在本版 `crack_work/tools/toolchain/w64devkit_x/`。
