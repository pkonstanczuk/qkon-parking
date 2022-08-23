import six


class VOpenApiEncoder:
    @staticmethod
    def _is_open_api_generate(o, models: set) -> bool:
        for entry in models:
            if isinstance(o, entry):
                return True
        return False

    @staticmethod
    def encode(o, models: set):
        if VOpenApiEncoder._is_open_api_generate(o, models):
            record = {}
            for attr, _ in six.iteritems(o.openapi_types):
                value = getattr(o, attr)
                if value is None:
                    continue
                attr = o.attribute_map[attr]
                if (
                    isinstance(value, list)
                    or isinstance(value, dict)
                    or VOpenApiEncoder._is_open_api_generate(value, models)
                ):
                    record[attr] = VOpenApiEncoder.encode(value, models)
                else:
                    record[attr] = value
            return record
        elif isinstance(o, list):
            return list(
                map(
                    lambda x: VOpenApiEncoder.encode(x, models)
                    if VOpenApiEncoder._is_open_api_generate(x, models)
                    else x,
                    o,
                )
            )
        elif isinstance(o, dict):
            return {
                key: VOpenApiEncoder.encode(val, models) if VOpenApiEncoder._is_open_api_generate(val, models) else val
                for key, val in o.items()
            }
        return o
