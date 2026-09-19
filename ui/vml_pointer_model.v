module ui2

// Track the current reference path, not a global visited set: two model fields
// may legitimately point at the same object. Back-edges and nil values remain
// invalid VML values and produce the usual source-line property-path error.
fn v_value_from[T](value T) VValue {
	return v_value_from_tracked[T](value, []voidptr{})
}

fn v_value_from_pointee[E](value &E, ancestors []voidptr) VValue {
	$if E is $pointer {
		return v_value_from_tracked[E](E(unsafe { voidptr(*value) }), ancestors)
	} $else {
		return v_value_from_tracked[E](*value, ancestors)
	}
}

fn v_schema_from[T](value T) VSchema {
	return v_schema_from_tracked[T](value, []voidptr{}, []string{})
}

fn v_schema_from_pointee[E](value &E, ancestors []voidptr, nil_types []string) VSchema {
	$if E is $pointer {
		return v_schema_from_tracked[E](E(unsafe { voidptr(*value) }), ancestors, nil_types)
	} $else {
		return v_schema_from_tracked[E](*value, ancestors, nil_types)
	}
}

fn v_schema_from_nil_pointee[E](_ &E, ancestors []voidptr, nil_types []string) VSchema {
	$if E is $pointer {
		return v_schema_from_tracked[E](E(unsafe { nil }), ancestors, nil_types)
	} $else {
		return v_schema_from_tracked[E]($zero(E), ancestors, nil_types)
	}
}
