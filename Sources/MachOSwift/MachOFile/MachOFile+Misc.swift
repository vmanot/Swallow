extension MachOFile {
    @_alwaysEmitIntoClient
    public var architecture: Architecture? {
        return Architecture(cputype: cputype, cpusubtype: cpusubtype)
    }
}
