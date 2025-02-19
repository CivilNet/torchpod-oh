# torchpod-oh
基于TorchPod的编译/运行OpenHarmony的容器环境。

本项目将![open-harmony-edu-dist项目](https://gitee.com/open-harmony-edu-dist) TorchPod化，提供了在Linux、macOS、Windows上编译和运行OpenHarmony的环境。


# 部署
使用gemfield/torchpod-oh镜像，部署和登录参考![TorchPod的部署和登录](https://github.com/DeepVAC/TorchPod?tab=readme-ov-file#%E9%83%A8%E7%BD%B2%E5%92%8C%E8%BF%90%E8%A1%8Ctorchpod)。

# 编译步骤
- 克隆源代码
```bash
repo init -u https://gitee.com/open-harmony-edu-dist/manifest -b refs/heads/OpenHarmony-5.0.2-Release --no-repo-verify
repo sync -c
repo forall -c 'git lfs pull'
bash -x build/prebuilts_download.sh
```
- 修改源文件

在以下文件中添加<stdint.h>头文件：
```bash
arkcompiler/ets_runtime/ecmascript/common.h
arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_be/include/cg/x86_64/assembler/util.h
arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/file_layout.h
arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/namemangler.h
arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/profile_type.h
arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/utils.h
arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/src/mpl_logging.cpp #该文件同时添加<cstring>头文件

arkcompiler/runtime_core/assembler/assembly-debug.h
arkcompiler/runtime_core/libpandabase/os/stacktrace.h
arkcompiler/runtime_core/static_core/templates/events/events.h.erb
arkcompiler/runtime_core/templates/events/events.h.erb

developtools/global_resource_tool/src/config_parser.cpp #该文件同时添加<cstring>头文件
developtools/global_resource_tool/src/resource_util.cpp #该文件同时添加<cstring>头文件

drivers/hdf_core/framework/tools/hdi-gen/util/options.cpp
```

- 编译
```bash
bash -x ./build.sh --product-name x86_64_virt
```

# 运行
