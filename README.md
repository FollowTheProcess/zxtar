# zxtar

[![License](https://img.shields.io/github/license/FollowTheProcess/zxtar)](https://github.com/FollowTheProcess/zxtar)
[![GitHub](https://img.shields.io/github/v/release/FollowTheProcess/zxtar?logo=github&sort=semver)](https://github.com/FollowTheProcess/zxtar)
[![CI](https://github.com/FollowTheProcess/zxtar/workflows/CI/badge.svg)](https://github.com/FollowTheProcess/zxtar/actions?query=workflow%3ACI)

An implementation of the [txtar] archive format in Zig 🦎

> [!WARNING]
> **zxtar is in early development and is not yet ready for use**

## Project Description

## Installation

```shell
zig fetch --save git+https://github.com/FollowTheProcess/zxtar.git
```

Then add the following to `build.zig`:

```zig
const zxtar = b.dependency("zxtar", .{});
exe.root_module.addImport("zxtar", zxtar.module("zxtar"));
```

## Quickstart

TBC

[txtar]: https://pkg.go.dev/golang.org/x/tools/txtar
