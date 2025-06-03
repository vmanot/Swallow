extension UnsafePointer {
    @_spi(CastUnsafeRawPointer)
    @_transparent
    public var raw: UnsafeRawPointer { UnsafeRawPointer(self) }
}

extension UnsafePointer where Pointee: ~Copyable {
    @_spi(CastUnsafeRawPointer)
    @_transparent
    public var raw: UnsafeRawPointer { UnsafeRawPointer(self) }
}

extension UnsafeBufferPointer {
    @_spi(CastUnsafeRawPointer)
    @_transparent
    public var raw: UnsafeRawPointer { UnsafeRawPointer(baseAddress.unsafelyUnwrapped) }
}

extension UnsafeBufferPointer where Element: ~Copyable {
    @_spi(CastUnsafeRawPointer)
    @_transparent
    public var raw: UnsafeRawPointer { UnsafeRawPointer(baseAddress.unsafelyUnwrapped) }
}
