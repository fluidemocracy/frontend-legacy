var wysihtmlParserRules = {
  tags: {
    b:      {},
    i:      {},
    br:     {},
    p:      {},
    ul:     {},
    ol:     {},
    li:     {},
    a:      {
      check_attributes: {
        href:   "url" // important to avoid XSS
      }
    },
    h1: {},
    h2: {},
    h3: {},
    h4: {},
    h5: {},
    h6: {},
    sup: {},
    sub: {}
  }
};
