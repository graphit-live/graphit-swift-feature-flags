import GraphitFeatureFlags
import Testing

@Test func packageExposesBootstrapAPIShell() throws {
    let key = FeatureFlagKey("bootstrap")
    let flag = FeatureFlag.enabled(key)
    let snapshot = FeatureFlagSnapshot([flag])
    let flags = try FeatureFlags(snapshot: snapshot)

    #expect(flags.snapshot == snapshot)
}
