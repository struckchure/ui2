module ui2

// Validate every link before an editor can write through a nested struct.
// Requiring public, mutable intermediate fields mirrors a direct V assignment.
fn vml_writable_path_type[T](model T, parts []string, path string) !string {
	if parts.len == 0 || parts[0].len == 0 {
		return error('invalid app field `${path}`')
	}
	$for field in T.fields {
		if field.name == parts[0] {
			$if !field.is_pub {
				return error('app field `${path}` is not public at `${field.name}`')
			} $else $if !field.is_mut {
				return error('app field `${path}` is not mutable at `${field.name}`')
			} $else {
				if parts.len == 1 {
					return typeof(field).name
				}
				$if field.typ is $struct {
					return vml_writable_path_type(model.$(field.name), parts[1..], path)
				} $else {
					return error('app field `${path}` cannot traverse `${field.name}`')
				}
			}
		}
	}
	return error('unknown app field `${path}`')
}

fn vml_set_path[T](mut model T, parts []string, path string, value VValue) ! {
	if parts.len == 0 || parts[0].len == 0 {
		return error('invalid app field `${path}`')
	}
	$for field in T.fields {
		if field.name == parts[0] {
			$if !field.is_pub {
				return error('app field `${path}` is not public at `${field.name}`')
			} $else $if !field.is_mut {
				return error('app field `${path}` is not mutable at `${field.name}`')
			} $else {
				if parts.len > 1 {
					$if field.typ is $struct {
						vml_set_path(mut model.$(field.name), parts[1..], path, value)!
						return
					} $else {
						return error('app field `${path}` cannot traverse `${field.name}`')
					}
				}
				$if field.typ is string {
					model.$(field.name) = value.string_value()
					return
				} $else $if field.typ is bool {
					model.$(field.name) = value.truthy()
					return
				} $else $if field.typ is int {
					model.$(field.name) = int(value.numeric(0)!)
					return
				} $else $if field.typ is f64 {
					model.$(field.name) = value.numeric(0)!
					return
				} $else $if field.typ is f32 {
					model.$(field.name) = f32(value.numeric(0)!)
					return
				} $else {
					return error('two-way binding does not support app field `${path}` of type `${typeof(field).name}`')
				}
			}
		}
	}
	return error('unknown app field `${path}`')
}
