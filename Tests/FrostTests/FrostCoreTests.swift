import Testing
@testable import FrostCore

@Suite struct SemVerTests {
    @Test func parses() {
        #expect(SemVer("1.2.3") == SemVer(1, 2, 3))
        #expect(SemVer("v0.10.0") == SemVer(0, 10, 0))
        #expect(SemVer(" 2.0.1\n") == SemVer(2, 0, 1))
    }
    @Test func rejectsBadInput() {
        #expect(SemVer("1.2") == nil)
        #expect(SemVer("1.2.x") == nil)
        #expect(SemVer("-1.0.0") == nil)
        #expect(SemVer("") == nil)
    }
    @Test func ordersNumerically() {
        #expect(SemVer(0, 9, 0) < SemVer(0, 10, 0))
        #expect(SemVer(1, 0, 0) > SemVer(0, 99, 99))
        #expect(SemVer(1, 2, 3).description == "1.2.3")
    }
}

@Suite struct DividerTests {
    @Test func startsCollapsedAndToggles() {
        var d = DividerState()
        #expect(d.collapsed && d.length == DividerState.collapsedLength)
        d.toggle()
        #expect(!d.collapsed && d.length == DividerState.expandedLength)
        d.collapse(); d.collapse()
        #expect(d.collapsed)
    }
    @Test func autoHide() {
        #expect(AutoHide.never.seconds == nil)
        #expect(AutoHide.tenSeconds.seconds == 10)
    }
}
