/// Generates a locally-unique annotation id. Matches this codebase's
/// existing convention for client-generated ids (see e.g. the custom-book
/// and reading-club flows, both `'prefix_${DateTime.now().millisecondsSinceEpoch}'`)
/// rather than pulling in a `uuid` package. Adds an identity-hash suffix
/// since two annotations can plausibly be created within the same
/// millisecond (e.g. a merge followed immediately by a new selection).
String newAnnotationId() =>
    'annotation_${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}';
