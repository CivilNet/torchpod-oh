# torchpod-oh
用于OpenHarmony开发和编译的容器环境


# 部署后的使用
- 克隆源代码
```bash
repo init -u https://gitee.com/openharmony/manifest.git -b refs/tags/OpenHarmony-v5.0.0-Release --no-repo-verify
repo sync -c
repo forall -c 'git lfs pull'
bash -x build/prebuilts_download.sh
```
- 编译
```bash
bash -x ./build.sh --product-name x86_general --ccache
```

# workaround

- arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/utils.h
- arkcompiler/runtime_core/libpandabase/os/stacktrace.h
- arkcompiler/ets_runtime/ecmascript/common.h
- arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_be/include/cg/x86_64/assembler/util.h
- arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/file_layout.h
- arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/namemangler.h
- arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/include/profile_type.h
- arkcompiler/runtime_core/assembler/assembly-debug.h
- arkcompiler/runtime_core/compiler/generated/compiler_events_gen.h
- clang_x64/gen/arkcompiler/runtime_core/compiler/generated/compiler_events_gen.h
- ./out/sdk/clang_x64/gen/arkcompiler/runtime_core/compiler/generated/compiler_events_gen.h
- ./out/x86_general/obj/build/templates/bpf/x86_64-linux-ohos/usr/include/linux/if.h
- arkcompiler/ets_runtime/ecmascript/compiler/codegen/maple/maple_util/src/mpl_logging.cpp
- developtools/global_resource_tool/src/config_parser.cpp
- developtools/global_resource_tool/src/resource_util.cpp
- drivers/hdf_core/framework/tools/hdi-gen/util/options.cpp