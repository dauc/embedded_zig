const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("firmware", "main.zig");
    exe.setTarget(builtin.Arch { .thumb = .v7m }, builtin.Os.freestanding, builtin.Abi.none);

    const main_o = b.addObject("startup", "startup.zig");
    main_o.setTarget(builtin.Arch { .thumb = .v7m }, builtin.Os.freestanding, builtin.Abi.none);
    exe.addObject(main_o);

    exe.setBuildMode(mode);
    exe.setLinkerScriptPath("arm_cm3.ld");

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}