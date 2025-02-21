# torchpod-oh
基于TorchPod的编译/运行OpenHarmony的容器环境。

本项目将![open-harmony-edu-dist项目](https://gitee.com/open-harmony-edu-dist) TorchPod化，提供了在Linux、macOS、Windows上编译和运行OpenHarmony的图形化开发环境。


# 部署
使用gemfield/torchpod-oh镜像，部署和登录参考![TorchPod的部署和登录](https://github.com/DeepVAC/TorchPod?tab=readme-ov-file#%E9%83%A8%E7%BD%B2%E5%92%8C%E8%BF%90%E8%A1%8Ctorchpod)。

请注意：如果想在编译后直接用qemu运行openharmony镜像，则部署TorchPod的时候需要使用root权限，也即docker命令行带--privileged=true 。

# 编译
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

修改foundation/graphic/graphic_3d/lume/LumeBinaryCompile/lumeassetcompiler/src/main.cpp的add_directory函数为：
```c++
void add_directory(const std::string& path, const std::string& outpath)
{
    ......
    while ((pDirent = readdir(pDir)) != NULL) {
        // This structure may be statically allocated
        size_t d_size = pDirent->d_reclen;
        struct dirent* a_copy = static_cast<struct dirent*>(std::malloc(d_size));
        std::memcpy(a_copy, pDirent, d_size); ;
        dirSet.insert(a_copy);
    }

    for (auto &d : dirSet) {
        if (d->d_type == DT_DIR) {
            if (d->d_name[0] == '.') {
                continue;
            }
            add_directory(p + d->d_name, op + d->d_name);
            continue;
        }
        append_file(p + d->d_name, op + d->d_name);
    }
    for (auto& d : dirSet) {
        std::free(d);
    }

    closedir(pDir);
}
```

修改drivers/hdf_core/adapter/khdf/linux/network/src/net_device_adapter.c的NetDevReceive函数：
```c++
if (flag & IN_INTERRUPT) {
  netif_rx(buff);
} else {
  netif_rx_ni(buff);
}
```
改为：
```c++
netif_rx(buff);
```

- 编译
```bash
bash -x ./build.sh --product-name x86_64_virt
```

- 编译产物：
```bash
gemfield@bf4ab8b417f9:/media/gemfieldU/qemu$ find out/x86_64_virt/ -type f -name *.img
out/x86_64_virt/packages/phone/images/chip_prod.img
out/x86_64_virt/packages/phone/images/eng_system.img
out/x86_64_virt/packages/phone/images/updater.img
out/x86_64_virt/packages/phone/images/ramdisk.img
out/x86_64_virt/packages/phone/images/system.img
out/x86_64_virt/packages/phone/images/vendor.img
out/x86_64_virt/packages/phone/images/userdata.img
out/x86_64_virt/packages/phone/images/sys_prod.img
```
以及
```bash
vendor/edu/x86_64_virt/qemu_run.sh
```

# 运行
确保TorchPod容器是以root权限启动的（也即：docker命令行带--privileged=true）：
```bash
docker run --privileged=true -v /home/gemfield:/media/gemfield -p 5900:5900 -eTORCHPOD_MODE=VNC -ePROTOCOL=X11 gemfield/torchpod-oh
```
登录TorchPod，执行以下三个步骤：
```bash
#切换到/opt/oh目录
#第一步：执行initnetwork.sh
gemfield@1f1f51e81a50:/opt/oh$ sudo ./initnetwork.sh 
NOTICE: must run with sudo.

dnsmasq: no process found

Now, run below 2 commands in your current konsole to set the environment variables: 

-----------------------------------------------------
export NET_OPTS="-netdev tap,id=net0,ifname=ohostap0,script=no,downscript=no -device virtio-net-pci,netdev=net0,mac=70:30:10:02:18:06" 
export OHOS_IMG_DIR=<your_ohos_img_dir>
-----------------------------------------------------

#第二步：根据上述的输出结果，设置两个环境变量：
gemfield@1f1f51e81a50:/opt/oh$ export NET_OPTS="-netdev tap,id=net0,ifname=ohostap0,script=no,downscript=no -device virtio-net-pci,netdev=net0,mac=70:30:10:02:18:06"
gemfield@1f1f51e81a50:/opt/oh$ export OHOS_IMG_DIR=/media/gemfield/images/

#第三步：启动qemu
gemfield@bf4ab8b417f9:/opt/oh$ ./qemu_run.sh
```

![OpenHarmony在TorchPod上启动](https://github.com/user-attachments/assets/29dc21c2-28a9-48ed-994d-2d1d6e60a483)


此后可以使用hdc命令：
```bash
#IP地址默认为192.168.111.49，你也可以从qemu的终端上用ifconfig命令获得openharmony的IP地址
gemfield@1f1f51e81a50:/opt/oh$ hdc tconn 192.168.111.49:55555
Connect OK
gemfield@1f1f51e81a50:/opt/oh$ hdc list targets -v
192.168.111.49:55555            TCP     Connected       localhost

gemfield@1f1f51e81a50:/opt/oh$ hdc shell 
# ls /
bin        config       eng_system  lost+found     storage   tmp      
chip_ckm   data         etc         mnt            sys       updater  
chip_prod  dev          init        module_update  sys_prod  vendor   
chipset    eng_chipset  lib         proc           system
```



