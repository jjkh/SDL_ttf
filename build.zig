const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const use_harfbuzz = b.option(bool, "use_harfbuzz", "Use HarfBuzz") orelse true;

    const lib = b.addStaticLibrary(.{
        .name = "SDL2_ttf",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile(.{ .file = b.path("SDL_ttf.c"), .flags = &.{if (use_harfbuzz) "-DTTF_USE_HARFBUZZ=1" else ""} });
    lib.linkLibC();

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
        .enable_brotli = false,
    });
    lib.linkLibrary(freetype_dep.artifact("freetype"));

    if (use_harfbuzz) {
        if (b.lazyDependency("harfbuzz", .{ .target = target, .optimize = optimize })) |harfbuzz_dep| {
            const harfbuzz = harfbuzz_dep.artifact("harfbuzz");
            lib.linkLibrary(harfbuzz);
            if (harfbuzz.installed_headers_include_tree) |tree|
                lib.addIncludePath(tree.getDirectory().path(b, "harfbuzz"));
        }
    }

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl = sdl_dep.artifact("SDL2");
    lib.linkLibrary(sdl);
    if (sdl.installed_headers_include_tree) |tree|
        lib.addIncludePath(tree.getDirectory().path(b, "SDL2"));

    lib.installHeader(b.path("SDL_ttf.h"), "SDL2/SDL_ttf.h");
    b.installArtifact(lib);
}
