const { Marp } = require('@marp-team/marp-core');
const markdownItContainer = require('markdown-it-container');
const markdownItFootnote = require('markdown-it-footnote');

const markdownItInclude = require('markdown-it-include');
const optionsInclude = {
    root: '.',
    includeRe: /!include(.+)/,
    bracesAreOptional: false
};

var codeql = function(hljs) {
  const regex = hljs.regex;
  const RESERVED_WORDS = [
    'and',
    'any',
    'or',
    'none',
    'import',
    'in',
    'class',
    'extends',
    'instanceof',
    'exists',
    'predicate',
    'from',
    'where',
    'select',
  ];
 
  const BUILT_INS = [
    'this',
  ];
  const LITERALS = [
    'true', 'false'
  ];
  const TYPES = [
    'boolean',
    'int'
  ]

  const KEYWORDS = {
    $pattern: /[A-Za-z]\w+|__\w+__/,
    keyword: RESERVED_WORDS,
    built_in: BUILT_INS,
    literal: LITERALS,
    type: TYPES
  };

  
  return {
    name: 'CodeQL',
    aliases: [
      'ql',
      'qll'
    ],
    unicodeRegex: true,
    keywords: KEYWORDS,
    illegal: /(<\/|\?)|=>/,
    contains: [
      // Comments
      hljs.COMMENT(
        '/\\*\\*',
        '\\*/',
        {
          relevance: 0,
          contains: [
            {
              // eat up @'s in emails to prevent them to be recognized as doctags
              begin: /\w+@/,
              relevance: 0
            },
            {
              className: 'doctag',
              begin: '@[A-Za-z]+'
            }
          ]
        }
      ),
      hljs.C_LINE_COMMENT_MODE,
      hljs.C_BLOCK_COMMENT_MODE,
      // Imports
      {
        begin: /import semmle\.[a-z]+\./,
        keywords: "import",
        relevance: 2
      },
      // Strings
      {
        begin: /"""/,
        end: /"""/,
        className: "string",
        contains: [ hljs.BACKSLASH_ESCAPE ]
      },
      hljs.APOS_STRING_MODE,
      hljs.QUOTE_STRING_MODE,
    ]
  };
}

// https://www.npmjs.com/package/markdown-it-highlightjs
const markdownItHighlight = require('markdown-it-highlightjs');

const highlightOpts = {
    hljs: require('highlight.js'),
    register: {
        codeql: codeql
    }
};


module.exports = (opts) => new Marp(opts)
    .use(markdownItFootnote)
    .use(markdownItContainer, 'columns')
    .use(markdownItInclude, optionsInclude)
    .use(markdownItHighlight, highlightOpts)


