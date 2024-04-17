const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "SDL2_ttf",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile(.{ .file = b.path("SDL_ttf.c") });
    lib.linkLibC();

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
        .enable_brotli = false,
    });
    lib.linkLibrary(freetype_dep.artifact("freetype"));

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(sdl_dep.artifact("SDL2"));

    lib.installHeader(b.path("SDL_ttf.h"), "SDL2/SDL_ttf.h");
    b.installArtifact(lib);
}
