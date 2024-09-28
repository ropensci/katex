function html_render_math(html, include_css, options){
  var $ = cheerio.load(html);
  options = options || {};
  $('.math.inline').each(function(i, el){
    var el = $(el)
    var text = el.text().trim();
    /* pandoc --mathjax replaces $..$ with \(...\)  */
    var math = text.match(/\$([\s\S]*)\$$/) || text.match(/\\\(([\s\S]*)\\\)$/);
    if(math && math[1])
      text = math[1];
    options.displayMode = false;
    var out = katex.renderToString(text, options);
    el.replaceWith(out);
  });
  $('.math.display').each(function(i, el){
    var el = $(el)
    var text = el.text().trim();
    /* pandoc --mathjax replaces $$..$$ with \[...\]  */
    var math = text.match(/^\${2}([\s\S]*)\${2}$/) || text.match(/\\\[([\s\S]*)\\\]$/);
    if(math && math[1])
      text = math[1];
    options.displayMode = true;
    var out = katex.renderToString(text, options);
    el.replaceWith(out);
  });
  if(include_css){
    var head = $('head');
    if(head.length){
      head.append('<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css" data-external="1">');
    } else {
      /* html snippet without a proper <head>, just append css at the top */
      $.root().prepend('<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css" data-external="1">\n');
    }
  }
  return $.html();
}
