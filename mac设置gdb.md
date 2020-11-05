mac设置gdb

```sh
brew install gdb
```

设置权限

https://sourceware.org/gdb/wiki/PermissionsDarwin

1、钥匙串->证书助理->创建证书

2、一路确定，注意两点，证书类型：代码签名，储存位置：system

3、点击证书，全部信任

(Mac OS X 10.14 and later) Create a `gdb-entitlement.xml` file containing the following:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.allow-dyld-environment-variables</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.cs.disable-executable-page-protection</key>
    <true/>
    <key>com.apple.security.cs.debugger</key>
    <true/>
    <key>com.apple.security.get-task-allow</key>
    <true/>
</dict>
</plist>
</pre>
```

If the certificate you generated in the previous section is known as `gdb-cert`, use:

```sh
codesign --entitlements gdb-entitlement.xml -fs gdb-cert $(which gdb)
```

or before Mojave (10.14), just

```sh
codesign -fs gdb-cert $(which gdb)
```

The most reliable way is to reboot your system.

A less invasive way is to and restart `taskgated` service by killing the current running taskgated process (at any time in the process, but no later than before trying to run gdb again):



```sh
sudo killall taskgated
```