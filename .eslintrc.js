// Documentation on http://eslint.org/docs/rules/

module.exports = {
  'env': {
    'browser': true,
    'node': true,
    'jquery': true
  },
  'rules': {
    'no-unused-expressions': ['error', { 'allowShortCircuit': true }],
    'max-len': ['error', { 'code': 113 }]
  },
}
