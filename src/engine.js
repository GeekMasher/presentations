const { Marp } = require('@marp-team/marp-core');
const markdownItContainer = require('markdown-it-container')
const markdownItFootnote = require('markdown-it-footnote');
const markdownItInclude = require('markdown-it-include');


const optionsInclude = {
    root: '.',
    includeRe: /!include(.+)/,
    bracesAreOptional: false
  };

module.exports = (opts) => new Marp(opts)
    .use(markdownItFootnote)
    .use(markdownItContainer, 'columns')
    .use(markdownItInclude, optionsInclude)
