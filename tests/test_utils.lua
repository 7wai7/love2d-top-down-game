local TestUtils = {}

function TestUtils.assertEqual(actual, expected, message)
    assert(
        actual == expected,
        ("%s: expected '%s', got '%s'"):format(
            message or "values are not equal",
            tostring(expected),
            tostring(actual)
        )
    )
end

return TestUtils
