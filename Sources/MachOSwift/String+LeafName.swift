extension String {
    var leafName: String {
        if let slashRange = range(of: "/", options: .backwards) {
            return String(self[slashRange.upperBound...])
        } else {
            return self
        }
    }
}
