module ui2

// Interface fields are part of the declared contract, even when a Repeater's
// collection is empty. Do not select fields from a zero interface: it has no
// backing object. Construct each field's schema from its type instead.
fn v_interface_schema[E](_ E) VSchema {
	mut fields := map[string]VSchema{}
	$for field in E.fields {
		$if field.is_pub {
			zero := $zero(field.typ)
			fields[field.name] = v_schema_from(zero)
		}
	}
	return VSchema{
		kind:   .object
		fields: fields
	}
}

fn v_interface_value[E](value E) VValue {
	mut fields := map[string]VValue{}
	$for field in E.fields {
		$if field.is_pub {
			fields[field.name] = v_value_from(value.$(field.name))
		}
	}
	return v_object(fields)
}
